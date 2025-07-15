//
//  TodoListDIContainer.swift
//  todoApp
//
//  Created by 조영태 on 5/1/25.
//

import Foundation
import Moya
import Swinject
import UIKit

extension UIK {
    class TodoListDIContainer {
        private let container: Container
        private let assembler: Assembler

        init(parentContainer: Container? = nil) {
            self.container = Container(parent: parentContainer)

            
            self.assembler = Assembler(
                [
                    UIK.TodoListAssembly(),
                    TodoRepositoryAssembly(),
                    TodoUseCaseAssembly(),
                    TodoCacheAssembly(),
                ],
                container: self.container
            )
        }

        func makeTodoListVC(
            initFilter: TodoFilterType, env: DataEnvironment = .local
        ) -> TodoListVC {
            let repo = container.resolveOrFail(TodoRepository.self, argument: env)

            let cache = container.resolveOrFail(TodoListCache.self)
            let fetchUseCase = container.resolveOrFail(
                (any FetchTodoUseCase).self, argument: repo
            )
            let deleteUseCase = container.resolveOrFail(
                (any DeleteTodoUseCase).self,
                arguments: repo, cache
            )
            let toggleDone = container.resolveOrFail(
                (any ToggleTodoDoneUseCase).self,
                arguments: repo, cache
            )

            let useCase = TodoListVM.UseCase(
                fetch: fetchUseCase,
                delete: deleteUseCase,
                toggleDone: toggleDone,
                cache: cache
            )

            return self.container.resolveOrFail(
                TodoListVC.self,
                arguments: initFilter, useCase
            )
        }
    }
    
}
