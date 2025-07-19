//
//  TodoRemoteDataSource.swift
//  todoApp
//
//  Created by 조영태 on 5/8/25.
//

import Foundation
internal import Moya

public class TodoRemoteDataSource: TodoDataSourceProtocol {
    fileprivate var networkManger: NetworkManager<TodoAPI>

    public init(_ networkManger: NetworkManager<TodoAPI>) {
        self.networkManger = networkManger
    }

    public func fetchTodoList() async throws -> [TodoResponse.Fetch] {
        return try await networkManger.requestData(.fetchList)
    }

    public func writeTodo(_ param:TodoRequest.Write) async throws -> TodoResponse.Write {
        return try await networkManger.requestData(.write(param))
    }

    public func deleteTodo(_ param:TodoRequest.Delete) async throws -> TodoResponse.Delete {
        return try await networkManger.requestData(.delete(param))
    }

    public func updateTodo(_ param:TodoRequest.Update) async throws -> TodoResponse.Update {
        return try await networkManger.requestData(.update(param))
    }

}
