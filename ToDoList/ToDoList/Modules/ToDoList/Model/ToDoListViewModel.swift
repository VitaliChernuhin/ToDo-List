//
//  ToDoListViewModel.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 28.07.2026.
//

import Foundation

// MARK: - Секции для Diffable Data Source
nonisolated enum ToDoListSection: Hashable, Sendable {
    case main
}

// MARK: - Модель отображения задачи (ViewModel ячейки)
nonisolated struct ToDoItemViewModel: Hashable, Sendable {
    let id: Int64
    let title: String
    let description: String
    let dateString: String
    let isCompleted: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(isCompleted)
    }
    
    static func == (lhs: ToDoItemViewModel, rhs: ToDoItemViewModel) -> Bool {
        return lhs.id == rhs.id && lhs.isCompleted == rhs.isCompleted
    }
}
