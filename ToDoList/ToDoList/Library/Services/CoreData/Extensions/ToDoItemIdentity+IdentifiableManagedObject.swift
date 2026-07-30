//
//  ToDoItemIdentity+IdentifiableManagedObject.swift.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 30.07.2026.
//

extension ToDoItemEntity: IdentifiableManagedObject {
    static var primaryKeyName: String { "id" }
}
