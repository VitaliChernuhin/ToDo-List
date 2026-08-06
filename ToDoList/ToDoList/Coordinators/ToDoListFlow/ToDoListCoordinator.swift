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
    
    init(navigationController: UINavigationController, container: Container) {
        self.navigationController = navigationController
        self.container = container
    }
    
    func start() {
        let taskListVC = container.resolve(ToDoListViewController.self)!
        navigationController.pushViewController(taskListVC, animated: false)
        currentFlow = .ToDoList
    }
}
