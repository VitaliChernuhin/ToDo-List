//
//  WritableCoreDataStore.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 30.07.2026.
//

import CoreData

protocol WritableCoreDataStore<Writable> {
    associatedtype Writable: NSManagedObject
    
    func saveInBackground(
        completionQueue: DispatchQueue,
        block: @escaping (_ context: NSManagedObjectContext) -> Void,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    
    func deleteInBackground(
        _ entity: Writable,
        completionQueue: DispatchQueue,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    
    func deleteInBackground(
        _ entities: [Writable],
        completionQueue: DispatchQueue,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    
    func deleteAllInBackground(
        completionQueue: DispatchQueue,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    
    // MARK: - Низкоуровневые кирпичики внутри конкретного контекста
    
    func save(in context: NSManagedObjectContext) throws
    func delete(_ entity: Writable, in context: NSManagedObjectContext)
    func delete(_ entities: [Writable], in context: NSManagedObjectContext)
    func deleteAll(in context: NSManagedObjectContext) throws
}
