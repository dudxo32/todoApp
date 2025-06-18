//
//  WriteableTodoVMSwiftUI.swift
//  todoApp
//
//  Created by 조영태 on 6/13/25.
//

import SwiftUI
import Combine

struct WriteableState {
    var title: String
    var date: Date?
    var content :String
    
    var isValid: Bool {
        !title.isEmpty && date != nil
    }
    
    func copyWith(
        title: String? = nil,
        date: Date? = nil,
        contents: String? = nil
    ) -> WriteableState {
        return WriteableState(
            title: title ?? self.title,
            date: date ?? self.date,
            content: contents ?? self.content
        )
    }
}

enum WritableAction {
    case titleInput(_ value:String)
    case dateInput(_ value: Date)
    case content(_ value: String)
    case doWrite
}

protocol WritableTodoVMSwiftUI {
    var state: WriteableState { get }
    var error: Error? { get }
    var writtenTodo: TodoModel? { get }
}

class AnyWritableTodoVMSwiftUI: WritableTodoVMSwiftUI {
    var state: WriteableState {
        get { base.state }
        set { base.input(newValue) }
    }
    var bindingState:Binding<WriteableState>

    var writtenTodo:TodoModel? {
        get { base.writtenTodo }
    }
    private let base: any WritableConcrete

    private(set) var error: (any Error)?
    
    private let _action: (WritableAction) -> Void
    private var cancellables = Set<AnyCancellable>()

    init<VM: WritableConcrete>(_ base: VM) {    
        self.base = base
        self.error = base.error
        self._action = base.action

        self.bindingState = Binding(
            get: { base.state },
            set: { base.input($0) }
        )
    }
}

protocol WritableConcrete: WritableTodoVMSwiftUI, ViewModelableSwiftUI where Action == WritableAction  {
    func input(_ s:WriteableState) -> Void
    func inputWritten(_ w:TodoModel?) -> Void
}

class CreateTodoVMSwiftUI: WritableConcrete {
    struct UseCase {
        let addTodo: any AddTodoUseCase
    }

    @Published var state:WriteableState
    @Published private(set) var error: Error?
    @Published private(set) var writtenTodo: TodoModel?

    private let useCase: UseCase
    var cancellables = Set<AnyCancellable>()

    var statePublisher: Published<WriteableState>.Publisher { $state }
    var writtenTodoPublisher: Published<TodoModel?>.Publisher { $writtenTodo }
    
    func input(_ s: WriteableState) {
        state = s
    }
    
    func inputWritten(_ w: TodoModel?) {
        writtenTodo = w
    }
    
    init(_ useCase: UseCase) {
        self.state = WriteableState(title: "", date: nil, content: "")
        
        self.useCase = useCase
    }
    
    func action(_ action: Action) {
        switch action {
        case .titleInput(let value):
            state = state.copyWith(title: value)
            break
            
        case .dateInput(let value):
            state = state.copyWith(date: value)
            break
            
        case .content(let value):
            state = state.copyWith(contents: value)
            break
            
        case .doWrite:
            bindCreate()
            break
            
        }
    }
    
    private func bindCreate() {
        handleCreate()
            .receive(on: DispatchQueue.main)
            .catch { [weak self] error  in
                self?.error = error
                return Combine.Empty<TodoModel, Never>()
            }
            .withUnretained(self)
            .sink { (self, value) in self.writtenTodo = value }
            .store(in: &cancellables)
    }
    
    fileprivate func handleCreate() -> AnyPublisher<TodoModel, Error> {
        return Deferred {
            return  Future<TodoModel, Error> {[weak self] promise in
                guard let self = self, let date = self.state.date else { return }
                
                Task  {
                    do {
                        let res = try await self.useCase.addTodo.execute(
                            title: self.state.title,
                            contents: self.state.content,
                            date: date
                        )
                        
                        promise(.success(TodoMapper.toModel(res)))
                    } catch  {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
