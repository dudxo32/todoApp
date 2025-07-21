//
//  PresentationError.swift
//  todoApp
//
//  Created by 조영태 on 7/19/25.
//

import Foundation
import Domain
import Shared

enum AppError: Error {
    case serverError
    case unknown
    case todo(AppError.Todo)
    
    var underlyingError: Error {
        switch self {
        case .serverError, .unknown: self
        case .todo(let error): error
        }
    }
    
    var localizedDescription: String {
        switch self {
        case .serverError:
            return I18N.serverError
        case .unknown:
            return I18N.unKnownError
        case .todo(let error):
            return error.localizedDescription
        }
    }
    
    static func mapper(_ error: Error) -> AppError {
        guard let domainError = error as? DomainError else {
            return .unknown
        }
        
        switch domainError {
        case .decodedFailed:
            return .serverError
        case .jsonFailed:
            return .serverError
        }
    }
}
