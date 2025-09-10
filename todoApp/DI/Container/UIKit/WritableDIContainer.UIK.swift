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

        func makeInputVM(model: (any TodoModelProtocol)?) -> TodoInputVM {
            return container.resolveOrFail(TodoInputVM.self, argument: model)
        }
        
        func makeCreateTodoVM(_ env: DataEnvironment) -> CreateTodoVM {
            let repo = makeRepository(env)

            let addTodo = useCaseAssembly.makeAddTodoUseCase(repo)

            let useCase = CreateTodoVM.UseCase(addTodo: addTodo)

            return container.resolveOrFail(
                CreateTodoVM.self,
                argument: useCase
            )
        }

        func makeCreateTodoVC(_ vm: CreateTodoVM, inputVM:TodoInputVM) -> CreateTodoVC {
            return container.resolveOrFail(
                CreateTodoVC.self,
                arguments: vm, inputVM
            )
        }
        
        func makeEditTodoVM(todoModel: any TodoModelProtocol, env: DataEnvironment) -> EditTodoVM {
            let repo = makeRepository(env)

            let editTodo = container.resolveOrFail(
                (any EditTodoUseCase).self, argument: repo
            )

            let useCase = EditTodoVM.UseCase(editTodo: editTodo)
            
            return container
                .resolveOrFail(EditTodoVM.self, arguments: useCase, todoModel)
        }
        
        func makeEditTodoVC(_ vm: EditTodoVM, inputVM: TodoInputVM) -> EditTodoVC {
            return container.resolveOrFail(
                EditTodoVC.self,
                arguments: vm, inputVM
            )
        }
    }

    final private class WritableTodoAssembly: Assembly {
        func assemble(container: Container) {
            container.register(TodoInputVM.self) {
                (_, model: TodoModelProtocol?) in
                return TodoInputVM(
                    title: model?.title ?? "",
                    date: model?.date,
                    contents: model?.contents ?? ""
                )
            }
            
            // 생성 vm 등록
            container.register(CreateTodoVM.self) {
                (_, useCase: CreateTodoVM.UseCase) in
                return CreateTodoVM(useCase: useCase)
            }

            // 생성 화면 등록
            container.register(CreateTodoVC.self) {
                (resolver, vm: CreateTodoVM, inputVM:TodoInputVM) in
                return CreateTodoVC(vm: vm, inputVM: inputVM)
            }

            // 수정 vm 등록
            container.register(EditTodoVM.self) {
                (_, useCase: EditTodoVM.UseCase, model: TodoModelProtocol) in
                return EditTodoVM(model: model, useCase: useCase)
            }

            // 수정 화면 등록
            container.register(EditTodoVC.self) {
                ( resolver, vm: EditTodoVM, inputVM:TodoInputVM) in
                return EditTodoVC(vm: vm, inputVM: inputVM)
            }
        }
    }

}
