//
//  ToggleTodoDoneUC.swift
//  todoApp
//
//  Created by 조영태 on 5/11/25.
//

import Foundation

public protocol ToggleTodoDoneUseCase {
    associatedtype Error: Swift.Error
    var repository: TodoRepository { get }

    /// Todo 객체의 완료 여부 변경
    /// - Throws: DomainError, TodoError
    func execute(_ target: Todo, list: [Todo]) async throws -> [Todo]
}

final public class DefaultToggleTodoDoneUseCase: ToggleTodoDoneUseCase {
    public enum Error: Swift.Error {}

    public var repository: any TodoRepository
    let cache: TodoListCacheUseCase

    public init(_ repository: any TodoRepository, cache: TodoListCacheUseCase) {
        self.repository = repository
        self.cache = cache
    }

    public func execute(_ target: Todo, list: [Todo]) async throws -> [Todo] {
        do {
            let newTodo = TodoImpl(
                id: target.id,
                title: target.title,
                date: target.date,
                contents: target.contents,
                isDone: !target.isDone
            )

            let new = try await repository.updateTodo(newTodo)

            return try cache.changeItemInList(new, list: list)

        } catch {
            throw error
        }
    }

}
