//
//  ToDoListStorage.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 03.08.2026.
//


import Foundation
import CoreData

// MARK: - ToDoListStorage Contract
protocol ToDoListStorage: AnyObject {
    func fetchAllTasks(completion: @escaping (Result<[ToDoItem], Error>) -> Void)
}

// MARK: - ToDoListStorage Implementation
final class ToDoListStorageImpl: ToDoListStorage {
    
    // Закрываемся протоколом через 'any' строго под ToDoItemEntity! Чистый SOLID. 🧱💎
    private let coreDataStorage: any CoreDataStorage<ToDoItemEntity>
    
    init(coreDataStorage: any CoreDataStorage<ToDoItemEntity>) {
        self.coreDataStorage = coreDataStorage
    }
    
    // MARK: - ToDoListStorage Realization
    
    func fetchAllTasks(completion: @escaping (Result<[ToDoItem], Error>) -> Void) {
        coreDataStorage.fetchEntitiesInBackground(.all, completionQueue: .main) { result in
            switch result {
            case .success(let entities):
                let domainItems = entities.map { $0.toDomain() }
                completion(.success(domainItems))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
