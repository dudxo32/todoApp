//
//  SwiftUICoordinator.swift
//  todoApp
//
//  Created by 조영태 on 7/9/25.
//

import Combine
import SwiftUI

enum AppScene {
    case list
}
enum ModalScene: Identifiable {
    case create
    case edit(todo: TodoModel)

    var id: String {
        switch self {
        case .create:
            return "create"
        case .edit(todo: let todo):
            return "todo-\(todo.id)"
        }
    }
}

class SwiftUICoordinator: ObservableObject {
    @Published var path: NavigationPath
    @Published fileprivate var modalScence: ModalScene? = nil

    private let initalScence: AppScene
    private let diContainer: TodoListDIContainer

    let createResult = PassthroughSubject<TodoModel, Never>()

    var cancellables = Set<AnyCancellable>()

    init(initalScene: AppScene, diContainer: TodoListDIContainer) {
        self.path = NavigationPath()
        self.initalScence = initalScene
        self.diContainer = diContainer
    }

    @ViewBuilder
    func buildMain() -> some View {
        buildScence(initalScence)
    }

    func buildScence(_ scene: AppScene) -> some View {
        switch scene {
        case .list:
            let vm = diContainer.makeTodoListVMSwiftUI(initFilter: .today)
            
            vm.presentModel
                .assign(to: \.modalScence, on: self)
                .store(in: &cancellables)

            return diContainer.makeTodoListVCSwiftUI(vm)
        }
    }

    @ViewBuilder
    func buildModelScence(_ scence: ModalScene) -> some View {
        switch scence {
        case .create:
            CreatableTodoVCSwiftUI { newValue in
//                createResult.send(newValue)
            }

        case .edit(let value):
            EditableTodoVCSwiftUI(value) { newValue in
//                viewModel.action(.edittedItem(newValue))
            }
        }
    }
}

struct SwiftUIScene: View {
    @StateObject var coordinator: SwiftUICoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator
                .buildMain()
                .navigationDestination(for: AppScene.self) { scene in
                    coordinator.buildScence(scene)
                }

        }
        .sheet(item: $coordinator.modalScence) { modalScence in
            coordinator.buildModelScence(modalScence)
        }
    }
}

extension View {
    func navigationTitleInline(_ title: String) -> some View {
        return
            self
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
    }

}
