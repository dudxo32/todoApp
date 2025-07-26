//
//  TodoError.swift
//  todoApp
//
//  Created by 조영태 on 7/19/25.
//

import Foundation
import Shared

extension AppError {
    @frozen
    public enum Todo: Error {
        case notFound
        
        var localizedDescription: String {
            switch self {
            case .notFound:
                return I18N.todoNotFound
            }
        }
    }
}
