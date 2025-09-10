//
//  NetworkError.swift
//  Domain
//
//  Created by 조영태 on 7/19/25.
//

import Foundation

@frozen
public enum DomainError: Error {
    case decodedFailed
    case jsonFailed
}
