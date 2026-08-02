//
//  CoreDataContextProvider.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 30.07.2026.
//
import Foundation
import CoreData

enum CoreDataContextProviderError: Error, LocalizedError {
    case failedToLoadModel(String)
    case notInitialized
    case alreadyInitialized
    
    public var errorDescription: String? {
        switch self {
        case .failedToLoadModel(let message):
            return "Не удалось загрузить модель Core Data: \(message)"
        case .notInitialized:
            return "Контекст Core Data не инициализирован"
        case .alreadyInitialized:
            return "Контекст Core Data уже инициализирован"
        }
    }
}

protocol CoreDataContextProvider: AnyObject {
    
    func initialize(completion: @escaping (Result<Void, Error>) -> Void)
    var viewContext: NSManagedObjectContext? { get }
    func makeBackgroundContext() -> NSManagedObjectContext?
    func performBackgroundTask( block: @escaping (_ writeContext: NSManagedObjectContext) -> Void,
                                receiveCompletionOn queue: DispatchQueue,
                                completion: @escaping (Result<Void, Error>) -> Void)
}

final class CoreDataContextProviderImpl: Logable {
    
    // MARK: - Private properties
    
    private let containerName: String
    private let bundle: Bundle
    private var persistentContainer: NSPersistentContainer?
    private var isInitialized = false
    
    func initialize(completion: @escaping (Result<Void, Error>) -> Void) {
        guard !isInitialized else {
            completion(.failure(CoreDataContextProviderError.alreadyInitialized))
            return
        }
        
        self.loadPersistentContainer(bundle: bundle) { result in
            switch result {
            case .success:
                self.isInitialized = true
            case .failure:
                self.isInitialized = false
            }
            
            completion(result)
        }
    }
    
    // MARK: - Life cycle
    init(containerName: String = "ToDoList", bundle: Bundle = .main) {
        self.containerName = containerName
        self.bundle = bundle
    }
    
    // MARK: - CoreDataContextProvider (implementation)
    
    var viewContext: NSManagedObjectContext? {
        guard isInitialized else {
            return nil
        }
        return persistentContainer?.viewContext
    }
    
    func makeBackgroundContext() -> NSManagedObjectContext? {
        guard isInitialized, let container = persistentContainer else {
            return nil
        }
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    func performBackgroundTask(
        block: @escaping (_ writeContext: NSManagedObjectContext) -> Void,
        completionQueue: DispatchQueue = .main,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let container = persistentContainer else {
            completionQueue.async {
                completion(.failure(CoreDataContextProviderError.notInitialized))
            }
            return
        }
        
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        context.perform { [weak self] in
            guard let self = self else { return }
            
            do {
                block(context)
                try context.save()
                
                // Создаем уведомление
                let notification = NSNotification(
                    name: .NSManagedObjectContextDidSave,
                    object: context
                ) as Notification
                
                // Используем асинхронное слияние
                self.viewContext?.perform {
                    self.viewContext?.mergeChanges(fromContextDidSave: notification)
                    do {
                        try self.viewContext?.save()
                        completionQueue.async {
                            completion(.success(()))
                        }
                    } catch {
                        completionQueue.async {
                            completion(.failure(error))
                        }
                    }
                }
            } catch {
                completionQueue.async {
                    completion(.failure(error))
                }
            }
        }
    }
}

// MARK: - Load persistent container (private)
private extension CoreDataContextProviderImpl {
    func loadPersistentContainer(bundle: Bundle, completion: @escaping (Result<Void, Error>) -> Void) {
        // Пытаемся получить URL для модели
        guard let modelURL = bundle.url(forResource: containerName, withExtension: "momd") else {
            completion(.failure(CoreDataContextProviderError.failedToLoadModel("Не удалось найти URL модели")))
            return
        }
        
        // Загружаем модель из полученного URL
        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            completion(.failure(CoreDataContextProviderError.failedToLoadModel("Не удалось загрузить модель из URL")))
            return
        }
        
        let container = NSPersistentContainer(name: containerName, managedObjectModel: model)
        
        container.loadPersistentStores { description, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Включаем автоматическое слияние изменений между контекстами
            container.viewContext.automaticallyMergesChangesFromParent = true
            // Задаем политику разрешения конфликтов (преимущество у данных в памяти)
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            self.persistentContainer = container
            completion(.success(()))
        }
    }
}
