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
    
    private var cachedTasks: [ToDoItem] = []
    
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
    
    // MARK: - ToDoListInteractor (implementation)
    
    func fetchTasks() {
        if settingsStorage.settings.isFirstInitializedFromServer {
            fetchLocalTasks()
        } else {
            fetchDataFromNetwork()
        }
    }
    
    func toggleTaskCompletion(id: Int64) {
        guard let index = cachedTasks.firstIndex(where: { $0.id == id }) else {
            log(message: "⚠️ Задача с id \(id) не найдена в кэше памяти для мутации флага")
            return
        }
        
        let targetTask = cachedTasks[index]
        let updatedTask = ToDoItem(
            id: targetTask.id,
            title: targetTask.title,
            description: targetTask.description,
            date: targetTask.date,
            isCompleted: !targetTask.isCompleted
        )
        
        cachedTasks[index] = updatedTask
        
        storage.saveTask(updatedTask) { [weak self] saveResult in
            guard let self = self else { return }
            
            switch saveResult {
            case .success:
                self.presenter?.didUpdateTasksState(with: .success(self.cachedTasks))
                
            case .failure(let error):
                self.log(message: "🛑 [Interactor] Ошибка записи инвертированного статуса на диск: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Private methods
private extension ToDoListInteractorImpl {
    
    func fetchLocalTasks() {
        storage.fetchAllTasks { [weak self] result in
            guard let self = self else { return }
            if case .success(let localItems) = result {
                self.cachedTasks = localItems
            }
            self.presenter?.didUpdateTasksState(with: result)
        }
    }
    
    func fetchDataFromNetwork() {
        networkService.fetchServerTodos { [weak self] networkResult in
            guard let self = self else { return }
            
            switch networkResult {
            case .success(let serverItems):
                
                self.cachedTasks = serverItems
                self.saveServerItemsToLocalStorage(serverItems)
                
                var currentSettings = self.settingsStorage.settings
                currentSettings.isFirstInitializedFromServer = true
                self.settingsStorage.settings = currentSettings
                
                self.presenter?.didUpdateTasksState(with: .success(serverItems))
                
            case .failure(let networkError):
                self.presenter?.didUpdateTasksState(with: .failure(networkError))
            }
        }
    }
    
    func saveServerItemsToLocalStorage(_ items: [ToDoItem]) {
        for item in items {
            storage.saveTask(item) { [weak self] result in
                if case .failure(let error) = result {
                    self?.log(message: "🛑 Ошибка фонового кэширования задачи \(item.id): \(error.localizedDescription)")
                }
            }
        }
    }
}
