//
//  NavigationFlowsAssembly.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 06.08.2026.
//


import Swinject
import UIKit

final class NavigationFlowsAssembly: Assembly {
    
    func assemble(container: Container) {
        
        container.register(AppCoordinator<ToDoListCoordinator>.self) { (resolver, window: UIWindow) in
            return AppCoordinator(
                window: window,
                container: container
            )
        }.inObjectScope(.container)
        
        container.register(ToDoListCoordinator.self) { (resolver, navigationController: UINavigationController) in
            return ToDoListCoordinator(
                navigationController: navigationController,
                container: container
            )
        }
    }
}
