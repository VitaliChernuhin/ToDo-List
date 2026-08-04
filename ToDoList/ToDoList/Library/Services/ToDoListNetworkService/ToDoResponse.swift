//
//  ToDoResponse.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 03.08.2026.
//

import Foundation

struct ToDoResponse: Decodable, Sendable {
    let todos: [ServerToDoItem]
    let total: Int
    let skip: Int
    let limit: Int
}
