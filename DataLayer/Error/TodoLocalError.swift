//
//  TodoLocalError.swift
//  DataLayer
//
//  Created by 조영태 on 7/19/25.
//

import Foundation
import Domain

enum TodoLocalError: Error, DomainErrorConvertible {
    case notFound
    
    func toDomainError() -> Domain.TodoError {
        switch self {
        case .notFound:
            return .localNotFound
        }
    }
}
