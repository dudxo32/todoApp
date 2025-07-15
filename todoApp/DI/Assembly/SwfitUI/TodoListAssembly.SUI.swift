//
//  File.swift
//  todoApp
//
//  Created by 조영태 on 7/14/25.
//

import Foundation
import Swinject

extension SUI {
    final class TodoListAssembly: Assembly {
        func assemble(container: Container) {
            // swiftUI vm 등록
            container.register(TodoListVMSwiftUI.self) {
                (
                    resolver,
                    initFilter: TodoFilterType,
                    useCase: TodoListVMSwiftUI.UseCase
                ) in

                return TodoListVMSwiftUI(useCase, initFilter: initFilter)
            }
            // swiftUI vc 등록
            container.register(TodoListVCSwiftUI.self) {
                (
                    resolver,
                    viewModel: TodoListVMSwiftUI
                ) in
                    
                return TodoListVCSwiftUI(viewModel: viewModel)
            }
        }
    }
}
