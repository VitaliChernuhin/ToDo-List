//
//  DateFormatterProvider.swift
//  ToDoList
//
//  Created by Vit Chernuhin on 03.08.2026.
//

import Foundation

enum CustomDateFormat {
    case shortUIDate      // дд/мм/гг под дизайн таблицы
    case shortServerDate  // дд/мм/гг под серверную неизвестную модель, просто заготовка
}

enum DateFormatterProvider {
    
    private static let uiShortFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        return formatter
    }()
    
    private static let serverShortFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        formatter.locale = Locale(identifier: "en_US_POSIX") // Защита сервера от региона телефона
        return formatter
    }()
    
    static func formatter(for format: CustomDateFormat) -> DateFormatter {
        switch format {
        case .shortUIDate:
            return uiShortFormatter
        case .shortServerDate:
            return serverShortFormatter
        }
    }
}
