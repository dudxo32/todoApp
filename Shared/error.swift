//
//  error.swift
//  Shared
//
//  Created by 조영태 on 7/18/25.
//

import Foundation

public enum NetworkError: Error {
    case DecodedFailed
    case DictionaryFailed
}

public enum TodoError: Error { case notFound }
