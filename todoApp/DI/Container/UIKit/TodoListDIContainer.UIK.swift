//
//  TodoListDIContainer.swift
//  todoApp
//
//  Created by 조영태 on 5/1/25.
//

import Foundation
import UIKit
import Swinject
import Domain
import DataLayer
import PresentationShared
import PresentationUIKit

extension UIK {
    class TodoListDIContainer: TodoListDIContainerProtocol {
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
                    TodoListAssembly(),
                    repoAssembly,
                    useCaseAssembly
                ],
                container: self.container
            )
        }
        
        func makeTodoListVM(initFilter: TodoFilterType, env: DataEnvironment = .local) -> TodoListVM {
            let ds = repoAssembly.makeDataSource()
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

            return container.resolveOrFail(
                TodoListVM.self,
                arguments: initFilter, useCase
            )
        }
        
        func makeTodoListVC(_ vm:TodoListVM, initFilter: TodoFilterType) -> TodoListVC {
            return self.container.resolveOrFail(
                TodoListVC.self,
                arguments: initFilter, vm
            )
        }
    }
    
    final private class TodoListAssembly: Assembly {
        func assemble(container: Container) {
            // vm 등록
            container.register(TodoListVM.self) {
                (
                    resolver,
                    initFilter: TodoFilterType,
                    useCase: TodoListVM.UseCase
                ) in

                return TodoListVM(initFilter: initFilter, useCase: useCase)
            }

            // vc 등록
            container.register(TodoListVC.self) {
                (
                    resolver,
                    initFilter: TodoFilterType,
                    vm:TodoListVM
                ) in
                return TodoListVC(initFilter: initFilter, vm: vm)
            }
        }
    }

}
