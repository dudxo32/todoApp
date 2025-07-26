//
//  FetchTodoUseCase.swift
//  todoApp
//
//  Created by 조영태 on 5/11/25.
//

import Foundation
import Shared

public protocol FetchTodoUseCase {
    associatedtype Error: Swift.Error
    var repository: TodoRepository { get }

    /// 할일 목록 불러오기
    /// - Throws: DomainError
    func execute() async throws -> [Todo]
}

final public class DefaultFetchTodoUseCase: FetchTodoUseCase {
    public enum Error: Swift.Error {}

    public var repository: TodoRepository

    public init(_ repository: TodoRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [Todo] {
        do {
            return try await repository.fetchTodoList()
        } catch {
            throw error
        }
    }
}
