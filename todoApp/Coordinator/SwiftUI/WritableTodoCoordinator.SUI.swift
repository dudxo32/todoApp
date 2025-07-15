//
//  SwiftUIEditableTodoCoordinator.swift
//  todoApp
//
//  Created by 조영태 on 7/14/25.
//

import SwiftUI
import Combine

extension SUI {
    class WritableTodoCoordinator: ObservableObject {
        @Published var path: NavigationPath
        let writeOnCompleted = PassthroughSubject<(TodoModel, SUI.WritableScene), Never>()

        var cancellables = Set<AnyCancellable>()
        
        private let diContainer:SUI.WritableTodoDIContainer
        private let type: SUI.WritableScene
        
        init(type: SUI.WritableScene, _ diContainer:SUI.WritableTodoDIContainer) {
            self.path = NavigationPath()
            self.diContainer = diContainer
            self.type = type
        }
        
        @ViewBuilder
        func buildMain() -> some View {
            buildScence(type)
        }
        
        @ViewBuilder
        func buildScence(_ scene: SUI.WritableScene) -> some View {
            switch scene {
            case .create:
                buildCreateView()
            case .edit(let todo):
                buildEditView(todo)
            }
        }
        
        @ViewBuilder
        private func buildCreateView() -> some View {
            diContainer.makeCreatableTodoScene() {
                self.bindWrittenTodo($0)
            }
        }
            
        @ViewBuilder
        private func buildEditView(_ todo: TodoModel) -> some View {
            diContainer.makeEditableTodoScene(todo: todo) {
                self.bindWrittenTodo($0)
            }
        }
        
        private func bindWrittenTodo(_ vm:any WritableTodoPublisher) {
            vm.writtenTodoPublisher.print().sink { _ in
                
            }.store(in: &cancellables)
            
            vm.writtenTodoPublisher
                .compactMap { $0 }
                .withUnretained(self)
                .sink { (self, value) in
                    self.writeOnCompleted.send((value, self.type))
                }
                .store(in: &cancellables)
        }
    }


}
