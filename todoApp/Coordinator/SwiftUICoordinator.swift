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

    let writtenTodo = PassthroughSubject<(TodoModel, WritableType), Never>()

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
            bindTodoListScene(vm)
            
            return diContainer.makeTodoListVCSwiftUI(vm)
        }
    }
    
    func bindTodoListScene(_ vm:TodoListVMSwiftUI) {
        vm.presentModel
            .assign(to: \.modalScence, on: self)
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
    
    @ViewBuilder
    func buildModalScene(_ scence: ModalScene) -> some View {
        switch scence {
        case .create:
            buildCreateView()

        case .edit(let value):
            buildEditView(value)

        }
    }
    
    private func bindWrittenTodo(_ vm:any WritableTodoPublisher) {
        vm.writtenTodoPublisher
            .compactMap { $0 }
            .withUnretained(self)
            .sink { (self, value) in
                self.modalScence = nil
                self.writtenTodo.send((value, vm.type))
            }
            .store(in: &cancellables)
    }
    
    private func buildCreateView() -> some View {
        let vm = CreateTodoVMSwiftUI(
            CreateTodoVMSwiftUI
                .UseCase(
                    addTodo: DefaultAddTodoUseCase(
                        repository: TodoRepositoryImpl(TodoLocalDataSource())
                    )
                )
        )

        bindWrittenTodo(vm)
        
        return WritableTodoVCSwiftUI<CreateTodoVMSwiftUI>(vm)
    }
    
    private func buildEditView(_ todo: TodoModel) -> some View {
        let viewModel = EditTodoVMSwiftUI(
            todo,
            useCase:
                EditTodoVMSwiftUI
                .UseCase(
                    editTodo: DefaultEditTodoUseCase(
                        repository: TodoRepositoryImpl(TodoLocalDataSource())
                    )
                )
        )
        
        bindWrittenTodo(viewModel)

        return WritableTodoVCSwiftUI<EditTodoVMSwiftUI>(viewModel)
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
