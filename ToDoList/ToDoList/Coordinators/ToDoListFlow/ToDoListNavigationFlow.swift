//
//  ToDoListNavigationFlow.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 06.08.2026.
//

enum ToDoListNavigationFlow {
    case toDoList
    case toDoItemMenu(item: ToDoItem)
    case share(item: ToDoItem)
    case editToDoItem(item: ToDoItem)
    case newToDoItem
    case error(description: String)
}

extension ToDoListNavigationFlow: Equatable {
    
    static func == (lhs: ToDoListNavigationFlow, rhs: ToDoListNavigationFlow) -> Bool {
        switch (lhs, rhs) {
        case (.toDoList, .toDoList):
            return true
            
        case let (.toDoItemMenu(lhsItem), .toDoItemMenu(rhsItem)):
            return lhsItem.id == rhsItem.id
            
        case let (.editToDoItem(lhsItem), .editToDoItem(rhsItem)):
            return lhsItem.id == rhsItem.id
            
        case (.newToDoItem, .newToDoItem):
            return true
            
        case let (.error(lhsDesc), .error(rhsDesc)):
            return lhsDesc == rhsDesc
            
        case let (.share(lhsDesc), .share(item: rhsDesc)):
            return lhsDesc == rhsDesc
            
        default:
            return false
        }
    }
}
