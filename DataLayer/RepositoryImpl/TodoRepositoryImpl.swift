//
//  TodoRepository.swift
//  todoApp
//
//  Created by 조영태 on 5/8/25.
//

import Foundation
import Domain

struct TodoImpl: Todo {
    var id: String
    var title: String
    var date: Date
    var contents: String
    var isDone: Bool
}

public class TodoRepositoryImpl: TodoRepository {
    private let dataSource: TodoDataSourceProtocol

    public init(_ dataSource: TodoDataSourceProtocol) {
        self.dataSource = dataSource
    }

    /// 할일 목록 불러오기
    /// - Throws: ``NetworkError``
    /// - Returns: `Todo` 데이터 모델 배열
    public func fetchTodoList() async throws -> [Todo] {
        let response = try await dataSource.fetchTodoList()

        return response.map { res in
            TodoImpl(
                id: res.id,
                title: res.title,
                date: res.date,
                contents: res.contents,
                isDone: res.isDone
            )
        }
    }

    /// 할일 목록 작성하기
    /// - Throws: ``NetworkError``
    /// - Returns: `Todo` 데이터 모델
    public func writeTodo(_ creatable: CreatableTodo) async throws -> Todo {
        let param = TodoRequest.Write(
            title: creatable.title,
            date: creatable.date,
            contents: creatable.contents
        )

        let response = try await dataSource.writeTodo(param)

        return TodoImpl(
            id: response.id,
            title: response.title,
            date: response.date,
            contents: response.contents,
            isDone: response.isDone
        )
    }

    /// 할일 목록 삭제하기
    /// - Throws: ``NetworkError``, ``TodoError``
    /// - Returns: Todo 모델의 `id`
    public func deleteTodo(_ id: String) async throws -> String {
        let requestParm = TodoRequest.Delete(id: id)
        let response = try await dataSource.deleteTodo(requestParm)

        return response.id
    }

    /// 할일 목록 수정하기
    /// - Throws: ``NetworkError``, ``TodoError``
    /// - Returns: `Todo` 데이터 모델
    public func updateTodo(_ todo: Todo) async throws -> Todo {
        let param = TodoRequest.Update(
            id: todo.id,
            title: todo.title,
            contents: todo.contents,
            isDone: todo.isDone,
            date: todo.date
        )

        let response = try await dataSource.updateTodo(param)

        return TodoImpl(
            id: response.id,
            title: response.title,
            date: response.date,
            contents: response.contents,
            isDone: response.isDone
        )
    }
}
