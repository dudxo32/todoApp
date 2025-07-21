//
//  TodoCacheUseCaseAssembly.swift
//  todoApp
//
//  Created by 조영태 on 5/11/25.
//

import Foundation
import Swinject
import Domain

final class TodoCacheAssembly: Assembly {
    func assemble(container: Container) {
        container.register(TodoListCacheUseCase.self) { _ in
            TodoListCacheUseCase()
        }
    }
}
