//
//  FetchOptions.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 30.07.2026.
//

import Foundation
import CoreData

public enum FetchOptions {
    case all
    case filtered(predicate: NSPredicate)
    case sorted(sortDescriptors: [NSSortDescriptor])
    case filteredAndSorted(predicate: NSPredicate, sortDescriptors: [NSSortDescriptor])
}
