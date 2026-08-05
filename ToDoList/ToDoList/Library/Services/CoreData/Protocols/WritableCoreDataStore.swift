//
//  WritableCoreDataStore.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 30.07.2026.
//

import CoreData

protocol WritableCoreDataStore {
    associatedtype Writable
    
    func saveInBackground(
        completionQueue: DispatchQueue,
        block: @escaping (_ context: NSManagedObjectContext) throws -> Void,
        completion: @escaping (Result<Void, Error>) -> Void
    )
    
    func deleteEntityInBackground(
        _ primaryKey: String,
        completionQueue: DispatchQueue,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}
