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

class SwiftUICoordinator: ObservableObject {

    
    @Published var path: NavigationPath
    @Published fileprivate var modalScene: WritableScene? = nil

    private let initalScence: AppScene
    private let diContainer: TodoListDIContainer

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

    func buildScence(_ scene: AppScene) -> some View {
        switch scene {
        case .list:
            let vm = diContainer.makeTodoListVMSwiftUI(initFilter: .today)
            bindTodoListScene(vm)
            
            return diContainer.makeTodoListVCSwiftUI(vm)
        }
    }
    
    func bindTodoListScene(_ vm:TodoListVMSwiftUI) {
        vm.presentModel
            .assign(to: \.modalScene, on: self)
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
        let coordinator = SwiftUIWritableTodoCoordinator(
            type: scene,
            EditableTodoDIContainer()
        )
        
        coordinator.writeOnCompleted
            .withUnretained(self)
            .sink { (self, data) in
                let (todo, type) = data
                self.modalScene = nil
                self.writtenTodo.send((todo, type))
            }
            .store(in: &cancellables)

        return coordinator.buildMain()
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
        .sheet(item: $coordinator.modalScene) { modalScence in
            coordinator.buildModalScene(modalScence)
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
