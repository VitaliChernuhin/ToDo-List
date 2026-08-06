//
//  AppCoordinator.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 06.08.2026.
//

import UIKit
import Swinject

final class AppCoordinator<Child: FlowCoordinator> {
    
    private let window: UIWindow
    private let container: Container
    
    private(set) var childCoordinator: Child?
    
    init(window: UIWindow, container: Container) {
        self.window = window
        self.container = container
    }
    
    func start() {
        let rootNavigationController = UINavigationController()
        
        if let todoCoordinator = container.resolve(Child.self, argument: rootNavigationController) {
            self.childCoordinator = todoCoordinator
            todoCoordinator.start()
        }
        
        window.rootViewController = rootNavigationController
        window.makeKeyAndVisible()
    }
}

// Пример того, как можно использовать обработку, к примеру DeepLink
private extension AppCoordinator where Child: ToDoListCoordinator {
    
    func handleIncomingDeepLink(_ url: URL) {
        // Компилятор ЖЕСТКО знает, что у childCoordinator энум — это ToDoListNavigationFlow!
        guard let currentFlowState = childCoordinator?.currentFlow else { return }
        
        switch currentFlowState {
        case .ToDoItemMenu(let item):
            print("📲 Обрабатываем диплинк \(url) для открытого меню задачи: \(item.title)")
            // Вызываем специфичные методы ToDoListCoordinator
            
        case .EditToDoItem(let item):
            print("📲 Юзер уже редактирует задачу \(item.id), обновляем контент диплинком")
            
        case .ToDoList, .NewToDoItem, .error:
            print("📲 Базовое состояние флоу задач, уводим на нужный экран")
        }
    }
}

// MARK: - Get topViewController (private)
private extension AppCoordinator {
    func getTopViewController(from root: UIViewController?) -> UIViewController? {
        if let presented = root?.presentedViewController {
            return getTopViewController(from: presented)
        }
        if let nav = root as? UINavigationController {
            return getTopViewController(from: nav.visibleViewController)
        }
        if let tab = root as? UITabBarController {
            return getTopViewController(from: tab.selectedViewController)
        }
        return root
    }
}
