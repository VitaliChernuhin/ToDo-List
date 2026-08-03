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
    case entityNotFound(String)
    case saveFailed(String)
    case unknownError(String)
    
    public var errorDescription: String? {
        switch self {
        case .contextNotAvailable:
            return "Контекст Core Data недоступен"
        case .fetchFailed(let message):
            return "Ошибка при выполнении запроса: \(message)"
        case .entityNotFound(let entityName):
            return "Сущность не найдена: \(entityName)"
        case .saveFailed(let message):
            return "Ошибка сохранения данных: \(message)"
        case .unknownError(let message):
            return "Неизвестная ошибка: \(message)"
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
    
    func fetchEntities(
        _ fetchOptions: FetchOptions,
        in context: NSManagedObjectContext,
        completion: @escaping (Result<[T], Error>) -> Void
    ) {
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
    
    func fetchEntities(_ fetchOptions: FetchOptions, completion: @escaping (Result<[T], any Error>) -> Void) {
        guard let context = self.contextProvider.viewContext else {
            completion(.failure(CoreDataStorageError.contextNotAvailable))
            return
        }
        fetchEntities(fetchOptions, in: context, completion: completion)
    }
    
    func fetchEntity(
        _ primaryKey: String,
        in context: NSManagedObjectContext,
        completion: @escaping (Result<T?, Error>) -> Void
    ) {
        context.perform {
            let predicate = NSPredicate(
                format: "%K =[c] %@",
                T.primaryKeyName,
                primaryKey
            )
            
            let request = NSFetchRequest<T>(entityName: Self.entityName)
            request.predicate = predicate
            request.fetchLimit = 1
            request.returnsObjectsAsFaults = false
            
            do {
                let entities = try context.fetch(request)
                completion(.success(entities.first))
            } catch {
                completion(.failure(CoreDataStorageError.fetchFailed(error.localizedDescription)))
            }
        }
    }
    
    func fetchEntity(_ primaryKey: String, completion: @escaping (Result<T?, any Error>) -> Void) {
        guard let context = self.contextProvider.viewContext else {
            completion(.failure(CoreDataStorageError.contextNotAvailable))
            return
        }
        fetchEntity(primaryKey, in: context, completion: completion)
    }
    
    func fetchEntitiesInBackground(
        _ fetchOptions: FetchOptions,
        completionQueue: DispatchQueue = .main,
        completion: @escaping (Result<[T], Error>) -> Void
    ) {
        guard let backgroundContext = contextProvider.makeBackgroundContext() else {
            completionQueue.async { completion(.failure(CoreDataStorageError.contextNotAvailable)) }
            return
        }
        
        backgroundContext.perform { [weak self] in
            guard let self = self else { return }
            
            self.fetchEntities(fetchOptions, in: backgroundContext) { result in
                completionQueue.async {
                    completion(result)
                }
            }
        }
    }
    
    func fetchEntityInBackground(
        _ primaryKey: String,
        completionQueue: DispatchQueue = .main,
        completion: @escaping (Result<T?, Error>) -> Void
    ) {
        
        guard let backgroundContext = contextProvider.makeBackgroundContext() else {
            completionQueue.async { completion(.failure(CoreDataStorageError.contextNotAvailable)) }
            return
        }
        
        backgroundContext.perform { [weak self] in
            guard let self = self else { return }
            
            self.fetchEntity(primaryKey, in: backgroundContext) { result in
                completionQueue.async {
                    completion(result)
                }
            }
        }
    }
}

// MARK: - WritableCoreDataStore (implementation)
extension CoreDataStorageImpl: WritableCoreDataStore {
    typealias Writable = T
    
    func saveInBackground(
        completionQueue: DispatchQueue = .main,
        block: @escaping (_ context: NSManagedObjectContext) -> Void,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        contextProvider.performBackgroundTask(
            block: block,
            receiveCompletionOn: completionQueue,
            completion: completion
        )
    }
    
    func deleteInBackground(
        _ entity: T,
        completionQueue: DispatchQueue = .main,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let entityID = entity.objectID
        contextProvider.performBackgroundTask(block: { backgroundContext in
            if let backgroundEntity = backgroundContext.object(with: entityID) as? T {
                backgroundContext.delete(backgroundEntity)
            }
        }, receiveCompletionOn: completionQueue, completion: completion)
    }
    
    func deleteInBackground(
        _ entities: [T],
        completionQueue: DispatchQueue = .main,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let entityIDs = entities.map { $0.objectID }
        contextProvider.performBackgroundTask(block: { backgroundContext in
            for id in entityIDs {
                if let backgroundEntity = backgroundContext.object(with: id) as? T {
                    backgroundContext.delete(backgroundEntity)
                }
            }
        }, receiveCompletionOn: completionQueue, completion: completion)
    }
    
    func deleteAllInBackground(
        completionQueue: DispatchQueue = .main,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        contextProvider.performBackgroundTask(block: { [weak self] backgroundContext in
            guard let self = self else { return }
            do {
                try self.deleteAll(in: backgroundContext)
            } catch {
                completionQueue.async { completion(.failure(error)) }
            }
        }, receiveCompletionOn: completionQueue, completion: completion)
    }
    
    // MARK: - Низкоуровневые операции внутри конкретного контекста
    
    func save(in context: NSManagedObjectContext) throws {
        do {
            try context.save()
        } catch {
            context.rollback()
            throw CoreDataStorageError.saveFailed("Не удалось зафиксировать изменения в контексте")   }
    }
    
    func delete(_ entity: T, in context: NSManagedObjectContext) {
        context.delete(entity)
    }
    
    func delete(_ entities: [T], in context: NSManagedObjectContext) {
        for entity in entities {
            context.delete(entity)
        }
    }
    
    func deleteAll(in context: NSManagedObjectContext) throws {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Self.entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs
        
        if let result = try context.execute(deleteRequest) as? NSBatchDeleteResult,
           let objectIDs = result.result as? [NSManagedObjectID] {
            
            NSManagedObjectContext.mergeChanges(
                fromRemoteContextSave: [NSDeletedObjectsKey: objectIDs],
                into: [context]
            )
        }
    }
}

