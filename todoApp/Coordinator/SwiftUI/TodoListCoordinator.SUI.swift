//
//  SwiftUICoordinator.swift
//  todoApp
//
//  Created by 조영태 on 7/9/25.
//

import Combine
import SwiftUI
import PresentationShared

extension SUI {
    enum AppScene {
        case list
    }

    enum WritableScene: Identifiable {
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

    class TodoListCoordinator: ObservableObject {
        @Published var path: NavigationPath
        @Published fileprivate var modalScene: WritableScene? = nil
        
        private let initalScence: AppScene
        private let diContainer: TodoListDIContainer
        
        private var writableCoordinator: SUI.WritableTodoCoordinator? = nil
        private let writtenTodo = PassthroughSubject<(TodoModel, WritableScene), Never>()

        private var cancellables = Set<AnyCancellable>()

        init(initalScene: AppScene, diContainer: TodoListDIContainer) {
            self.path = NavigationPath()
            self.initalScence = initalScene
            self.diContainer = diContainer
        }

        @ViewBuilder
        func buildMain() -> some View {
            buildScence(initalScence)
        }

        @ViewBuilder
        func buildScence(_ scene: AppScene) -> some View {
            switch scene {
            case .list:
                diContainer.makeTodoListScene(initFilter: .today) { vm in
                    self.bindTodoListScene(vm)
                }
            }
        }
        
        func bindTodoListScene(_ vm:SUI.TodoListVM) {
            vm.presentModel
                .assign(to: \TodoListCoordinator.modalScene, on: self)
                .store(in: &cancellables)

            writtenTodo.sink { data in
                let (value, type) = data
                switch type {
                case .create:
                    vm.action(.addedItem(value))
                case .edit:
                    vm.action(.edittedItem(value))
                }
            }
            .store(in: &cancellables)
        }
        
        func buildModalScene(_ scene: WritableScene) -> some View {
            let coordinator = SUI.WritableTodoCoordinator(
                type: scene,
                WritableTodoDIContainer()
            )
            
            self.writableCoordinator = coordinator
            
            coordinator.writeOnCompleted
                .withUnretained(self)
                .sink { (self, data) in
                    let (todo, type) = data
                    self.modalScene = nil
                    self.writableCoordinator = nil
                    self.writtenTodo.send((todo, type))
                }
                .store(in: &cancellables)

            return writableCoordinator!.buildMain()
        }
    }

    struct CoordinatorScene: View {
        @StateObject var coordinator: TodoListCoordinator

        var body: some View {
            NavigationStack(path: $coordinator.path) {
                coordinator
                    .buildMain()
                    .navigationDestination(for: AppScene.self) { scene in
                        coordinator.buildScence(scene)
                    }

            }
            .sheet(item: $coordinator.modalScene) { modalScence in
                coordinator.buildModalScene(modalScence)
            }
        }
    }
}


extension View {
    @ViewBuilder
    func navigationTitleInline(_ title: String) -> some View {
        self
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
    }

}
