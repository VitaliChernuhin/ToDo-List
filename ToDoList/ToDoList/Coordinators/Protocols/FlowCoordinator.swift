//
//  FlowCoordinator.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 06.08.2026.
//

import Foundation

protocol FlowCoordinator: AnyObject {
    
    associatedtype Flow: Equatable
    
    var currentFlow: Flow { get }
    func start()
}
