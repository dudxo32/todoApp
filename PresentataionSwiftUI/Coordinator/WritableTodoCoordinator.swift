//
//  SwiftUIEditableTodoCoordinator.swift
//  todoApp
//
//  Created by 조영태 on 7/14/25.
//

import SwiftUI
import Combine
import PresentationShared
import DataLayer

public protocol WritableTodoDIContainerProtocol {
    func makeCreatableTodoScene(
        env: DataEnvironment,
        setup: ((_ vm: CreateTodoVM) -> Void)?
    ) -> CreateTodoVC

    func makeEditableTodoScene(
        todo: any TodoModelProtocol,
        env: DataEnvironment,
        setup: ((_ vm: EditTodoVM) -> Void)?
    ) -> EditTodoVC
}

class WritableTodoCoordinator: ObservableObject {
    @Published var path: NavigationPath
    let writeOnCompleted = PassthroughSubject<(TodoModel, WritableScene), Never>()

    var cancellables = Set<AnyCancellable>()
        
    private let appDiContainer: AppDIContainerProtocol
//    private let diContainer:WritableTodoDIContainerProtocol
    private let type: WritableScene
        
    init(type: WritableScene,
         appDiContainer: AppDIContainerProtocol
//         _ diContainer:WritableTodoDIContainerProtocol
    ) {
        self.path = NavigationPath()
//        self.diContainer = diContainer
        self.type = type
        self.appDiContainer = appDiContainer
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
        
    @ViewBuilder
    private func buildCreateView() -> some View {
        let container = appDiContainer.makeWritableDIContainer()
        
        container.makeCreatableTodoScene(env: .local) {
            self.bindWrittenTodo($0)
        }
    }
            
    @ViewBuilder
    private func buildEditView(_ todo: TodoModel) -> some View {
        let container = appDiContainer.makeWritableDIContainer()
        
        container.makeEditableTodoScene(todo: todo, env: .local) {
            self.bindWrittenTodo($0)
        }
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
