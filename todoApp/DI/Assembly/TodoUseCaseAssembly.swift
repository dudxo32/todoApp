//
//  TodoUseCaseAssembly.swift
//  todoApp
//
//  Created by 조영태 on 5/11/25.
//

import Foundation
import Swinject
import Domain

final class TodoUseCaseAssembly: Assembly {
    private var resolver: Container!

    func assemble(container: Container) {
        self.resolver = container
        
        container.register((any FetchTodoUseCase).self) {
            (_, repository: TodoRepository) in
            DefaultFetchTodoUseCase(repository)
        }

        container.register((any DeleteTodoUseCase).self) {
            (_, repository: TodoRepository, cache: TodoListCacheUseCase) in
            DefaultDeleteTodoUseCase(repository, cache: cache)
        }

        container.register((any ToggleTodoDoneUseCase).self) {
            (_, repository: TodoRepository, cache: TodoListCacheUseCase) in
            DefaultToggleTodoDoneUseCase(repository, cache: cache)
        }
        
        container.register((any AddTodoUseCase).self) {
            (_, repository: TodoRepository) in
            DefaultAddTodoUseCase(repository: repository)
        }
        
        container.register((any EditTodoUseCase).self) {
            (_, repository: TodoRepository) in
            DefaultEditTodoUseCase(repository: repository)
        }
        
        container.register(TodoListCacheUseCase.self) { _ in
            TodoListCacheUseCase()
        }
    }
    
    func makeFetchTodoUseCase(_ repo:TodoRepository) -> any FetchTodoUseCase {
        return resolver.resolveOrFail((any FetchTodoUseCase).self, argument: repo)
    }
    
    func makeDeleteTodoUseCase(_ repo:TodoRepository, _ cache:TodoListCacheUseCase) -> any DeleteTodoUseCase {
        return resolver.resolveOrFail((any DeleteTodoUseCase).self, arguments: repo, cache)
    }
    
    func makeToggleTodoDoneUseCase(_ repo:TodoRepository, _ cache:TodoListCacheUseCase) -> any ToggleTodoDoneUseCase {
        return resolver.resolveOrFail((any ToggleTodoDoneUseCase).self, arguments: repo, cache)
    }
    
    func makeAddTodoUseCase(_ repo:TodoRepository) -> any AddTodoUseCase {
        return resolver.resolveOrFail((any AddTodoUseCase).self, argument: repo)
    }
    
    func makeEditTodoUseCase(_ repo:TodoRepository) -> any EditTodoUseCase {
        return resolver.resolveOrFail((any EditTodoUseCase).self, argument: repo)
    }
    
    func makeListCacheUseCase() -> TodoListCacheUseCase {
        return resolver.resolveOrFail(TodoListCacheUseCase.self)
    }
}
