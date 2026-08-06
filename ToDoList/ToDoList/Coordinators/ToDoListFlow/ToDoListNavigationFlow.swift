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

extension ToDoListNavigationFlow: Equatable {
    
    static func == (lhs: ToDoListNavigationFlow, rhs: ToDoListNavigationFlow) -> Bool {
        switch (lhs, rhs) {
        case (.ToDoList, .ToDoList):
            return true
            
        case let (.ToDoItemMenu(lhsItem), .ToDoItemMenu(rhsItem)):
            return lhsItem.id == rhsItem.id
            
        case let (.EditToDoItem(lhsItem), .EditToDoItem(rhsItem)):
            return lhsItem.id == rhsItem.id
            
        case (.NewToDoItem, .NewToDoItem):
            return true
            
        case let (.error(lhsDesc), .error(rhsDesc)):
            return lhsDesc == rhsDesc
            
        default:
            return false
        }
    }
}
