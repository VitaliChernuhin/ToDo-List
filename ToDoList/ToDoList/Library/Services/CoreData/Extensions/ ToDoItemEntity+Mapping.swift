//
//  ToDoItemEntity+Mapping.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 30.07.2026.
//

import CoreData

extension ToDoItemEntity {
    
    func toViewModel() -> ToDoItemViewModel {
        return ToDoItemViewModel(
            id: self.id,
            title: self.title ?? "",
            description: self.taskDescription ?? "",
            dateString: self.date ?? "",
            isCompleted: self.isCompleted
        )
    }
}
