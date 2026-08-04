//
//  Settings.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 03.08.2026.
//

struct Settings: Codable, Sendable {
    var isFirstInitializedFromServer: Bool
    
    /// Дефолтное состояние настроек при самом первом старте приложения
    static var defaultSettings: Settings {
        Settings(isFirstInitializedFromServer: false)
    }
}
