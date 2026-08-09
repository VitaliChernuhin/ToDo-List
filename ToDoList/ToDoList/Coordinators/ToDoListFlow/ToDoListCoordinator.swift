//
//  ToDoListCoordinator.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 06.08.2026.
//

import UIKit
import Swinject

final class ToDoListCoordinator: NSObject, FlowCoordinator {
    
    private let navigationController: UINavigationController
    private let container: Container
    
    private(set) var currentFlow: ToDoListNavigationFlow = .ToDoList
    
    // Приватное свойство для временного удержания координат ячейки (нужно для Аниматора)
    private var sourceCellRect: CGRect = .zero
    
    init(navigationController: UINavigationController, container: Container) {
        self.navigationController = navigationController
        self.container = container
    }
    
    func start() {
        let taskListVC = container.resolve(ToDoListViewController.self)!
        navigationController.pushViewController(taskListVC, animated: false)
        currentFlow = .ToDoList
        
        // Configurate route
        let taskListRouter = container.resolve((any ToDoListRouter).self)!
        taskListRouter.onRouteAction = { [weak self] action in
            switch action {
                
            case .openCreateScreen:
                break
                
            case .openEditScreen(item: let toDoItem):
                break
                
            case .openItemMenu(item: let toDoItem, rect: let rect):
                self?.openItemMenu(for: toDoItem, rect: rect, router: taskListRouter)
                
            case .triggerErrorAlert(message: let message):
                break
            }
        }
    }
}

// MARK: - Private Navigation Cascade (private)
private extension ToDoListCoordinator {
    
    /// Конфигурирует оверлей, замыкает UDF-каналы кнопок меню и презентует кастомный экран меню
    func openItemMenu(for toDoItem: ToDoItem, rect: CGRect, router: any ToDoListRouter) {
        
        currentFlow = .ToDoItemMenu(item: toDoItem)
        sourceCellRect = rect
        
        let menuVC = container.resolve(ToDoItemMenuViewController.self)!

        menuVC.toDoItem = toDoItem
//        menuVC.transitioningDelegate = self

        // Накатываем данные на саму карточку перед показом
        menuVC.toDoItemView.configure(with: toDoItem)

        navigationController.present(menuVC, animated: true)

    }
}
