//
//  NSManagedObjectContext+saveOrRollback.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 30.07.2026.
//

import Foundation
import CoreData

extension NSManagedObjectContext {
    @discardableResult
    public func saveOrRollback() -> Bool {
        do {
            try save()
            return true
        } catch {
            print("CoreData saving error: \(error)")
            rollback()
            return false
        }
    }
    
    func performChanges(block: @escaping () -> Void) {
        performAndWait {
            block()
        }
    }
}
