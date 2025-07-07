//
//  WriteableTodoVMSwiftUI.swift
//  todoApp
//
//  Created by 조영태 on 6/13/25.
//

import Combine
import SwiftUI

struct WriteableState {
    var title: String
    var date: Date?
    var content: String

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
    case titleInput(_ value: String)
    case dateInput(_ value: Date)
    case content(_ value: String)
    case doWrite
}

protocol ActionObservableObject: ViewModelObservableObject
where Action == WritableAction {}

protocol WritableTodoOutput: ObservableObject {
    var state: WriteableState { get set }
    var error: Error? { get }
    var writtenTodo: TodoModel? { get }
}
/*
class AnyWritableTodoVMSwiftUI: ActionObservableObject, WritableTodo {
    private let base: any WritableConcrete
    private let _action: (WritableAction) -> Void

    var state: WriteableState {
        get { base.state }
        set { base.setState(newValue) }
    }

    var writtenTodo:TodoModel? {
        get { base.writtenTodo }
    }

    var error: (any Error)? {
        get { base.error }
    }

    init(_ base: any WritableConcrete) {
        self.base = base
        self._action = base.action
    }

    func action(_ action: WritableAction) {
        _action(action)
    }
}

protocol WritableConcrete: WritableTodo, ActionObservableObject {
    func setState(_ value:WriteableState) -> Void
}
*/
class CreateTodoVMSwiftUI: ActionObservableObject, WritableTodoOutput,
    LoadingProtocolSwiftUI
{
    struct UseCase {
        let addTodo: any AddTodoUseCase
    }

    @Published var state: WriteableState
    @Published private(set) var error: Error?
    @Published private(set) var writtenTodo: TodoModel?
    @Published private(set) var isShowLoadingIndicator: Bool = false

    private let useCase: UseCase
    var cancellables = Set<AnyCancellable>()

    init(_ useCase: UseCase) {
        self.state = WriteableState(title: "", date: nil, content: "")
        self.useCase = useCase
    }

    func setState(_ value: WriteableState) {
        state = value
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
            .handleLoadingWithUnretained(self) { this, value in
                self.isShowLoadingIndicator = value
            }
            .catchWithUnretained(self) { this, error in
                this.error = error
                return Combine.Empty<TodoModel, Never>()
            }
            .withUnretained(self)
            .sink { (self, value) in self.writtenTodo = value }
            .store(in: &cancellables)
    }

    fileprivate func handleCreate() -> AnyPublisher<TodoModel, Error> {
        return Deferred {
            return Future<TodoModel, Error> { [weak self] promise in
                guard let self = self, let date = self.state.date else {
                    return
                }

                Task {
                    do {
                        let res = try await self.useCase.addTodo.execute(
                            title: self.state.title,
                            contents: self.state.content,
                            date: date
                        )

                        promise(.success(TodoMapper.toModel(res)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

class EditTodoVMSwiftUI: ActionObservableObject, WritableTodoOutput {
    struct UseCase {
        let editTodo: any EditTodoUseCase
    }

    @Published var state: WriteableState
    @Published private(set) var error: Error?
    @Published private(set) var writtenTodo: TodoModel?

    private let todo: TodoModelProtocol
    private let useCase: UseCase
    var cancellables = Set<AnyCancellable>()

    init(_ todo: TodoModelProtocol, useCase: UseCase) {
        self.todo = todo
        self.state = WriteableState(
            title: todo.title, date: todo.date, content: todo.contents)
        self.useCase = useCase
    }

    func setState(_ value: WriteableState) {
        state = value
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
            bindEdit()
            break

        }
    }

    private func bindEdit() {
        handleEdit()
            .receive(on: DispatchQueue.main)
            .catchWithUnretained(self) { this, error in
                this.error = error
                return Combine.Empty<TodoModel, Never>()
            }
            .withUnretained(self)
            .sink { (self, value) in self.writtenTodo = value }
            .store(in: &cancellables)
    }

    private func handleEdit() -> AnyPublisher<TodoModel, Error> {
        return Deferred {
            return Future<TodoModel, Error> { [weak self] promise in
                guard let self = self else { return }

                Task {
                    do {
                        let entity = TodoMapper.toEntity(self.todo)
                        let res = try await self.useCase.editTodo.execute(
                            entity,
                            newTitle: self.state.title,
                            newDate: self.state.date,
                            newContents: self.state.content
                        )

                        promise(.success(TodoMapper.toModel(res)))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
