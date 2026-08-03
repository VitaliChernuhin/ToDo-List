//
//  ToDoItemEntity+Mapping.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 30.07.2026.
//

import CoreData

extension ToDoItemEntity {
    func toDomain() -> ToDoItem {
        return ToDoItem(
            id: self.id,
            title: self.title ?? "",
            description: self.taskDescription ?? "",
            date: self.date ?? Date(),
            isCompleted: self.isCompleted
        )
    }
}

