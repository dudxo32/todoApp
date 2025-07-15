//
//  File.swift
//  todoApp
//
//  Created by 조영태 on 7/15/25.
//

import Foundation
import Swinject

extension SUI {
    class WritableTodoDIContainer {
        private let container: Container
        private let assembler: Assembler

        init(parentContainer: Container? = nil) {
            self.container = Container(parent: parentContainer)

            self.assembler = Assembler(
                [
                    SUI.WritableTodoAssembly(),
                    TodoRepositoryAssembly(),
                    TodoUseCaseAssembly(),
                ],
                container: self.container
            )
        }

        func makeCreatableTodoScene(
            env: DataEnvironment = .local,
            setup: ((_ vm: SUI.CreateTodoVM) -> Void)? = nil
        ) -> SUI.WritableTodoVC<SUI.CreateTodoVM> {
            let vm = makeCreateVM(env)
            setup?(vm)
            return makeCreateVC(vm)
        }

        func makeEditableTodoScene(
            todo: TodoModelProtocol,
            env: DataEnvironment = .local,
            setup: ((_ vm: SUI.EditTodoVM) -> Void)? = nil
        ) -> SUI.WritableTodoVC<SUI.EditTodoVM> {
            let vm = makeEditVM(todo, env: env)
            setup?(vm)
            return makeEditVC(vm)
        }

        private func makeRepository(_ env: DataEnvironment) -> TodoRepository {
            return container.resolveOrFail(TodoRepository.self, argument: env)
        }

        private func makeCreateVM(_ env: DataEnvironment = .local)
            -> SUI.CreateTodoVM
        {
            let repo = makeRepository(env)

            let addTodo = container.resolveOrFail(
                (any AddTodoUseCase).self, argument: repo)

            let useCase = SUI.CreateTodoVM.UseCase(addTodo: addTodo)

            return
                container
                .resolveOrFail(SUI.CreateTodoVM.self, argument: useCase)
        }

        private func makeCreateVC(_ vm: SUI.CreateTodoVM)
            -> SUI.WritableTodoVC<SUI.CreateTodoVM>
        {
            return container.resolveOrFail(
                SUI.WritableTodoVC<SUI.CreateTodoVM>.self,
                argument: vm
            )
        }

        private func makeEditVM(
            _ todo: TodoModelProtocol, env: DataEnvironment = .local
        ) -> SUI.EditTodoVM {
            let repo = makeRepository(env)

            let editTodo = container.resolveOrFail(
                (any EditTodoUseCase).self, argument: repo)

            let useCase = SUI.EditTodoVM.UseCase(editTodo: editTodo)

            return
                container
                .resolveOrFail(SUI.EditTodoVM.self, arguments: useCase, todo)
        }

        private func makeEditVC(_ vm: SUI.EditTodoVM)
            -> SUI.WritableTodoVC<SUI.EditTodoVM>
        {
            return container.resolveOrFail(
                SUI.WritableTodoVC.self,
                argument: vm
            )
        }
    }

    final private class WritableTodoAssembly: Assembly {
        func assemble(container: Container) {
            // 생성 VM 등록
            container
                .register(SUI.CreateTodoVM.self) {
                    (resovler, useCase: SUI.CreateTodoVM.UseCase) in
                    return SUI.CreateTodoVM(useCase)
                }

            // 생성 화면 등록
            container.register(SUI.WritableTodoVC.self) {
                (resolver, vm: SUI.CreateTodoVM) in

                return SUI.WritableTodoVC(vm)
            }

            // 수정 vm 등록
            container.register(SUI.EditTodoVM.self) {
                (
                    _,
                    useCase: SUI.EditTodoVM.UseCase,
                    model: TodoModelProtocol
                ) in

                return SUI.EditTodoVM(model, useCase: useCase)
            }

            // 수정 화면 등록
            container.register(SUI.WritableTodoVC.self) {
                (resolver, vm: SUI.EditTodoVM) in

                return SUI.WritableTodoVC(vm)
            }
        }
    }

}
