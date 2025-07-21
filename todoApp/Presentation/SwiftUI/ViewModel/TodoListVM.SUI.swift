//
//  TodoListVM.swift
//  todoApp
//
//  Created by 조영태 on 6/5/25.
//

import SwiftUI
import Combine
import Domain
import Shared

extension SUI {
    class TodoListVM: ViewModelObservableObject, SUI.LoadingProtocol {
        struct UseCase {
            let fetch: any FetchTodoUseCase
            let delete: any DeleteTodoUseCase
            let toggleDone: any ToggleTodoDoneUseCase
            let cache: TodoListCacheUseCase
        }

        enum Action {
            case fetchItems
            case addedItem(_ value: TodoModel)
            case edittedItem(_ value: TodoModel)
            case tapDelete(_ value: TodoModel)
            case tapFilter(_ value: TodoFilterType)
            case toggleDone(_ value: TodoModel)
            case retryTrigger(_value: RetryAction)
            case presentModal(_ value: SUI.WritableScene)
        }

        private let useCase: UseCase
        var cancellables = Set<AnyCancellable>()
        private let retryTrigger = PassthroughSubject<RetryAction, Never>()

        @Published private(set) var item = [TodoSection]()
        @Published private(set) var selectedFilter: TodoFilterType
        @Published private(set) var error: Error?
        @Published private(set) var serverError: Error?
        @Published private(set) var isShowLoadingIndicator: Bool = false
        let presentModel = PassthroughSubject<SUI.WritableScene?, Never>()

        @Published fileprivate var allItmes = [TodoModel]()
        @Published private var cachedGroup: TodoGroup = [:]

        init(_ useCase: UseCase, initFilter: TodoFilterType) {
            self.useCase = useCase
            self.selectedFilter = initFilter

            $allItmes
                .map(makeTapGroup)
                .assign(to: &($cachedGroup))

            $cachedGroup.combineLatest($selectedFilter) { group, filter in
                func makeSectionByDate(_ todos: [TodoModel]) -> [TodoSection] {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy/MM/dd"
                    formatter.locale = Locale(identifier: "ko_KR")

                    let grouped = Dictionary(grouping: todos) { todo in
                        formatter.string(from: todo.date)
                    }

                    let sections =
                        grouped
                        .map { key, value in
                            TodoSection(header: key, items: value)
                        }
                        .sorted { $0.header < $1.header }  // 날짜순 정렬

                    return sections
                }

                let arr = group[filter] ?? []
                return makeSectionByDate(arr)
            }
            .assign(to: &($item))
        }

        func action(_ action: Action) {
            switch action {
            case .fetchItems:
                bindFetchItemsToAll()
                break
            case .addedItem(let value):
                bindAddedTodo(value)
                break
            case .edittedItem(let value):
                bindEdited(value)
                break
            case .tapDelete(let value):
                bindDelete(value)
                break
            case .tapFilter(let value):
                self.selectedFilter = value
                break
            case .toggleDone(let value):
                bindToggleDone(value)
                break
            case .retryTrigger(let value):
                retryTrigger.send(value)
                break
            case .presentModal(let value):
                presentModel.send(value)
            }
        }

        private func bindFetchItemsToAll() {
            func fetchWithErrorHandle() -> AnyPublisher<[TodoModel], Never> {
                return handleFetching()
                    .receive(on: DispatchQueue.main)                    
                    .saveError(onError: { [weak self] error in
                        self?.serverError = error
                    })
                    .retryHandler(self, retryFunc: { this in
                        return this.retryTrigger.retry(
                            retry: { fetchWithErrorHandle() },
                            none: { [weak self] in self?.serverError = nil }
                        )
                    })
                    .eraseToAnyPublisher()
            }

            fetchWithErrorHandle()
                .receive(on: DispatchQueue.main)
                .handleLoadingWithUnretained(self) { this, isLoading in
                    this.isShowLoadingIndicator = isLoading
                }
                .withUnretained(self)
                .sink { (self, value) in
                    self.allItmes = value
                }
                .store(in: &cancellables)
        }

        private func bindToggleDone(_ todo: TodoModel) {
            func changedWithErrorHandle() -> AnyPublisher<[TodoModel], Never> {
                return handleChanged(todo)
                    .receive(on: DispatchQueue.main)
                    .saveError(
                        onTodoError: { [weak self] in self?.error = $0 },
                        onError: { [weak self] in self?.serverError = $0 }
                    )
                    .retryHandler(self, retryFunc: { this in
                        return this.retryTrigger.retry(
                            retry: { changedWithErrorHandle() },
                            none: { [weak self] in self?.serverError = nil }
                        )
                    })
                    .eraseToAnyPublisher()
            }

            changedWithErrorHandle()
                .receive(on: DispatchQueue.main)
                .withUnretained(self)
                .sink { (self, value) in
                    self.allItmes = value
                }
                .store(in: &cancellables)
        }

        private func bindAddedTodo(_ todo: TodoModel) {

            let list = self.allItmes.map { TodoMapper.toEntity($0) }
            let targetEntity = TodoMapper.toEntity(todo)
            let response = self.useCase.cache.addItemInList(
                targetEntity, list: list
            ).map(
                TodoMapper.toModel
            )

            self.allItmes = response
        }

        private func bindDelete(_ todo: TodoModel) {
            func deleteWithErrorHandle() -> AnyPublisher<[TodoModel], Never> {
                return handleDelete(todo)
                    .saveError(
                        onTodoError: { [weak self] in self?.error = $0 },
                        onError: { [weak self] in self?.serverError = $0 }
                    )
                    .retryHandler(self, retryFunc: { this in
                        return this.retryTrigger.retry(
                            retry: { deleteWithErrorHandle() },
                            none: { [weak self] in self?.serverError = nil }
                        )
                    })
                    .eraseToAnyPublisher()
            }

            deleteWithErrorHandle()
                .receive(on: DispatchQueue.main)
                .withUnretained(self)
                .sink { (self, value) in self.allItmes = value }
                .store(in: &cancellables)
        }

        private func bindEdited(_ todo: TodoModel) {
            do {
                let list = self.allItmes.map { TodoMapper.toEntity($0) }
                let targetEntity = TodoMapper.toEntity(todo)
                let response = try self.useCase.cache.changeItemInList(
                    targetEntity, list: list
                ).map(
                    TodoMapper.toModel
                )

                self.allItmes = response
            } catch let error as TodoListCacheUseCase.Error {
                switch error {
                case .notFound:
                    self.error = AppError.todo(.notFound)
                }
            } catch {
                self.error = AppError.unknown
            }
        }

        private func handleFetching() -> AnyPublisher<[TodoModel], AppError> {
            return Deferred {
                return Future<[TodoModel], Error> { promise in
                    Task {
                        do {
                            let r = try await self.useCase.fetch.execute().map(
                                TodoMapper.toModel
                            )
                            promise(.success(r))
                        } catch {
                            promise(.failure(error))
                        }
                    }
                }
            }
            .mapError { AppError.mapper($0) }
            .eraseToAnyPublisher()
        }

        private func handleChanged(_ todo: TodoModelProtocol) -> AnyPublisher<
            [TodoModel], AppError
        > {
            return Deferred {
                return Future<[TodoModel], Error> { [weak self] promise in
                    guard let self = self else { return }

                    Task {
                        do {
                            let list = self.allItmes.map {
                                TodoMapper.toEntity($0)
                            }
                            let changedTodo = TodoMapper.toEntity(todo)
                            let res = try await self.useCase.toggleDone.execute(
                                changedTodo,
                                list: list
                            )
                            let models = res.map { TodoMapper.toModel($0) }

                            promise(.success(models))
                        } catch {
                            promise(.failure(error))
                        }
                    }
                }
            }
            .mapAppError()
            .eraseToAnyPublisher()
        }

        private func handleDelete(_ target: TodoModel) -> AnyPublisher<
            [TodoModel], AppError
        > {
            return Deferred {
                return Future<[TodoModel], Error> { promise in
                    Task {
                        do {
                            let list = self.allItmes.map {
                                TodoMapper.toEntity($0)
                            }
                            let targetEntity = TodoMapper.toEntity(target)

                            let res = try await self.useCase.delete.execute(
                                targetEntity,
                                list: list
                            )

                            promise(.success(res.map(TodoMapper.toModel)))
                        } catch {
                            promise(.failure(error))
                        }
                    }
                }
            }
            .mapAppError()
            .eraseToAnyPublisher()
        }

        // MARK: -
        private func makeTapGroup(_ items: [TodoModel]) -> TodoGroup {
            return Dictionary(grouping: items) { item in
                let comparison = Calendar.current.compare(
                    item.date,
                    to: Date(),
                    toGranularity: .day
                )

                switch comparison {
                case .orderedAscending:
                    return TodoFilterType.past
                case .orderedSame:
                    return TodoFilterType.today
                case .orderedDescending:
                    return TodoFilterType.future
                }
            }
        }
    }

    class MTodoListVM: SUI.TodoListVM {
        init(_ value: [TodoModel]) {
            let repo = MockTodoRepository(value: value.map(TodoMapper.toEntity))

            let cache = TodoListCacheUseCase()

            let useCase = SUI.TodoListVM.UseCase(
                fetch: DefaultFetchTodoUseCase(repo),
                delete: DefaultDeleteTodoUseCase(repo, cache: cache),
                toggleDone: DefaultToggleTodoDoneUseCase(repo, cache: cache),
                cache: cache
            )

            super.init(useCase, initFilter: .today)
        }
    }

}

extension Publisher where Failure == AppError {
    func saveError(
        onTodoError: @escaping (AppError.Todo) -> Void = {_ in},
        onError: @escaping (AppError) -> Void = {_ in}
    ) -> Publishers.HandleEvents<Self> {
        
        self.handleEvents(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                switch error {
                case .todo(let error):
                    onTodoError(error)

                case .serverError, .unknown:
                    onError(error)
                }
            }
        })
    }
    
    func retryHandler<Object: AnyObject>(
        _ object: Object,
        retryFunc: @escaping (_ this: Object) -> AnyPublisher<Output, Never>
    ) -> AnyPublisher<Output, Never> {

        return self.catch { [weak object] error in
            guard let object = object else {
                return Empty<Output, Never>().eraseToAnyPublisher()
            }

            switch error {
            case .todo:
                return Empty<Output, Never>().eraseToAnyPublisher()

            case .serverError, .unknown:
                return retryFunc(object).eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher {
    func mapAppError() -> Publishers.MapError<Self, AppError> {
        return self.mapError { error in
            if let todoError = error as? TodoError {
                switch todoError {
                case .localNotFound:
                    return .todo(.notFound)
                }
            }

            return AppError.mapper(error)
        }
    }
}
