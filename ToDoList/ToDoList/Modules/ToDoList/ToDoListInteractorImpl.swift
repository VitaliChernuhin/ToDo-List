//
//  ToDoListInteractorImpl.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 03.08.2026.
//

import Foundation

final class ToDoListInteractorImpl: ToDoListInteractor {
    
    // MARK: - VIPER Ссылки
    weak var presenter: ToDoListInteractorOutput?
    
    // MARK: - Private properties
    private let storage: ToDoListStorage
    
    // MARK: - Init
    init(storage: ToDoListStorage) {
        self.storage = storage
    }
    
    // MARK: - ToDoListInteractor Realization
    
    func fetchTasks() {
        storage.fetchAllTasks { [weak self] result in
            self?.presenter?.didFetchTasks(with: result)
        }
    }
}
