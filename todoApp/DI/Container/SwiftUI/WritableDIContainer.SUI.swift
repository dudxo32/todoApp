//
//  File.swift
//  todoApp
//
//  Created by 조영태 on 7/15/25.
//

import DataLayer
import Domain
import Foundation
import PresentataionSwiftUI
import PresentationShared
import Swinject

extension SUI {
    class WritableTodoDIContainer: WritableTodoDIContainerProtocol {
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
                    WritableTodoAssembly(),
                    repoAssembly,
                    useCaseAssembly,
                ],
                container: self.container
            )
        }

        func makeCreatableTodoScene(
            env: DataEnvironment,
            setup: ((_ vm: CreateTodoVM) -> Void)?
        ) -> CreateTodoVC {
            let vm = makeCreateVM(env)
            setup?(vm)
            return makeCreateVC(vm)
        }

        func makeEditableTodoScene(
            todo: any TodoModelProtocol,
            env: DataEnvironment,
            setup: ((_ vm: EditTodoVM) -> Void)?
        ) -> EditTodoVC {
            let vm = makeEditVM(todo, env: env)
            setup?(vm)
            return makeEditVC(vm)
        }

        private func makeRepository(_ env: DataEnvironment) -> TodoRepository {
            let ds = repoAssembly.makeDataSource(.local)
            return repoAssembly.makeRepository(ds)
        }

        private func makeCreateVM(_ env: DataEnvironment = .local)
            -> CreateTodoVM
        {
            let repo = makeRepository(env)

            let addTodo = useCaseAssembly.makeAddTodoUseCase(repo)
            let useCase = CreateTodoVM.UseCase(addTodo: addTodo)

            return container.resolveOrFail(
                CreateTodoVM.self,
                argument: useCase
            )
        }

        private func makeCreateVC(_ vm: CreateTodoVM) -> CreateTodoVC {
            return container.resolveOrFail(
                CreateTodoVC.self,
                argument: vm
            )
        }

        private func makeEditVM(
            _ todo: any TodoModelProtocol,
            env: DataEnvironment = .local
        ) -> EditTodoVM {
            let repo = makeRepository(env)

            let editTodo = useCaseAssembly.makeEditTodoUseCase(repo)
            let useCase = EditTodoVM.UseCase(editTodo: editTodo)

            return container.resolveOrFail(
                EditTodoVM.self,
                arguments: useCase, todo
            )
        }

        private func makeEditVC(_ vm: EditTodoVM) -> EditTodoVC {
            return container.resolveOrFail(
                EditTodoVC.self,
                argument: vm
            )
        }
    }

    final private class WritableTodoAssembly: Assembly {
        func assemble(container: Container) {
            // 생성 VM 등록
            container
                .register(CreateTodoVM.self) {
                    (resovler, useCase: CreateTodoVM.UseCase) in
                    return CreateTodoVM(useCase)
                }

            // 생성 화면 등록
            container.register(CreateTodoVC.self) {
                (resolver, vm: CreateTodoVM) in

                return CreateTodoVC(vm)
            }

            // 수정 vm 등록
            container.register(EditTodoVM.self) {
                (
                    _,
                    useCase: EditTodoVM.UseCase,
                    model: TodoModelProtocol
                ) in

                return EditTodoVM(model, useCase: useCase)
            }

            // 수정 화면 등록
            container.register(EditTodoVC.self) {
                (resolver, vm: EditTodoVM) in

                return EditTodoVC(vm)
            }
        }
    }

}
