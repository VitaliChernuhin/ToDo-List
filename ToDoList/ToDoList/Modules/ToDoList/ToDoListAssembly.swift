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
        
        // 1. Регистрируем Interactor
        container.register(ToDoListInteractor.self) { _ in
            ToDoListInteractorImpl()
        }
        
        // 2. Регистрируем Router
        container.register(ToDoListRouter.self) { _ in
            ToDoListRouterImpl()
        }
        
        // 3. Регистрируем Presenter
        container.register(ToDoListPresenter.self) { resolver in
            let presenter = ToDoListPresenterImpl()
            presenter.interactor = resolver.resolve(ToDoListInteractor.self)
            presenter.router = resolver.resolve(ToDoListRouter.self)
            return presenter
        }
        
        // 4. Регистрируем View
        container.register(ToDoListViewController.self) { resolver in
            let viewController = ToDoListViewController()
            let presenter = resolver.resolve(ToDoListPresenter.self)!
            
            viewController.presenter = presenter
            presenter.view = viewController
            
            if let router = presenter.router as? ToDoListRouterImpl {
                router.viewController = viewController
            }
            
            if let interactor = presenter.interactor as? ToDoListInteractorImpl {
                interactor.presenter = presenter as? ToDoListInteractorOutput
            }
            
            return viewController
        }
    }
}

