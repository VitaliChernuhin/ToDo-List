//
//  CoreDataStorage.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 30.07.2026.
//

import Foundation
import CoreData

enum CoreDataStorageError: Error, LocalizedError {
    case contextNotAvailable
    case fetchFailed(String)
    case saveFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .contextNotAvailable:
            return "Контекст Core Data недоступен"
        case .fetchFailed(let message):
            return "Ошибка при выполнении запроса: \(message)"
        case .saveFailed(let message):
            return "Ошибка сохранения данных: \(message)"
        }
    }
}

protocol CoreDataStorage<Storable>: AnyObject, ReadableCoreDataStore, WritableCoreDataStore where Writable == Storable {
    
}

final class CoreDataStorageImpl<T: NSManagedObject>: CoreDataStorage where T: IdentifiableManagedObject {
    
    // MARK: - Private properties
    private static var entityName: String {
        String(describing: T.self)
    }
    
    private let contextProvider: CoreDataContextProvider
    
    init(contextProvider: CoreDataContextProvider) {
        self.contextProvider = contextProvider
    }
}

// MARK: - ReadableCoreDataStore (implementation)
extension CoreDataStorageImpl: ReadableCoreDataStore {
    typealias Storable = T
    
    func fetchEntities(_ fetchOptions: FetchOptions, completion: @escaping (Result<[T], any Error>) -> Void) {
        guard let context = self.contextProvider.viewContext else {
            completion(.failure(CoreDataStorageError.contextNotAvailable))
            return
        }
        
        context.perform {
            do {
                let request = NSFetchRequest<T>(entityName: Self.entityName)
                
                switch fetchOptions {
                case let .filtered(predicate):
                    request.predicate = predicate
                case let .sorted(sortDescriptors):
                    request.sortDescriptors = sortDescriptors
                case let .filteredAndSorted(predicate, sortDescriptors):
                    request.predicate = predicate
                    request.sortDescriptors = sortDescriptors
                case .all:
                    break
                }
                
                request.returnsObjectsAsFaults = false
                request.includesPropertyValues = true
                
                let entities = try context.fetch(request)
                completion(.success(entities))
            } catch {
                completion(.failure(CoreDataStorageError.fetchFailed(error.localizedDescription)))
            }
        }
    }
}

// MARK: - WritableCoreDataStore (implementation)
extension CoreDataStorageImpl: WritableCoreDataStore {
    typealias Writable = T
    
    func saveInBackground(completionQueue: DispatchQueue,
                          block: @escaping (NSManagedObjectContext) throws -> Void,
                          completion: @escaping (Result<Void, any Error>) -> Void) {
        contextProvider.performBackgroundTask(
            block: block,
            receiveCompletionOn: completionQueue,
            completion: completion
        )
    }
    
    func deleteEntityInBackground(
        _ primaryKey: String,
        completionQueue: DispatchQueue = .main,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        contextProvider.performBackgroundTask(block: { context in
            let predicate = NSPredicate(format: "%K =[c] %@", T.primaryKeyName, primaryKey)
            
            let request = NSFetchRequest<T>(entityName: Self.entityName)
            request.predicate = predicate
            request.fetchLimit = 1
            request.returnsObjectsAsFaults = false
            
            do {
                if let entityToDelete = try context.fetch(request).first {
                    context.delete(entityToDelete)
                }
            } catch {
                throw CoreDataStorageError.fetchFailed(error.localizedDescription)
            }
        }, receiveCompletionOn: completionQueue, completion: { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                if let storageError = error as? CoreDataStorageError {
                    completion(.failure(storageError))
                } else {
                    completion(.failure(CoreDataStorageError.saveFailed(error.localizedDescription)))
                }
            }
        })
    }

}

