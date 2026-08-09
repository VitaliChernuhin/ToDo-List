//
//  ToDoListAssembly.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 28.07.2026.
//

import Swinject
import UIKit

final class ToDoListAssembly: Assembly {
    
    func assemble(container: Container) {
        
        // 1. Собираем Презентер
        container.register((any ToDoListPresenter).self) { _ in
            ToDoListPresenterImpl()
        }
        
        // 2. Собираем Интерактор
        container.register(ToDoListInteractor.self) { resolver in
            let storage = resolver.resolve(ToDoListStorage.self)!
            let networkService = resolver.resolve(ToDoListNetworkService.self)!
            let settingsStorage = resolver.resolve(SettingsStorage.self)!
            return ToDoListInteractorImpl(storage: storage, networkService: networkService, settingsStorage: settingsStorage)
        }
        
        // 3. Собираем Роутер
        container.register((any ToDoListRouter).self) { _ in
            ToDoListRouterImpl()
        }
        
        // 4. Собираем Вью-Контроллер, один в контейнере, т.к. нужен для проброски создания меню
        container.register(ToDoListViewController.self) { resolver in
            let viewController = ToDoListViewController()
            
            // Разрешаем зависимости через резолвер
            let presenter = resolver.resolve((any ToDoListPresenter).self)!
            let interactor = resolver.resolve(ToDoListInteractor.self)!
            let router = resolver.resolve((any ToDoListRouter).self)!
            
            // Прошиваем ссылки по контрактам
            viewController.presenter = presenter
            presenter.view = viewController
            presenter.interactor = interactor
            presenter.router = router
            interactor.presenter = presenter as? ToDoListInteractorOutput
            
            return viewController
        }.inObjectScope(.container)
        
        // 5. Собираем ViewController для меню
        container.register(ToDoItemMenuViewController.self) { resolver in
            let toDoItemMenuViewController = ToDoItemMenuViewController()
            
            return toDoItemMenuViewController
        }
    }
}
