//
//  EditTodoUseCase.swift
//  todoApp
//
//  Created by 조영태 on 5/11/25.
//

import Foundation
import Shared

public protocol EditTodoUseCase {
    associatedtype Error: Swift.Error
    var repository: TodoRepository { get }
    
    /// Todo 수정하기
    /// - Throws: DomainError, TodoError
    func execute(_ target:Todo, newTitle:String?, newDate:Date?, newContents:String?) async throws -> Todo
}

final public class DefaultEditTodoUseCase: EditTodoUseCase {
    public enum Error: Swift.Error {}

    public var repository: TodoRepository
    
    public init(repository: TodoRepository) {
        self.repository = repository
    }
    
    public func execute(_ target:Todo, newTitle:String?, newDate:Date?, newContents:String? ) async throws -> Todo {
        do {
            
            let newTodo  = TodoImpl(
                id: target.id,
                title: newTitle ?? target.title,
                date: newDate ?? target.date,
                contents: newContents ?? target.contents,
                isDone: target.isDone
            )
            
            let response = try await repository.updateTodo(newTodo)
            
            return response
        } catch {
            throw error
        }
    }
    
}

