//
//  Logable.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 28.07.2026.
//

import Foundation

protocol Logable {
    func log(message: String)
}

extension Logable {
    func log(message: String) {
        let className = String(describing: type(of: self))
        print("➡️ [\(className)]: \(message)")
    }
}
