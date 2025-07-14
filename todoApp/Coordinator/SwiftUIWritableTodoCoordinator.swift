//
//  SwiftUIEditableTodoCoordinator.swift
//  todoApp
//
//  Created by 조영태 on 7/14/25.
//

import SwiftUI
import Combine

class SwiftUIWritableTodoCoordinator: ObservableObject {
    @Published var path: NavigationPath
    let writeOnCompleted = PassthroughSubject<(TodoModel, WritableScene), Never>()

    var cancellables = Set<AnyCancellable>()
    
    private let diContainer:EditableTodoDIContainer
    private let type: WritableScene
    
    init(type: WritableScene, _ diContainer:EditableTodoDIContainer) {
        self.path = NavigationPath()
        self.diContainer = diContainer
        self.type = type
    }
    
    @ViewBuilder
    func buildMain() -> some View {
        buildScence(type)
    }
    
    @ViewBuilder
    func buildScence(_ scene: WritableScene) -> some View {
        switch scene {
        case .create:
            buildCreateView()
        case .edit(let todo):
            buildEditView(todo)
        }
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
    
    private func bindWrittenTodo(_ vm:any WritableTodoPublisher) {
        vm.writtenTodoPublisher
            .compactMap { $0 }
            .withUnretained(self)
            .sink { (self, value) in
                self.writeOnCompleted.send((value, self.type))
            }
            .store(in: &cancellables)
    }
}

