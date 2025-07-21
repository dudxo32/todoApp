//
//  File.swift
//  todoApp
//
//  Created by 조영태 on 7/14/25.
//

import Foundation
import Swinject
import DataLayer
import Domain

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
            setup: ((_ vm: SUI.TodoListVM) -> Void)? = nil
        ) -> SUI.TodoListVC {
            let vm = makeTodoListVM(initFilter: initFilter, env: env)
            setup?(vm)
            return makeTodoListVC(vm)
        }

        private func makeTodoListVM(
            initFilter: TodoFilterType, env: DataEnvironment = .local
        ) -> SUI.TodoListVM {
            let repo = container.resolveOrFail(
                TodoRepository.self,
                argument: env
            )

            let cache = container.resolveOrFail(TodoListCacheUseCase.self)
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

            let useCase = SUI.TodoListVM.UseCase(
                fetch: fetchUseCase,
                delete: deleteUseCase,
                toggleDone: toggleDone,
                cache: cache
            )

            return self.container
                .resolveOrFail(
                    SUI.TodoListVM.self,
                    arguments: initFilter,
                    useCase
                )
        }

        private func makeTodoListVC(_ vm: SUI.TodoListVM) -> SUI.TodoListVC {
            return self.container.resolveOrFail(
                SUI.TodoListVC.self,
                argument: vm
            )
        }
    }

    final private class TodoListAssembly: Assembly {
        func assemble(container: Container) {
            // swiftUI vm 등록
            container.register(SUI.TodoListVM.self) {
                (
                    resolver,
                    initFilter: TodoFilterType,
                    useCase: SUI.TodoListVM.UseCase
                ) in

                return SUI.TodoListVM(useCase, initFilter: initFilter)
            }
            // swiftUI vc 등록
            container.register(SUI.TodoListVC.self) {
                (
                    resolver,
                    viewModel: SUI.TodoListVM
                ) in
                    
                return SUI.TodoListVC(viewModel: viewModel)
            }
        }
    }
}
