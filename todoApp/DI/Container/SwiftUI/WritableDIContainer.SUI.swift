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
            setup: ((_ vm: CreateTodoVMSwiftUI) -> Void)? = nil
        ) -> WritableTodoVCSwiftUI<CreateTodoVMSwiftUI> {
            let vm = makeCreateVM(env)
            setup?(vm)
            return makeCreateVC(vm)
        }

        func makeEditableTodoScene(
            todo: TodoModelProtocol,
            env: DataEnvironment = .local,
            setup: ((_ vm: EditTodoVMSwiftUI) -> Void)? = nil
        ) -> WritableTodoVCSwiftUI<EditTodoVMSwiftUI> {
            let vm = makeEditVM(todo, env: env)
            setup?(vm)
            return makeEditVC(vm)
        }

        private func makeRepository(_ env: DataEnvironment) -> TodoRepository {
            return container.resolveOrFail(TodoRepository.self, argument: env)
        }

        private func makeCreateVM(_ env: DataEnvironment = .local)
            -> CreateTodoVMSwiftUI
        {
            let repo = makeRepository(env)

            let addTodo = container.resolveOrFail(
                (any AddTodoUseCase).self, argument: repo)

            let useCase = CreateTodoVMSwiftUI.UseCase(addTodo: addTodo)

            return
                container
                .resolveOrFail(CreateTodoVMSwiftUI.self, argument: useCase)
        }

        private func makeCreateVC(_ vm: CreateTodoVMSwiftUI)
            -> WritableTodoVCSwiftUI<CreateTodoVMSwiftUI>
        {
            return container.resolveOrFail(
                WritableTodoVCSwiftUI<CreateTodoVMSwiftUI>.self,
                argument: vm
            )
        }

        private func makeEditVM(
            _ todo: TodoModelProtocol, env: DataEnvironment = .local
        ) -> EditTodoVMSwiftUI {
            let repo = makeRepository(env)

            let editTodo = container.resolveOrFail(
                (any EditTodoUseCase).self, argument: repo)

            let useCase = EditTodoVMSwiftUI.UseCase(editTodo: editTodo)

            return
                container
                .resolveOrFail(EditTodoVMSwiftUI.self, arguments: useCase, todo)
        }

        private func makeEditVC(_ vm: EditTodoVMSwiftUI)
            -> WritableTodoVCSwiftUI<EditTodoVMSwiftUI>
        {
            return container.resolveOrFail(
                WritableTodoVCSwiftUI.self,
                argument: vm
            )
        }

        private func makeEditTodoVC(
            todoModel: TodoModelProtocol, _ env: DataEnvironment = .local
        ) -> EditTodoVC {
            let repo = makeRepository(env)

            let addTodo = container.resolveOrFail(
                (any AddTodoUseCase).self, argument: repo)
            let editTodo = container.resolveOrFail(
                (any EditTodoUseCase).self, argument: repo)

            let useCase = EditTodoVM.UseCase(
                addTodo: addTodo, EditTodo: editTodo)

            return container.resolveOrFail(
                EditTodoVC.self,
                arguments: useCase, todoModel
            )
        }
    }

    final private class WritableTodoAssembly: Assembly {
        func assemble(container: Container) {
            // 생성 VM 등록
            container
                .register(CreateTodoVMSwiftUI.self) {
                    (resovler, useCase: CreateTodoVMSwiftUI.UseCase) in
                    return CreateTodoVMSwiftUI(useCase)
                }

            // 생성 화면 등록
            container.register(WritableTodoVCSwiftUI.self) {
                (resolver, vm: CreateTodoVMSwiftUI) in

                return WritableTodoVCSwiftUI(vm)
            }

            // 수정 vm 등록
            container.register(EditTodoVMSwiftUI.self) {
                (
                    _,
                    useCase: EditTodoVMSwiftUI.UseCase,
                    model: TodoModelProtocol
                ) in

                return EditTodoVMSwiftUI(model, useCase: useCase)
            }

            // 수정 화면 등록
            container.register(WritableTodoVCSwiftUI.self) {
                (resolver, vm: EditTodoVMSwiftUI) in

                return WritableTodoVCSwiftUI(vm)
            }
        }
    }

}
