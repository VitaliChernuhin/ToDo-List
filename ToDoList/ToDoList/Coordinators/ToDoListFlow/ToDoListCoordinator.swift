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
    
    private(set) var currentFlow: ToDoListNavigationFlow = .toDoList
    
    init(navigationController: UINavigationController, container: Container) {
        self.navigationController = navigationController
        self.container = container
    }
    
    func start() {
        
        let taskListVC = container.resolve(ToDoListViewController.self)!
        navigationController.pushViewController(taskListVC, animated: false)
        currentFlow = .toDoList
        
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
                    
                case .share(item: let item):
                    guard let menuVC = self.menuItemViewController()
                    else { return }
                    
                    self.share(item: item, from: menuVC.sourceItemRect)
                    
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
        
        currentFlow = .toDoItemMenu(item: toDoItem)
        
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
            self.currentFlow = .toDoList
        }
    }
    
    func share(item: ToDoItem, from sourceRect: CGRect) {
        guard let menuVC = menuItemViewController()
        else {
            log(message: "⚠️ Не удалось найти ToDoItemMenuViewController для шаринга")
            return
        }

        let prevFlow = currentFlow
        currentFlow = .share(item: item)

        let text = item.toString()
        let activityViewController = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )

        if let popover = activityViewController.popoverPresentationController {
            popover.sourceRect = sourceRect
        }

        activityViewController.completionWithItemsHandler = { [weak self] activityType, completed, returnedItems, error in
            guard let self = self else { return }

            if let error = error {
                self.log(message: "❌ Ошибка шаринга: \(error.localizedDescription)")
                self.currentFlow = prevFlow
                return
            }

            if completed {
                self.log(message: "✅ Задача \(item.id) была поделена через \(String(describing: activityType))")
                self.currentFlow = prevFlow
                
                self.dismissItemMenu()
            } else {
                self.log(message: "🔙 Пользователь отменил шаринг")
                // Отмена: возвращаем в меню
                self.currentFlow = prevFlow
            }
        }
        menuVC.present(activityViewController, animated: true)
    }
}

// MARK: - ViewControllers methods (private)
private extension ToDoListCoordinator {
    func currentToDoListViewController() -> ToDoListViewController? {
        // Сначала проверяем, что сейчас вообще ожидаем этот экран по flow
        guard currentFlow == .toDoList else { return nil }
        
        return navigationController.viewControllers
            .first { $0 is ToDoListViewController }
            .flatMap { $0 as? ToDoListViewController }
    }
    
    func menuItemViewController() -> ToDoItemMenuViewController? {
        guard case .toDoItemMenu = currentFlow else { return nil }
        return navigationController.topViewController?.presentedViewController as? ToDoItemMenuViewController
    }
}

// MARK: - Top presented viewController (private)
private extension UIViewController {
    var topPresentedViewController: UIViewController? {
        var current = self
        while let presented = current.presentedViewController {
            current = presented
        }
        return current
    }
}

private extension ToDoListCoordinator {
    func topPresentingViewController() -> UIViewController? {
        return navigationController.topViewController?.topPresentedViewController
    }
}


