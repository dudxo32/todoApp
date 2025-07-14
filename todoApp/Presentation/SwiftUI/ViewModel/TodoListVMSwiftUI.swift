//
//  TodoListVM.swift
//  todoApp
//
//  Created by 조영태 on 6/5/25.
//

import SwiftUI
import Combine

class TodoListVMSwiftUI: ViewModelObservableObject, LoadingProtocolSwiftUI {
    struct UseCase {
        let fetch: any FetchTodoUseCase
        let delete: any DeleteTodoUseCase
        let toggleDone: any ToggleTodoDoneUseCase
        let cache: TodoListCache
    }
    
    enum Action {
        case fetchItems
        case addedItem(_ value: TodoModel)
        case edittedItem(_ value: TodoModel)
        case tapDelete(_ value: TodoModel)
        case tapFilter(_ value: TodoFilterType)
        case toggleDone(_ value: TodoModel)
        case retryTrigger
        case presentModal(_ value: SUI.WritableScene)
    }
    
    private let useCase: UseCase
    var cancellables = Set<AnyCancellable>()
    private let retryTrigger = PassthroughSubject<Void, Never>()

    @Published private(set) var item = [TodoSection]()
    @Published private(set) var selectedFilter:TodoFilterType
    @Published private(set) var error: Error?
    @Published private(set) var serverError: Error?
    @Published private(set) var isShowLoadingIndicator: Bool = false
    let presentModel = PassthroughSubject<SUI.WritableScene?, Never>()
    
    @Published fileprivate var allItmes = [TodoModel]()
    @Published private var cachedGroup:TodoGroup = [:]
    

    init(_ useCase:UseCase, initFilter:TodoFilterType) {
        self.useCase = useCase
        self.selectedFilter = initFilter        
        
        $item.print().sink { _ in
            
        }.store(in: &cancellables)

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
        case .retryTrigger:
            retryTrigger.send(())
            break
        case .presentModal(let value):
            presentModel.send(value)
        }
    }
    
    private func bindFetchItemsToAll() {
        func fetchWithErrorHandle() -> AnyPublisher<[TodoModel], Never> {
            return handleFetching()
                .catchWithUnretained(self) { this, error in
                    guard error is TodoError else {
                        this.serverError = error

                        return this.retryTrigger
                            .retry {  fetchWithErrorHandle() }
                    }
                    
                    this.error = error
                    return Combine.Empty<[TodoModel], Never>()
                        .eraseToAnyPublisher()
                }
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
                self.isShowLoadingIndicator = false
            }
            .store(in: &cancellables)
    }
    
    private func bindToggleDone(_ todo:TodoModel) {
        func changedWithErrorHandle() -> AnyPublisher<[TodoModel], Never> {
            return handleChanged(todo)
                .catchWithUnretained(self) { this, error in
                    guard let todoError = error as? TodoError else {
                        
                        this.serverError = error

                        return this.retryTrigger
                            .retry {  changedWithErrorHandle() }
                    }
                    
                    this.error = todoError
                    return Combine.Empty<[TodoModel], Never>().eraseToAnyPublisher()
                }
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
    
    private func bindAddedTodo(_ todo:TodoModel) {
        
        let list = self.allItmes.map { TodoMapper.toEntity($0) }
        let targetEntity = TodoMapper.toEntity(todo)
        let response = self.useCase.cache.addItemInList(targetEntity, list: list).map(
            TodoMapper.toModel
        )
        
        self.allItmes = response
    }
    
    private func bindDelete(_ todo:TodoModel) {
        func deleteWithErrorHandle() -> AnyPublisher<[TodoModel], Never> {
            return handleDelete(todo)
                .catchWithUnretained(self) { this, error in
                    guard error is TodoError else {
                        this.serverError = error

                        return this.retryTrigger
                            .retry {  deleteWithErrorHandle() }
                    }
                    
                    this.error = error
                    return Combine.Empty<[TodoModel], Never>()
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }
        
        deleteWithErrorHandle()
            .receive(on: DispatchQueue.main)
            .withUnretained(self)
            .sink { (self, value) in self.allItmes = value }
            .store(in: &cancellables)
    }
    
    private func bindEdited(_ todo:TodoModel) {
        do {
            let list = self.allItmes.map { TodoMapper.toEntity($0) }
            let targetEntity = TodoMapper.toEntity(todo)
            let response = try self.useCase.cache.changeItemInList(targetEntity, list: list).map(
                TodoMapper.toModel
            )
            
            self.allItmes = response
        } catch {
            self.error = error
        }
    }
    
    private func handleFetching() -> AnyPublisher<[TodoModel], Error> {
        return Deferred {
            return  Future<[TodoModel], Error> { promise in
                Task  {
                    do {
                        let r = try await self.useCase.fetch.execute().map(
                            TodoMapper.toModel
                        )
                        promise(.success(r))
                    } catch  {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func handleChanged(_ todo:TodoModelProtocol) -> AnyPublisher<[TodoModel], Error> {
        return Deferred {
            return Future<[TodoModel], Error> { [weak self] promise in
                guard let self = self else { return }

                Task  {
                    do {
                        let list = self.allItmes.map { TodoMapper.toEntity($0) }
                        let changedTodo = TodoMapper.toEntity(todo)
                        let res = try await self.useCase.toggleDone.execute(changedTodo, list: list)
                        let models = res.map{ TodoMapper.toModel($0) }

                        promise(.success(models))
                    } catch  {
                        promise(.failure(error))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func handleDelete(_ target:TodoModel) -> AnyPublisher<[TodoModel], Error> {
        return Deferred {
            return Future<[TodoModel], Error> { promise in
                Task {
                    do {
                        let list = self.allItmes.map { TodoMapper.toEntity($0) }
                        let targetEntity = TodoMapper.toEntity(target)

                        let res = try await self.useCase.delete.execute(
                            targetEntity,
                            list: list
                        )
                        
                        promise( .success(res.map(TodoMapper.toModel)) )
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }
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

class MTodoListVMSwiftUI: TodoListVMSwiftUI {
    init(_ value:[TodoModel]) {
        let dataSource = TodoLocalDataSource()
        let repo = TodoRepositoryImpl(dataSource)

        let cache = TodoListCache()

        let useCase = TodoListVMSwiftUI.UseCase(
            fetch: DefaultFetchTodoUseCase(repo),
            delete: DefaultDeleteTodoUseCase(repo, cache: cache),
            toggleDone: DefaultToggleTodoDoneUseCase(repo, cache: cache),
            cache: cache
        )
        
        super.init(useCase, initFilter: .today)
        
        self.allItmes = value
    }
}
