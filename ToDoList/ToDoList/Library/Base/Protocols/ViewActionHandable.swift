//
//  ViewActionHandable.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 04.08.2026.
//

protocol ViewActionHandable: AnyObject {
    associatedtype Action
    
    func handleAction(_ action: Action)
}
