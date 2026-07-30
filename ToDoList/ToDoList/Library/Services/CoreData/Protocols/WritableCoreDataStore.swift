//
//  WritableCoreDataStore.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 30.07.2026.
//

import CoreData
 
protocol WritableCoreDataStore {
    
    associatedtype Writable: NSManagedObject
    
    func delete(entity: Writable)
    func delete(entities: [Writable])
    func deleteAll()
    func deleteAll(in writableContext: NSManagedObjectContext)
    func delete(
        entity: Writable,
        in writableContext: NSManagedObjectContext
    )
    
    func delete(
        entities: [Writable],
        in writableContext: NSManagedObjectContext
    )
}
