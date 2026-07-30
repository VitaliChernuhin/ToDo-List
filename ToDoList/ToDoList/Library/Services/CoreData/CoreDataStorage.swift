//
//  CoreDataStorage.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 30.07.2026.
//

import Foundation
import CoreData

protocol CoreDataStorage: AnyObject, ReadableCoreDataStore, WritableCoreDataStore {}

final class CoreDataStorageImpl<T: NSManagedObject>: CoreDataStorage where T: IdentifiableManagedObject {
    
    // MARK: - Private properties
    private let contextProvider: CoreDataContextProvider
    
    init(contextProvider: CoreDataContextProvider) {
        self.contextProvider = contextProvider
    }
}

// MARK: - ReadableCoreDataStore (implementation)
extension CoreDataStorageImpl: ReadableCoreDataStore {
    typealias Storable = T
    
    func entities(_ fetchOptions: FetchOptions, in context: NSManagedObjectContext) -> [T] {
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
        
        switch fetchOptions {
        case let .filtered(predicate):
            fetchRequest.predicate = predicate
        case let .sorted(sortDescriptors):
            fetchRequest.sortDescriptors = sortDescriptors
        case let .filteredAndSorted(predicate, sortDescriptors):
            fetchRequest.predicate = predicate
            fetchRequest.sortDescriptors = sortDescriptors
        case .all:
            fetchRequest.sortDescriptors = []
        }
        
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.includesPropertyValues = true
        
        return (try? context.fetch(fetchRequest)) ?? []
    }
    
    func entities(_ fetchOptions: FetchOptions) -> [T] {
        entities(fetchOptions, in: contextProvider.viewContext)
    }
    
    func entity(_ primaryKey: String, in context: NSManagedObjectContext) -> T? {
        let predicate = primaryKeyPredicate(primaryKeyName: T.primaryKeyName, for: primaryKey)
        return findOrFetch(in: context, matching: predicate)
    }
    
    func entity(_ primaryKey: String) -> T? {
        entity(primaryKey, in: contextProvider.viewContext)
    }
}

// MARK: - WritableCoreDataStore (implementation)
extension CoreDataStorageImpl: WritableCoreDataStore {
    typealias Writable = T
    
    func delete(entity: T) {
        let context = contextProvider.viewContext
        context.performChanges {
            context.delete(entity)
        }
    }
    
    func delete(entities: [T]) {
        let context = contextProvider.viewContext
        context.performChanges {
            for entity in entities {
                context.delete(entity)
            }
        }
    }
    
    func deleteAll() {
        guard let fetchRequest = NSFetchRequest<T>(entityName: entityName) as? NSFetchRequest<NSFetchRequestResult> else {
            return
        }
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            _ = try contextProvider.viewContext.execute(deleteRequest)
        } catch {
            print("Core Data deleteAll error: \(error)")
        }
    }
    
    func deleteAll(in writableContext: NSManagedObjectContext) {
        deleteAllInContext(in: writableContext)
    }
    
    func delete(entity: T, in writableContext: NSManagedObjectContext) {
        writableContext.performChanges {
            writableContext.delete(entity)
        }
    }
    
    func delete(entities: [T], in writableContext: NSManagedObjectContext) {
        writableContext.performChanges {
            for entity in entities {
                writableContext.delete(entity)
            }
        }
    }
}

// MARK: -  Private methods
private extension CoreDataStorageImpl {
    
    var entityName: String {
        String(describing: T.self)
    }
    
    func primaryKeyPredicate(primaryKeyName: String, for identity: String) -> NSPredicate {
        return NSPredicate(format: "%K =[c] %@", primaryKeyName, identity)
    }
    
    func create(in context: NSManagedObjectContext, configure: (T) -> Void) -> T {
        guard let newObj: T = NSEntityDescription.insertNewObject(forEntityName: entityName, into: contextProvider.viewContext) as? T
        else { fatalError() }
        configure(newObj)
        return newObj
    }
    
    func fetch(in context: NSManagedObjectContext,
               configurationBlock: (NSFetchRequest<T>) -> Void = { _ in }
    ) -> [T] {
        
        let request = NSFetchRequest<T>(entityName: entityName)
        request.includesPropertyValues = true
        configurationBlock(request)
        
        return (try? context.fetch(request)) ?? []
    }
    
    func findOrFetch(in context: NSManagedObjectContext,
                     matching predicate: NSPredicate) -> T? {
        return fetch(in: context) { request in
            request.predicate = predicate
            request.returnsObjectsAsFaults = false
            request.fetchLimit = 1
        }.first
    }
    
    func deleteAllInContext(in context: NSManagedObjectContext) {
        guard let fetchRequest = NSFetchRequest<T>(entityName: entityName) as? NSFetchRequest<NSFetchRequestResult> else {
            return
        }
        
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            _ = try context.execute(deleteRequest)
        } catch {
            print("Core Data deleteAll error: \(error)")
        }
    }
}
