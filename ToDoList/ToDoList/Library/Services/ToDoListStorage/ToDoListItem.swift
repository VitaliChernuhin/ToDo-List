//
//  ToDoListItem.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 03.08.2026.
//

import Foundation

public struct ToDoItem: Sendable, Hashable {
    public let id: Int64
    public let title: String
    public let description: String
    public let date: Date
    public let isCompleted: Bool
    
    public init(id: Int64, title: String, description: String, date: Date, isCompleted: Bool) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.isCompleted = isCompleted
    }
}
