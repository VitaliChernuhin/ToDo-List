//
//  ServicesAssembly.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 03.08.2026.
//

import Foundation
import Swinject

final class ServicesAssembly: Assembly, Logable {
    
    func assemble(container: Container) {
        
        container.register(CoreDataContextProvider.self) { _ in
            let provider: CoreDataContextProvider = CoreDataContextProviderImpl(containerName: "ToDoList")
            
            provider.initialize { [weak self] result in
                switch result {
                case .success:
                    self?.log(message: "🏁 Стек Core Data успешно проинициализирован Swinject!")
                case .failure(let error):
                    self?.log(message: "🛑 Критическая ошибка старта базы данных: \(error.localizedDescription)")
                }
            }
            return provider
        }.inObjectScope(.container)
        
        container.register((any CoreDataStorage<ToDoItemEntity>).self) { resolver in
            let provider = resolver.resolve(CoreDataContextProvider.self)!
            return CoreDataStorageImpl<ToDoItemEntity>(contextProvider: provider)
        }.inObjectScope(.container)
        
        container.register(ToDoListStorage.self) { resolver in
            let coreDataStorage = resolver.resolve((any CoreDataStorage<ToDoItemEntity>).self)!
            return ToDoListStorageImpl(coreDataStorage: coreDataStorage)
        }
    }
}
