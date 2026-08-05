//
//  ReadableCoreDataStore.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 30.07.2026.
//

import CoreData

protocol ReadableCoreDataStore<Storable> {
    associatedtype Storable: NSManagedObject
    
    // Метод с контекстом по умолчанию (viewContext)
    func fetchEntities(
        _ fetchOptions: FetchOptions,
        completion: @escaping (Result<[Storable], Error>) -> Void
    )
}


