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

    public func fetchTodoList() async throws -> [Todo] {
        do {
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
        } catch let error as DomainErrorConvertible {
            throw error.toDomainError()
        } catch {
            throw error
        }
      
    }

    public func writeTodo(_ creatable: CreatableTodo) async throws -> Todo {
        let param = TodoRequest.Write(
            title: creatable.title,
            date: creatable.date,
            contents: creatable.contents
        )

        do {
            let response = try await dataSource.writeTodo(param)

            return TodoImpl(
                id: response.id,
                title: response.title,
                date: response.date,
                contents: response.contents,
                isDone: response.isDone
            )
        } catch let error as DomainErrorConvertible {
            throw error.toDomainError()
        } catch {
            throw error
        }
       
    }

    public func deleteTodo(_ id: String) async throws -> String {
        let requestParm = TodoRequest.Delete(id: id)
        do {
            let response = try await dataSource.deleteTodo(requestParm)

            return response.id
        } catch let error as DomainErrorConvertible {
            throw error.toDomainError()
        } catch {
            throw error
        }
    }

    public func updateTodo(_ todo: Todo) async throws -> Todo {
        let param = TodoRequest.Update(
            id: todo.id,
            title: todo.title,
            contents: todo.contents,
            isDone: todo.isDone,
            date: todo.date
        )

        do {
            let response = try await dataSource.updateTodo(param)

            return TodoImpl(
                id: response.id,
                title: response.title,
                date: response.date,
                contents: response.contents,
                isDone: response.isDone
            )
        } catch let error as DomainErrorConvertible {
            throw error.toDomainError()
        } catch {
            throw error
        }
    }
}
