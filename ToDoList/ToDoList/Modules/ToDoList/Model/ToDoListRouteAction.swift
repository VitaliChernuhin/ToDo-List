//
//  ToDoListRouteAction.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 07.08.2026.
//

import Foundation
import CoreGraphics

// MARK: - ToDoListRouteAction
/// Пачка строго типизированных навигационных команд, вылетающих из Роутера на уровень Координатора потока.
enum ToDoListRouteAction {
    /// Показ кастомного меню из конкретной геометрической точки (нашей ячейки) экрана
    case openItemMenu(item: ToDoItem, rect: CGRect)
    
    /// Переход на экран редактирования существующей задачи
    case openEditScreen(item: ToDoItem)
    
    /// Переход на экран создания абсолютно новой задачи
    case openCreateScreen
    
    /// Триггер глобального алерта ошибки на самом верхнем слое приложения
    case triggerErrorAlert(message: String)
    
    case dismisseItemMenu
    
    case share(item: ToDoItem)
}
