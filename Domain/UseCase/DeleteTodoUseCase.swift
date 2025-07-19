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
    /// - Throws: ``DeleteTodoUseCaseBase.Error``
    func execute(_ target: Todo, list: [Todo]) async throws -> [Todo]
}

final public class DefaultDeleteTodoUseCase: DeleteTodoUseCase {
    public enum Error: Swift.Error {
        case ServerError
    }

    public var repository: TodoRepository
    let cache:TodoListCache
    
    public init(_ repository: TodoRepository, cache:TodoListCache) {
        self.repository = repository
        self.cache = cache
        
    }

    public func execute(_ target: Todo, list: [Todo]) async throws -> [Todo] {
        do {
            let removedID = try await repository.deleteTodo(target.id)

            return cache.deleteItemInList(removedID, list:list)
//FIXME: - networkError 에러 계층화
        } catch let error as NetworkError {
            switch error {
            case .DecodedFailed:
                throw error
            case .DictionaryFailed:
                throw error
            }
        } catch {
            throw Error.ServerError
        }
    }
}
