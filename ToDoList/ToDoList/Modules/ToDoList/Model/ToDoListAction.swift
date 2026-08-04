//
//  ToDoListAction.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 04.08.2026.
//

enum ToDoListAction {
    case didTapCheckbox(item: ToDoItemViewModel)
    case didUpdateSearchQuery(query: String)
    case didSwipeToDelete(item: ToDoItemViewModel)
}
