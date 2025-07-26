//
//  TodoRepository.swift
//  todoApp
//
//  Created by 조영태 on 5/11/25.
//

import Foundation

public protocol TodoRepository {
    /// 할일 목록 불러오기
    /// - Throws: DomainError
    /// - Returns: `Todo` 데이터 모델 배열
    func fetchTodoList() async throws -> [Todo]

    /// 할일 목록 작성하기
    /// - Throws: DomainError
    /// - Returns: `Todo` 데이터 모델
    func writeTodo(_ creatableTodo:CreatableTodo) async throws -> Todo
    
    /// 할일 목록 삭제하기
    /// - Throws: DomainError, TodoError
    /// - Returns: Todo 모델의 `id`
    func deleteTodo(_ id: String) async throws -> String
    
    /// 할일 목록 수정하기
    /// - Throws: DomainError, TodoError
    /// - Returns: `Todo` 데이터 모델
    func updateTodo(_ todo:Todo) async throws -> Todo
}

public class MockTodoRepository: TodoRepository {
    public init() {}
    
    public func deleteTodo(_ id: String) async throws -> String {
        fatalError()
    }
    
    public func updateTodo(_ todo: any Todo) async throws -> any Todo {
        fatalError()
    }
    
    public func fetchTodoList() async throws -> [Todo] {
        let modifiedDate = Calendar.current.date(
            byAdding: .day,
            value: 1,
            to: Date()
        )!
        
        return [
            TodoImpl(
                id: "",
                title: "1",
                date: Date(),
                contents: "c",
                isDone: false
            ),
            TodoImpl(
                id: "",
                title: "2",
                date: Date(),
                contents: "c",
                isDone: false
            ),
            TodoImpl(
                id: "",
                title: "3",
                date: Date(),
                contents: "c",
                isDone: false
            ),
            TodoImpl(
                id: "",
                title: "3",
                date: modifiedDate,
                contents: "c",
                isDone: false
            ),
        ]
    }
    
    public func writeTodo(_ creatableTodo: CreatableTodo) async throws -> Todo {
        fatalError()
    }
}
