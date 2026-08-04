//
//  SettingsStorage.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 03.08.2026.
//

import Foundation

protocol SettingsStorage: AnyObject {
    var settings: Settings { get set }
}

final class SettingsStorageImpl: SettingsStorage {
    
    private let userDefaults: UserDefaults
    private let settingsKey = "com.todolist.appsettings.globalConfig"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    // MARK: - SettingsStorage (implementaion)
    var settings: Settings {
        get {
            guard let data = userDefaults.data(forKey: settingsKey),
                  let decoded = try? JSONDecoder().decode(Settings.self, from: data) else {
                return .defaultSettings
            }
            return decoded
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                userDefaults.set(encoded, forKey: settingsKey)
            }
        }
    }
}
