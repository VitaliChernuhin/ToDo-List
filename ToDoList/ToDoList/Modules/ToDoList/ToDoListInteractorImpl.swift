//
//  ToDoListInteractorImpl.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 03.08.2026.
//

import Foundation

final class ToDoListInteractorImpl: ToDoListInteractor, Logable {
    
    // MARK: - VIPER Ссылки
    weak var presenter: ToDoListInteractorOutput?
    
    // MARK: - Private properties
    private let storage: ToDoListStorage
    private let networkService: ToDoListNetworkService
    private let settingsStorage: SettingsStorage
    
    // MARK: - Init
    init(
        storage: ToDoListStorage,
        networkService: ToDoListNetworkService,
        settingsStorage: SettingsStorage
    ) {
        self.storage = storage
        self.networkService = networkService
        self.settingsStorage = settingsStorage
    }
    
    // MARK: - ToDoListInteractor Realization
    
    func fetchTasks() {
        if settingsStorage.settings.isFirstInitializedFromServer {
            fetchLocalTasks()
        } else {
            fetchDataFromNetwork()
        }
    }
    
    // MARK: - Private Cascade Methods
    
    private func fetchLocalTasks() {
        storage.fetchAllTasks { [weak self] result in
            self?.presenter?.didFetchTasks(with: result)
        }
    }
    
    private func fetchDataFromNetwork() {

        networkService.fetchServerTodos { [weak self] networkResult in
            guard let self = self else { return }
            
            switch networkResult {
            case .success(let serverItems):

                self.saveServerItemsToLocalStorage(serverItems)
                
                var currentSettings = self.settingsStorage.settings
                currentSettings.isFirstInitializedFromServer = true
                self.settingsStorage.settings = currentSettings
                
                self.presenter?.didFetchTasks(with: .success(serverItems))
              
            case .failure(let networkError):
                self.presenter?.didFetchTasks(with: .failure(networkError))
            }
        }
    }
    
    private func saveServerItemsToLocalStorage(_ items: [ToDoItem]) {
        for item in items {
            storage.saveTask(item) { [weak self] result in
                if case .failure(let error) = result {
                    self?.log(message: "🛑 Ошибка фонового кэширования задачи \(item.id): \(error.localizedDescription)")
                }
            }
        }
    }
}
