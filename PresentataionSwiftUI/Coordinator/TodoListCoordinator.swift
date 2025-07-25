//
//  SwiftUICoordinator.swift
//  todoApp
//
//  Created by 조영태 on 7/9/25.
//

import Combine
import SwiftUI
import DataLayer
import PresentationShared

public enum AppScene {
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

public protocol TodoListDIContainerProcotcol {
    func makeTodoListScene(
        initFilter: TodoFilterType,
        env: DataEnvironment,
        setup: ((_ vm: TodoListVM) -> Void)?
    ) -> TodoListVC
}

public class TodoListCoordinator: ObservableObject {
    @Published var path: NavigationPath
    @Published fileprivate var modalScene: WritableScene? = nil
        
    private let initalScence: AppScene
    private let appDiContainer: AppDIContainerProtocol
    private let diContainer: TodoListDIContainerProcotcol
        
    private var writableCoordinator: WritableTodoCoordinator? = nil
    private let writtenTodo = PassthroughSubject<(TodoModel, WritableScene), Never>()

    private var cancellables = Set<AnyCancellable>()

    public init(
        initalScene: AppScene,
        appDiContaeinr:AppDIContainerProtocol,
        diContainer: TodoListDIContainerProcotcol
    ) {
        self.path = NavigationPath()
        self.initalScence = initalScene
        self.appDiContainer = appDiContaeinr
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
            let container = appDiContainer.makeTodoListDIContainer()
            
//            container
            diContainer
                .makeTodoListScene(initFilter: .today, env: .local) { vm in
                self.bindTodoListScene(vm)
            }
        }
    }
        
    func bindTodoListScene(_ vm:TodoListVM) {
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
        let coordinator = WritableTodoCoordinator(
            type: scene,
            appDiContainer: appDiContainer
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

public struct CoordinatorScene: View {
    @StateObject var coordinator: TodoListCoordinator

    public init(coordinator: TodoListCoordinator) {
        self._coordinator = .init(wrappedValue: coordinator)
    }
    
    public var body: some View {
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
