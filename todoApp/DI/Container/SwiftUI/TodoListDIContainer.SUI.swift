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
import PresentationShared
import PresentataionSwiftUI

extension SUI {
    class TodoListDIContainer: TodoListDIContainerProcotcol{
        private let container: Container
        private let repoAssembly: TodoRepositoryAssembly
        private let useCaseAssembly: TodoUseCaseAssembly
        private let assembler: Assembler

        init(parentContainer: Container? = nil) {
            self.container = Container(parent: parentContainer)
            self.repoAssembly = TodoRepositoryAssembly()
            self.useCaseAssembly = TodoUseCaseAssembly()
            
            self.assembler = Assembler(
                [
                    SUI.TodoListAssembly(),
                    repoAssembly,
                    useCaseAssembly
                ],
                container: self.container
            )
        }
        
        func makeTodoListScene(
            initFilter: TodoFilterType,
            env: DataEnvironment = .local,
            setup: ((_ vm: TodoListVM) -> Void)? = nil
        ) -> TodoListVC {
            let vm = makeTodoListVM(initFilter: initFilter, env: env)
            setup?(vm)
            return makeTodoListVC(vm)
        }

        private func makeTodoListVM(
            initFilter: TodoFilterType, env: DataEnvironment = .local
        ) -> TodoListVM {
            let ds = repoAssembly.makeDataSource(.local)
            let repo = repoAssembly.makeRepository(ds)

            let cache = useCaseAssembly.makeListCacheUseCase()
            
            let fetchUseCase = useCaseAssembly.makeFetchTodoUseCase(repo)
            let deleteUseCase = useCaseAssembly.makeDeleteTodoUseCase(repo, cache)
            let toggleDone = useCaseAssembly.makeToggleTodoDoneUseCase(repo, cache)
            let useCase = TodoListVM.UseCase(
                fetch: fetchUseCase,
                delete: deleteUseCase,
                toggleDone: toggleDone,
                cache: cache
            )

            return self.container.resolveOrFail(
                TodoListVM.self,
                arguments: initFilter,useCase
            )
        }

        private func makeTodoListVC(_ vm: TodoListVM) -> TodoListVC {
            return self.container.resolveOrFail(
                TodoListVC.self,
                argument: vm
            )
        }
    }

    final private class TodoListAssembly: Assembly {
        func assemble(container: Container) {
            // swiftUI vm 등록
            container.register(TodoListVM.self) {
                (
                    resolver,
                    initFilter: TodoFilterType,
                    useCase: TodoListVM.UseCase
                ) in

                return TodoListVM(useCase, initFilter: initFilter)
            }
            // swiftUI vc 등록
            container.register(TodoListVC.self) {
                (
                    resolver,
                    viewModel: TodoListVM
                ) in
                    
                return TodoListVC(viewModel: viewModel)
            }
        }
    }
}
