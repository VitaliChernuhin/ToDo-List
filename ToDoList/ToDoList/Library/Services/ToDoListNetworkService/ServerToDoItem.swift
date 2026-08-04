//
//  ServerToDoItem.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 03.08.2026.
//

import Foundation

struct ServerToDoItem: Decodable, Sendable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
    
    let description: String?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case todo
        case completed
        case userId
        case description
        case createdAt = "created_at"
    }
}

extension ServerToDoItem {
    func toDomain() -> ToDoItem {
        let dateFormatter = DateFormatterProvider.formatter(for: .shortServerDate)
        let parsedDate = dateFormatter.date(from: createdAt ?? "") ?? Date()
        
        return ToDoItem(
            id: Int64(self.id),
            title: self.todo,
            description: self.description ?? "Описание отсутствует",
            date: parsedDate,
            isCompleted: self.completed
        )
    }
}


