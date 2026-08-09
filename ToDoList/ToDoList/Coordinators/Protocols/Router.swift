//
//  Router.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 07.08.2026.
//

import Foundation

// MARK: - Core Router Protocol
protocol Router: AnyObject {
    
    associatedtype RouteAction
    
    var onRouteAction: ((RouteAction) -> Void)? { get set }
}
