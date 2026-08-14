//
//  ToDoListItem.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 03.08.2026.
//

import Foundation

struct ToDoItem: Sendable, Hashable {
    let id: Int64
    let title: String
    let description: String
    let date: Date
    let isCompleted: Bool
    
    init(id: Int64, title: String, description: String, date: Date, isCompleted: Bool) {
        self.id = id
        self.title = title
        self.description = description
        self.date = date
        self.isCompleted = isCompleted
    }
    
    func toString() -> String {
        return """
        📋 Задача: \(self.title)
        📝 Описание: \(self.description)
        📅 Дата: \(DateFormatterProvider.formatter(for: .shortUIDate).string(from: self.date))
        ✅ Статус: \(self.isCompleted ? "Выполнено" : "В работе")
        """
    }
}
