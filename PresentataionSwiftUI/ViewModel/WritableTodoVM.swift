//
//  WriteableTodoVMSwiftUI.swift
//  todoApp
//
//  Created by 조영태 on 6/13/25.
//

import Combine
import Domain
import PresentationShared
import Shared
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
    case retryAction(_ value: RetryAction)
}

enum WritableType {
    case create, edit
}

protocol WritableTodoOutput: ObservableObject {
    var state: WriteableState { get set }
    var retryError: Error? { get }
    var error: Error? { get }
    var writtenTodo: TodoModel? { get }
    var writtenTodoPublisher: Published<TodoModel?>.Publisher { get }
}

protocol WritableTodoPublisher {
    var writtenTodoPublisher: Published<TodoModel?>.Publisher { get }
}

protocol WritableViewModelProtocol: ViewModelObservableObject,
    WritableTodoOutput, WritableTodoPublisher, RetryProtocol,
    LoadingProtocol
where Action == WritableAction {
    var type: WritableType { get }
}

public class CreateTodoVM: WritableViewModelProtocol, LoadingProtocol {
    public struct UseCase {
        let addTodo: any AddTodoUseCase
        
        public init(addTodo: any AddTodoUseCase) {
            self.addTodo = addTodo
        }
    }

    @Published var state: WriteableState
    @Published private(set) var error: Error?
    @Published private(set) var retryError: Error?
    @Published private(set) var writtenTodo: TodoModel?
    @Published private(set) var isShowLoadingIndicator: Bool = false
    var writtenTodoPublisher: Published<TodoModel?>.Publisher {
        $writtenTodo
    }

    private let useCase: UseCase
    var cancellables = Set<AnyCancellable>()
    let retryTrigger = PassthroughSubject<RetryAction, Never>()
    var type: WritableType = .create

    public init(_ useCase: UseCase) {
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

        case .retryAction(let value):
            retryTrigger.send(value)
        }
    }

    private func bindCreate() {
        func createWithErrorHandle() -> AnyPublisher<TodoModel, Never> {
            return handleCreate()
                .saveError(
                    onTodoError: { [weak self] in self?.error = $0 },
                    onError: { [weak self] in self?.retryError = $0 }
                )
                .retryHandler(
                    self,
                    retryFunc: { this in
                        return this.retryTrigger.retry(
                            retry: { createWithErrorHandle() },
                            none: { [weak self] in self?.retryError = nil }
                        )
                    }
                )
                .eraseToAnyPublisher()
        }

        createWithErrorHandle()
            .receive(on: DispatchQueue.main)
            .handleLoadingWithUnretained(self) { this, value in
                self.isShowLoadingIndicator = value
            }
            .withUnretained(self)
            .sink { (self, value) in
                self.writtenTodo = value
            }
            .store(in: &cancellables)
    }

    fileprivate func handleCreate() -> AnyPublisher<TodoModel, AppError> {
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
        .mapAppError()
        .eraseToAnyPublisher()
    }
}

class MockCreateTodoVM: CreateTodoVM {
    convenience init() {
        let mockRepo = MockTodoRepository()
        let useCase = CreateTodoVM.UseCase.init(
            addTodo: DefaultAddTodoUseCase(repository: mockRepo)
        )
        
        self.init(useCase)
    }
}

public class EditTodoVM: WritableViewModelProtocol {
    public struct UseCase {
        let editTodo: any EditTodoUseCase
        
        public init(editTodo: any EditTodoUseCase) {
            self.editTodo = editTodo
        }
    }

    @Published var state: WriteableState
    @Published private(set) var error: Error?
    @Published private(set) var retryError: Error?
    @Published private(set) var writtenTodo: TodoModel?
    var writtenTodoPublisher: Published<TodoModel?>.Publisher {
        $writtenTodo
    }

    private let todo: any TodoModelProtocol
    private let useCase: UseCase
    var cancellables = Set<AnyCancellable>()
    let retryTrigger = PassthroughSubject<RetryAction, Never>()
    var isShowLoadingIndicator: Bool = false
    var type: WritableType = .edit

    public init(_ todo: any TodoModelProtocol, useCase: UseCase) {
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

        case .retryAction(let value):
            retryTrigger.send(value)
        }
    }

    private func bindEdit() {
        func editWithErrorHandle() -> AnyPublisher<TodoModel, Never> {
            return handleEdit()
                .saveError(
                    onTodoError: { [weak self] in self?.error = $0 },
                    onError: { [weak self] in self?.retryError = $0 }
                )
                .retryHandler(
                    self,
                    retryFunc: { this in
                        return this.retryTrigger.retry(
                            retry: { editWithErrorHandle() },
                            none: { [weak self] in self?.retryError = nil }
                        )
                    }
                )
                .eraseToAnyPublisher()
        }

        editWithErrorHandle()
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { (self, value) in self.writtenTodo = value }
            .store(in: &cancellables)
    }

    private func handleEdit() -> AnyPublisher<TodoModel, AppError> {
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
        .mapAppError()
        .eraseToAnyPublisher()
    }
}
