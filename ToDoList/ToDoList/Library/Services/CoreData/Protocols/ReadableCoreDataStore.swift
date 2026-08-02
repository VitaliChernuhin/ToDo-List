//
//  ReadableCoreDataStore.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 30.07.2026.
//

import CoreData

protocol ReadableCoreDataStore {
    associatedtype Storable: NSManagedObject
    
    func fetchEntities(
        _ fetchOptions: FetchOptions,
        in context: NSManagedObjectContext,
        completion: @escaping (Result<[Storable], Error>) -> Void
    )
    
    func fetchEntity(
        _ primaryKey: String,
        in context: NSManagedObjectContext,
        completion: @escaping (Result<Storable?, Error>) -> Void
    )
    
    // Методы с контекстом по умолчанию (viewContext)
    func fetchEntities(
        _ fetchOptions: FetchOptions,
        completion: @escaping (Result<[Storable], Error>) -> Void
    )
    
    func fetchEntity(
        _ primaryKey: String,
        completion: @escaping (Result<Storable?, Error>) -> Void
    )
    
    // Методы с backgroundContext
    func fetchEntitiesInBackground(
        _ fetchOptions: FetchOptions,
        completionQueue: DispatchQueue,
        completion: @escaping (Result<[Storable], Error>) -> Void
    )

    func fetchEntityInBackground(
        _ primaryKey: String,
        completionQueue: DispatchQueue,
        completion: @escaping (Result<Storable?, Error>) -> Void
    )
}


