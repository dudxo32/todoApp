//
//  NetworkError.swift
//  DataLayer
//
//  Created by 조영태 on 7/19/25.
//

import Foundation
import Domain

protocol DomainErrorConvertible: Error {
    associatedtype DError: Error
    func toDomainError() -> DError
}

enum DataError: Error, DomainErrorConvertible {
    case decodedFailed
    case jsonFailed
    
    func toDomainError() -> DomainError {
        switch self {
        case .decodedFailed:
            return .decodedFailed
        case .jsonFailed:
            return .jsonFailed
        }
    }
}
