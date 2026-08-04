//
//  ToDoAPI.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 03.08.2026.
//

import Foundation
import Moya
import Alamofire

enum ToDoAPI {
    case fetchTodos(limit: Int, skip: Int)
}

extension ToDoAPI: TargetType {
    
    var baseURL: URL {
//         guard let url = URL(string: "https://nextcloud.effective-mobile.ru") else {
        guard let url = URL(string: "https://dummyjson.com") else {
             fatalError("Некорректный базовый URL")
         }
         return url
     }
     
     var path: String {
         switch self {
         case .fetchTodos:
//             return "/s/sq3YwmeQEQcoHoc/download/todos.json"
             return "/todos"
         }
     }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Moya.Task {
        switch self {
        case let .fetchTodos(limit, skip):
            let parameters: [String: Any] = [
                "limit": limit,
                "skip": skip
            ]
            return .requestParameters(parameters: parameters,
                                      encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
    
    var sampleData: Data {
        switch self {
        case .fetchTodos:
            let mockJSON = """
            {
                "todos": [
                    {
                        "id": 1,
                        "todo": "Купить свежий кофе для Виталия",
                        "completed": false,
                        "userId": 42,
                        "description": "Зайти в кофейню возле бункера и взять зерна",
                        "created_at": "02/10/24"
                    }
                ],
                "total": 1,
                "skip": 0,
                "limit": 1
            }
            """
            return mockJSON.data(using: .utf8) ?? Data()
        }
    }
}
