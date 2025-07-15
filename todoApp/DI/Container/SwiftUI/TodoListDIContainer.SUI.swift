//
//  File.swift
//  todoApp
//
//  Created by 조영태 on 7/14/25.
//

import Foundation
import Swinject

extension SUI {
    class TodoListDIContainer {
        private let container: Container
        private let assembler: Assembler

        init(parentContainer: Container? = nil) {
            self.container = Container(parent: parentContainer)
            
            self.assembler = Assembler(
                [
                    SUI.TodoListAssembly(),
                    TodoRepositoryAssembly(),
                    TodoUseCaseAssembly(),
                    TodoCacheAssembly(),
                ],
                container: self.container
            )
        }

        func makeTodoListScene(
            initFilter: TodoFilterType,
            env: DataEnvironment = .local,
            setup: ((_ vm: TodoListVMSwiftUI) -> Void)? = nil
        ) -> TodoListVCSwiftUI {
            let vm = makeTodoListVM(initFilter: initFilter, env: env)
            setup?(vm)
            return makeTodoListVC(vm)
        }

        private func makeTodoListVM(
            initFilter: TodoFilterType, env: DataEnvironment = .local
        ) -> TodoListVMSwiftUI {
            let repo = container.resolveOrFail(
                TodoRepository.self,
                argument: env
            )

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

            let useCase = TodoListVMSwiftUI.UseCase(
                fetch: fetchUseCase,
                delete: deleteUseCase,
                toggleDone: toggleDone,
                cache: cache
            )

            return self.container
                .resolveOrFail(
                    TodoListVMSwiftUI.self,
                    arguments: initFilter,
                    useCase
                )
        }

        private func makeTodoListVC(_ vm: TodoListVMSwiftUI) -> TodoListVCSwiftUI {
            return self.container.resolveOrFail(
                TodoListVCSwiftUI.self,
                argument: vm
            )
        }
    }

}
