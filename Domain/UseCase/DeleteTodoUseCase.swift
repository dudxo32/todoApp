//
//  DeleteTodoUC.swift
//  todoApp
//
//  Created by 조영태 on 5/11/25.
//

import Foundation
import Shared

public protocol DeleteTodoUseCase {
    associatedtype Error: Swift.Error
    var repository: TodoRepository { get }

    /// 할일 삭제하기
    /// - Throws: DomainError, TodoError
    func execute(_ target: Todo, list: [Todo]) async throws -> [Todo]
}

final public class DefaultDeleteTodoUseCase: DeleteTodoUseCase {
    public enum Error: Swift.Error {}

    public var repository: TodoRepository
    let cache:TodoListCacheUseCase
    
    public init(_ repository: TodoRepository, cache:TodoListCacheUseCase) {
        self.repository = repository
        self.cache = cache
        
    }

    public func execute(_ target: Todo, list: [Todo]) async throws -> [Todo] {
        do {
            let removedID = try await repository.deleteTodo(target.id)

            return cache.deleteItemInList(removedID, list:list)
        } catch {
            throw error
        }
    }
}
