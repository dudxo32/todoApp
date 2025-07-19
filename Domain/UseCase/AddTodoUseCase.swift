//
//  AddTodoUseCase.swift
//  todoApp
//
//  Created by 조영태 on 5/11/25.
//

import Foundation

public protocol AddTodoUseCase {
    associatedtype Error: Swift.Error
    var repository: TodoRepository { get }

    /// Todo를 추가
    /// - Throws: ``AddTodoUseCase.Error``
    func execute(title: String, contents: String, date: Date) async throws
        -> Todo
}

final public class DefaultAddTodoUseCase: AddTodoUseCase {
    public enum Error: Swift.Error {}

    public var repository: any TodoRepository

    public init(repository: any TodoRepository) {
        self.repository = repository
    }

    public func execute(title: String, contents: String, date: Date) async throws
        -> Todo
    {
        do {
            let creatable = CreatableToDoImpl(
                title: title, date: date, contents: contents)
            let newTodo = try await repository.writeTodo(creatable)

            return newTodo
        } catch {
            // 추가 에러 처리 가능
            throw error
        }
    }

}
