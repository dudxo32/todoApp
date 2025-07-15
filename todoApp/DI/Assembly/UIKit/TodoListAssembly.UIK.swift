//
//  TodoListAssembly.UIK.swift
//  todoApp
//
//  Created by 조영태 on 7/14/25.
//

import Foundation
import Swinject

enum UIK {}

extension UIK {
    final class TodoListAssembly: Assembly {
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
                    useCase: TodoListVM.UseCase
                ) in

                let viewModel = resolver.resolveOrFail(
                    TodoListVM.self,
                    arguments: initFilter, useCase
                )

                return TodoListVC(initFilter: initFilter, vm: viewModel)
            }
        }
    }

}
