//
//  ToDoListStorage.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 03.08.2026.
//


import Foundation
import CoreData

// MARK: - ToDoListStorage
protocol ToDoListStorage: AnyObject {
    
    /// Выгружает все задачи из локального хранилища.
    ///
    /// Вычитка данных производится строго через **главный контекст (viewContext)** на основном потоке.
    /// Это архитектурное решение намертво устраняет гонку потоков (Data Race) и предотвращает
    /// рассинхронизацию приватных очередей Core Data при самом первом старте приложения,
    /// гарантируя, что координатор хранилища успеет прогрузить свойства объектов,
    /// исключая возвращение пустых Fault-заглушек с нулевыми идентификаторами.
    ///
    /// - Parameter completion: Замыкание, возвращающее результат вычитки: массив доменных моделей `[ToDoItem]` или ошибку.
    func fetchAllTasks(completion: @escaping (Result<[ToDoItem], Error>) -> Void)
    
    /// Асинхронно сохраняет новую или обновляет существующую задачу в локальной базе данных.
    ///
    /// Транзакция записи на диск и слияние изменений осуществляются в **фоновом контексте (backgroundContext)**,
    /// что гарантирует стопроцентную отзывчивость интерфейса при параллельных мутациях данных.
    /// Статус завершения операции безопасно доставляется на **главный поток (mainQueue)**.
    ///
    /// - Parameters:
    ///   - task: Доменная модель задачи `ToDoItem`, подлежащая фиксации на диске.
    ///   - completion: Замыкание, возвращающее статус успеха (Void) или ошибку транзакции.
    func saveTask(_ task: ToDoItem, completion: @escaping (Result<Void, Error>) -> Void)
}


// MARK: - ToDoListStorage Implementation
final class ToDoListStorageImpl: ToDoListStorage, Logable {
    
    private let coreDataStorage: any CoreDataStorage<ToDoItemEntity>
    
    init(coreDataStorage: any CoreDataStorage<ToDoItemEntity>) {
        self.coreDataStorage = coreDataStorage
    }
    
    // MARK: - ToDoListStorage (implementation)
    
    func fetchAllTasks(completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        coreDataStorage.fetchEntities(.all) { result in
            switch result {
            case .success(let entities):
                let domainItems = entities.map { $0.toDomain() }
                completion(.success(domainItems))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func saveTask(_ task: ToDoItem, completion: @escaping (Result<Void, Error>) -> Void) {
        coreDataStorage.saveInBackground(completionQueue: .main) { context in
            
            let entity = ToDoItemEntity(context: context)
            entity.id = task.id
            entity.title = task.title
            entity.taskDescription = task.description
            entity.isCompleted = task.isCompleted
            entity.date = task.date
            
        } completion: { result in
            completion(result)
        }
    }
}
