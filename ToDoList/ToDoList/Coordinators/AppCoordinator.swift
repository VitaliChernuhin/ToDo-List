//
//  AppCoordinator.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 06.08.2026.
//


import UIKit
import Swinject

final class AppCoordinator {
    
    private let window: UIWindow
    private let container: Container
    
    private var childCoordinator: ToDoListCoordinator?
    
    init(window: UIWindow, container: Container) {
        self.window = window
        self.container = container
    }
    
    func start() {
        let rootNavigationController = UINavigationController()
        let todoCoordinator = ToDoListCoordinator(
            navigationController: rootNavigationController,
            container: container
        )
        self.childCoordinator = todoCoordinator
        todoCoordinator.start()
    
        window.rootViewController = rootNavigationController
        window.makeKeyAndVisible()
    }
}

