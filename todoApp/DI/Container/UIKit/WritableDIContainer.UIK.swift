//
//  File.swift
//  todoApp
//
//  Created by 조영태 on 4/8/25.
//

import DataLayer
import Domain
import Foundation
import PresentationShared
import PresentationUIKit
import Swinject

extension UIK {
    class WritableTodoDIContainer: WritableTodoDIContainerProtocol {
        private let container: Container
        private let assembler: Assembler
        private let repoAssembly: TodoRepositoryAssembly
        private let useCaseAssembly: TodoUseCaseAssembly

        init(parentContainer: Container? = nil) {
            self.container = Container(parent: parentContainer)
            self.repoAssembly = TodoRepositoryAssembly()
            self.useCaseAssembly = TodoUseCaseAssembly()

            self.assembler = Assembler(
                [
                    WritableTodoAssembly(),
                    repoAssembly,
                    useCaseAssembly
                ],
                container: self.container
            )
        }

        private func makeRepository(_ env: DataEnvironment) -> TodoRepository {
            let ds = repoAssembly.makeDataSource()
            return repoAssembly.makeRepository(ds)
        }

        func makeCreateTodoVM(_ env: DataEnvironment) -> CreateTodoVM
        {
            let repo = makeRepository(env)

            let addTodo = useCaseAssembly.makeAddTodoUseCase(repo)
            let editTodo = useCaseAssembly.makeEditTodoUseCase(repo)

            let useCase = CreateTodoVM.UseCase(
                addTodo: addTodo,
                EditTodo: editTodo
            )

            return container.resolveOrFail(
                CreateTodoVM.self,
                argument: useCase
            )
        }

        func makeCreateTodoVC(_ vm: WritableTodoVM) -> CreateTodoVC {
            return container.resolveOrFail(CreateTodoVC.self, argument: vm)
        }
        
        func makeEditTodoVM(todoModel: any TodoModelProtocol, env: DataEnvironment) -> EditTodoVM {
            let repo = makeRepository(env)

            let addTodo = container.resolveOrFail(
                (any AddTodoUseCase).self, argument: repo)
            let editTodo = container.resolveOrFail(
                (any EditTodoUseCase).self, argument: repo)

            let useCase = EditTodoVM.UseCase(
                addTodo: addTodo, EditTodo: editTodo)
            
            return container.resolveOrFail(EditTodoVM.self, arguments: useCase, todoModel)
        }
        
        func makeEditTodoVC(todoModel: any TodoModelProtocol, vm: EditTodoVM) -> EditTodoVC {
            return container.resolveOrFail(
                EditTodoVC.self,
                argument: vm
            )
        }
    }

    final private class WritableTodoAssembly: Assembly {
        func assemble(container: Container) {
            // 생성 vm 등록
            container.register(CreateTodoVM.self) {
                (_, useCase: CreateTodoVM.UseCase) in
                return CreateTodoVM(useCase)
            }

            // 생성 화면 등록
            container.register(CreateTodoVC.self) {
                (resolver, vm: WritableTodoVM) in
                return CreateTodoVC(vm)
            }

            // 수정 vm 등록
            container.register(EditTodoVM.self) {
                (
                    _, useCase: CreateTodoVM.UseCase,
                    model: TodoModelProtocol
                ) in
                return EditTodoVM(model: model, useCase: useCase)
            }

            // 수정 화면 등록
            container.register(EditTodoVC.self) {
                (
                    resolver,
                    vm: EditTodoVM
                ) in
                return EditTodoVC(vm)
            }
        }
    }

}
