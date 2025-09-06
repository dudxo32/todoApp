//
//  CreateTodoVM.swift
//  PresentationUIKit
//
//  Created by 조영태 on 9/4/25.
//

import Domain
import Foundation
import PresentationShared
internal import RxCocoa
internal import RxSwift

extension CreateTodoVM: ViewModelProtocol, LoadingProtocol, RetryProtocol {
    public struct UseCase {
        let addTodo: any AddTodoUseCase

        public init(addTodo: any AddTodoUseCase) {
            self.addTodo = addTodo
        }
    }

    struct Input: RetryInput {
        let titleRelay = BehaviorRelay<String>.init(value: "")
        let dateRelay = BehaviorRelay<Date?>.init(value: nil)
        let contentRelay = BehaviorRelay<String>.init(value: "")
        let createTap = PublishRelay<Void>()
        let retryTrigger = PublishRelay<RetryAction>()
    }

    struct State: LoadingState {
        let inputValid: Driver<Bool>
        let createdModel: Driver<any TodoModelProtocol>
        let error: Driver<Error?>
        let isLoading: Driver<Bool>

        fileprivate init(
            titleRelay: BehaviorRelay<String>,
            dateRelay: BehaviorRelay<Date?>,
            contentRelay: BehaviorRelay<String>,
            createdModelRelay: PublishRelay<TodoModel>,
            errorRelay: PublishRelay<Error?>,
            isLoadingRelay: BehaviorRelay<Bool>
        ) {
            self.inputValid = BehaviorRelay.combineLatest(
                titleRelay, dateRelay
            )
            .map({ (title, date) in
                !title.isEmpty && date != nil
            })
            .asDriver(onErrorJustReturn: false)

            self.createdModel = createdModelRelay.map { $0 as (any TodoModelProtocol) }
                .asDriver(onErrorDriveWith: .never())

            self.error = errorRelay.asDriver(onErrorJustReturn: nil)

            self.isLoading = isLoadingRelay.asDriver()

        }
    }
}

public class CreateTodoVM {
    var input: Input
    var state: State
    var useCase: UseCase
    
    var disposeBag = DisposeBag()

    fileprivate let loadingRelay: BehaviorRelay<Bool> = .init(value: false)
    private let errorRelay: PublishRelay<Error?> = .init()
    private let createdRelay: PublishRelay<TodoModel> = .init()
    
    public init(useCase:UseCase) {
        self.input = Input()
        self.useCase = useCase
        
        self.state = State(
            titleRelay: input.titleRelay,
            dateRelay: input.dateRelay,
            contentRelay: input.contentRelay,
            createdModelRelay: createdRelay,
            errorRelay: errorRelay,
            isLoadingRelay: loadingRelay
        )
        
        bindDoneTap()
    }
    
    private func bindDoneTap() {
        self.input.createTap
            .withUnretained(self)
            .flatMap { (self, _) in self.handleChangeTodo() }
            .bind(to: createdRelay)
            .disposed(by: disposeBag)
    }

    private func handleChangeTodo() -> Single<TodoModel> {
        return writeTodo()
            .handleLoadingState(to: self.loadingRelay)
            .retry(when: { error in
                return self.handelRetry(from: error, in: self.errorRelay)
            })
            .catch { _ in .never() }
    }
    
    
    func writeTodo() -> Single<TodoModel> {
        guard let date = self.input.dateRelay.value else {
            preconditionFailure("date 값이 nil 입니다")
        }

        let title = self.input.titleRelay.value
        let contents = self.input.contentRelay.value

        return .deferredWithUnretained(self) { obj in
            return .async {
                let response = try await obj.useCase.addTodo.execute(
                    title: title,
                    contents: contents,
                    date: date
                )

                return TodoMapper.toModel(response)
            }
        }
    }
}
