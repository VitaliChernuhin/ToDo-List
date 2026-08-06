//
//  ToDoListNavigationFlow.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 06.08.2026.
//

enum ToDoListNavigationFlow {
    case ToDoList
    case ToDoItemMenu(item: ToDoItem)
    case EditToDoItem(item: ToDoItem)
    case NewToDoItem
    case error(description: String)
}
