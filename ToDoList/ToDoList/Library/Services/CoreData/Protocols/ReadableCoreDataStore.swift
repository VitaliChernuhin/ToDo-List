//
//  ReadableCoreDataStore.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 30.07.2026.
//

import CoreData

protocol ReadableCoreDataStore {

    associatedtype Storable: NSManagedObject
    
    func entities(_ fetchOptions: FetchOptions, in context: NSManagedObjectContext) -> [Storable]
    
    func entity(_ primaryKey: String, in context: NSManagedObjectContext) -> Storable?

    func entities(_ fetchOptions: FetchOptions) -> [Storable]
    
    func entity(_ primaryKey: String) -> Storable?
}

