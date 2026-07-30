//
//  IdentifiableManagedObject.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 30.07.2026.
//

protocol IdentifiableManagedObject {
    static var primaryKeyName: String { get }
}
