//
//  ToDoListNetworkService.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 03.08.2026.
//

import Foundation
import Moya

// MARK: - Сетевые ошибки
enum NetworkError: Error, LocalizedError {
    case noInternet             // Ошибка отсутствия сети (код -1009)
    case serverError(Int)       // Ошибки сервера (404, 500, 502 и т.д.)
    case decodingError          // Ошибка парсинга кривого JSON
    case unknown(String)        // Все остальные непредвиденные случаи
    
    var errorDescription: String? {
        switch self {
        case .noInternet:
            return "Отсутствует подключение к интернету. Проверьте сеть."
        case .serverError(let code):
            return "Ошибка сервера (\(code)). Повторите попытку позже."
        case .decodingError:
            return "Не удалось обработать данные от сервера."
        case .unknown(let message):
            return "Произошла непредвиденная ошибка: \(message)"
        }
    }
}

// MARK: - Сетевой контракт
protocol ToDoListNetworkService: AnyObject {
    func fetchServerTodos(
        limit: Int,
        skip: Int,
        completion: @escaping (Result<[ToDoItem], Error>) -> Void
    )
}

extension ToDoListNetworkService {
    func fetchServerTodos(
        limit: Int = 30, // По умолчанию качаем первые 30 штук, как на сервере
        skip: Int = 0,
        completion: @escaping (Result<[ToDoItem], Error>) -> Void
    ) {
        fetchServerTodos(limit: limit, skip: skip, completion: completion)
    }
}

// MARK: - Реализация сетевого сервиса через Moya
final class ToDoListNetworkServiceImpl: ToDoListNetworkService {
    
    private let provider: MoyaProvider<ToDoAPI>
    
    init(provider: MoyaProvider<ToDoAPI>? = nil) {
        if let customProvider = provider {
            self.provider = customProvider
        } else {
            let backgroundQueue = DispatchQueue(
                label: "com.todolist.network.queue",
                qos: .userInitiated,
                attributes: .concurrent
            )
            self.provider = MoyaProvider<ToDoAPI>(callbackQueue: backgroundQueue)
        }
    }
    
    // MARK: - ToDoListNetworkService implementation
    func fetchServerTodos(
            limit: Int,
            skip: Int,
            completion: @escaping (Result<[ToDoItem], Error>) -> Void
        ) {
        
        provider.request(.fetchTodos(limit: limit, skip: skip)) { result in
            switch result {
            case .success(let response):
                // 1. Проверяем статус-код (200-299)
                guard (200...299).contains(response.statusCode) else {
                    completion(.failure(NetworkError.serverError(response.statusCode)))
                    return
                }
                
                // 2. Декодируем и маппим в легкие DTO структуры Домена
                do {
                    let serverResponse = try JSONDecoder().decode(ToDoResponse.self, from: response.data)
                    let domainItems = serverResponse.todos.map { $0.toDomain() }
                    completion(.success(domainItems))
                } catch {
                    completion(.failure(NetworkError.decodingError))
                }
                
            case .failure(let moyaError):
                switch moyaError {
                case .underlying(let error as NSError, _):
                    // Проверяем классический iOS-код отсутствия сети (-1009)
                    if error.code == NSURLErrorNotConnectedToInternet || error.domain == NSURLErrorDomain {
                        completion(.failure(NetworkError.noInternet))
                    } else {
                        completion(.failure(NetworkError.unknown(error.localizedDescription)))
                    }
                default:
                    // Все остальные внутренние ошибки Moya (ошибки маппинга хэдеров и т.д.)
                    completion(.failure(NetworkError.unknown(moyaError.localizedDescription)))
                }
            }
        }
    }
}
