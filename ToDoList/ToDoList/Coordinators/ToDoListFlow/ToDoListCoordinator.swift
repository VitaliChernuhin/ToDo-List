//
//  ToDoListCoordinator.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 06.08.2026.
//

import UIKit
import Swinject

final class ToDoListCoordinator: NSObject, FlowCoordinator, Logable {
    
    private let navigationController: UINavigationController
    private let container: Container
    
    private(set) var currentFlow: ToDoListNavigationFlow = .ToDoList
    
    init(navigationController: UINavigationController, container: Container) {
        self.navigationController = navigationController
        self.container = container
    }
    
    func start() {
        
        let taskListVC = container.resolve(ToDoListViewController.self)!
        navigationController.pushViewController(taskListVC, animated: false)
        currentFlow = .ToDoList
        
        if let presenter = taskListVC.presenter,
           let router = presenter.router {
            
            router.onRouteAction = { [weak self] action in
                guard let self = self else { return }
                switch action {
                case .openCreateScreen: break
                case .openEditScreen: break
                    
                case let .openItemMenu(toDoItem, rect):
                    self.openItemMenu(for: toDoItem, rect: rect)
                    
                case .dismisseItemMenu:
                    self.dismissItemMenu()
                    
                case .triggerErrorAlert:
                    break
                }
            }
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate (Движок Анимации)
extension ToDoListCoordinator: UIViewControllerTransitioningDelegate {
    
    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        guard let menuVC = presented as? ToDoItemMenuViewController
        else { return nil }
        log(message: "🚀 Запускаем кастомный ToDoMenuPresentAnimator для CGRect: \(menuVC.sourceItemRect)")
        return ToDoMenuPresentAnimator(sourceCellRect: menuVC.sourceItemRect)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let menuVC = dismissed as? ToDoItemMenuViewController
        else { return nil }
        return ToDoMenuDismissAnimator(sourceCellRect: menuVC.sourceItemRect)
    }
}

// MARK: - Private Navigation Cascade (private)
private extension ToDoListCoordinator {
    
    func openItemMenu(for toDoItem: ToDoItem, rect: CGRect) {
        guard let toDoListViewController = currentToDoListViewController()
        else { return }
        
        currentFlow = .ToDoItemMenu(item: toDoItem)
        
        let menuVC = container.resolve(ToDoItemMenuViewController.self)!
        menuVC.sourceItemRect = rect
        
        menuVC.onActionSelected = { menuAction in
            toDoListViewController.presenter?.handleAction(.didSelectMenuAction(action: menuAction))
        }
        
        menuVC.toDoItem = toDoItem
        menuVC.transitioningDelegate = self
        
        menuVC.toDoItemView.configure(with: toDoItem)
        
        navigationController.present(menuVC, animated: true)
    }
    
    func dismissItemMenu() {
        guard navigationController.presentedViewController != nil else {
            return
        }
        
        navigationController.presentedViewController?.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.currentFlow = .ToDoList
        }
    }
}

// MARK: - ViewControllers methods (private)
private extension ToDoListCoordinator {
    func currentToDoListViewController() -> ToDoListViewController? {
        // Сначала проверяем, что сейчас вообще ожидаем этот экран по flow
        guard currentFlow == .ToDoList else {
            return nil
        }
        
        return navigationController.viewControllers
            .first { $0 is ToDoListViewController }
            .flatMap { $0 as? ToDoListViewController }
    }
}
