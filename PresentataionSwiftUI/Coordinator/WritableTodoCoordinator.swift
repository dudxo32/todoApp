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
        
    private let diContainer:WritableTodoDIContainerProtocol
    private let type: WritableScene
        
    init(type: WritableScene,
         appDiContainer: AppDIContainerProtocol
    ) {
        self.path = NavigationPath()
        self.diContainer = appDiContainer.makeWritableDIContainer()
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
        
    @ViewBuilder
    private func buildCreateView() -> some View {
        diContainer.makeCreatableTodoScene(env: .local) {
            self.bindWrittenTodo($0)
        }
    }
            
    @ViewBuilder
    private func buildEditView(_ todo: TodoModel) -> some View {
        diContainer.makeEditableTodoScene(todo: todo, env: .local) {
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
