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

enum WriteableAction {
    case titleInput(_ value:String)
    case dateInput(_ value: Date)
    case content(_ value: String)
    case doWrite
}

protocol WritableTodoVMSwiftUI: ObservableObject, ViewModelableSwiftUI where Action == WriteableAction {
    var state: WriteableState { get }
    var error: Error? { get }
    var writenTodo: TodoModel? { get }
}

class CreateTodoVMSwiftUI: WritableTodoVMSwiftUI {
    struct UseCase {
        let addTodo: any AddTodoUseCase
    }
    
    @Published var state:WriteableState
    @Published private(set) var error: Error?
    @Published private(set) var writenTodo: TodoModel?

    private let useCase: UseCase
    var cancellables = Set<AnyCancellable>()

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
            .sink { (self, value) in self.writenTodo = value }
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
