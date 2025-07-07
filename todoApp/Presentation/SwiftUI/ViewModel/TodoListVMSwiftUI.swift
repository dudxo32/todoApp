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
        case retryTrigger(_ value: RetryAction)
    }
    
    private let useCase: UseCase
    var cancellables = Set<AnyCancellable>()
    
    @Published private(set) var item = [TodoSection]()
    @Published private(set) var selectedFilter:TodoFilterType
    @Published private(set) var error: Error?
    @Published private(set) var isShowLoadingIndicator: Bool = false
    
    @Published fileprivate var allItmes = [TodoModel]()
    @Published private var cachedGroup:TodoGroup = [:]
    
    init(_ useCase:UseCase, initFilter:TodoFilterType) {
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
            break
            
        }
    }
    
    private func bindFetchItemsToAll() {
        handleFetching()
            .receive(on: DispatchQueue.main)
            .handleLoadingWithUnretained(self) { this, isLoading in
                this.isShowLoadingIndicator = isLoading
            }
            .catchWithUnretained(self) { this, error in
                this.error = error
                return Combine.Empty<[TodoModel], Never>()
            }
            .withUnretained(self)
            .sink { (self, value) in
                self.allItmes = value
                self.isShowLoadingIndicator = false
            }
            .store(in: &cancellables)
    }
    
    private func bindToggleDone(_ todo:TodoModel) {
        handleChanged(todo)
            .receive(on: DispatchQueue.main)
            .retry(3)
            .catchWithUnretained(self) { this, error in
                this.error = error
                return Combine.Empty<[TodoModel], Never>()
            }
            .withUnretained(self)
            .sink { (self, value) in self.allItmes = value }
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
        handleDelete(todo)
            .receive(on: DispatchQueue.main)
            .catchWithUnretained(self) { this, error in
                this.error = error
                return Combine.Empty<[TodoModel], Never>()
            }
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
                promise(.failure(TodoError.notFound))
return
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
