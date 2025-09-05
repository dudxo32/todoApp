//
//  EditTodoVM.swift
//  PresentationUIKit
//
//  Created by 조영태 on 9/5/25.
//

import Domain
import Foundation
import PresentationShared
internal import RxCocoa
internal import RxSwift

extension EditTodoVM1: ViewModelProtocol, LoadingProtocol, RetryProtocol {
    public struct UseCase {
        let editTodo: any EditTodoUseCase

        public init(editTodo: any EditTodoUseCase) {
            self.editTodo = editTodo
        }
    }

    struct Input: RetryInput {
        let titleRelay: BehaviorRelay<String>
        let dateRelay: BehaviorRelay<Date?>
        let contentRelay: BehaviorRelay<String>
        let editTap = PublishRelay<Void>()
        let retryTrigger = PublishRelay<RetryAction>()
    }

    struct State: LoadingState {
        let inputValid: Driver<Bool>
        let edittedModel: Driver<any TodoModelProtocol>
        let error: Driver<Error?>
        let isLoading: Driver<Bool>

        fileprivate init(
            isValidChangeTitleRelay: Observable<Bool>,
            isValidChangeDateRelay: Observable<Bool>,
            isValidChangeContetRelay: Observable<Bool>,
            edittedModelRelay: PublishRelay<TodoModel>,
            errorRelay: PublishRelay<Error?>,
            isLoadingRelay: BehaviorRelay<Bool>
        ) {
            
            self.inputValid = BehaviorRelay.combineLatest(
                isValidChangeTitleRelay,
                isValidChangeDateRelay,
                isValidChangeContetRelay)
            .map { $0 || $1 || $2 }
            .asDriver(onErrorJustReturn: false)
            
            self.edittedModel = edittedModelRelay.map { $0 as (any TodoModelProtocol) }
                .asDriver(onErrorDriveWith: .never())

            self.error = errorRelay.asDriver(onErrorJustReturn: nil)

            self.isLoading = isLoadingRelay.asDriver()

        }
    }
}

public class EditTodoVM1 {
    var input: Input
    var state: State
    var useCase: UseCase
    
    var disposeBag = DisposeBag()
    private let model: TodoModel

    fileprivate let loadingRelay: BehaviorRelay<Bool> = .init(value: false)
    private let errorRelay: PublishRelay<Error?> = .init()
    private let edittedRelay: PublishRelay<TodoModel> = .init()
    
    init(model: any TodoModelProtocol, useCase:UseCase) {
        self.model = TodoModel(model)
        
        self.input = .init(
            titleRelay: .init(value: model.title),
            dateRelay: .init(value: model.date),
            contentRelay: .init(value: model.contents)
        )
        self.useCase = useCase
        
        let titleValid = input.titleRelay.map {
            $0 != model.title && !($0.isEmpty)
        }
        
        let dateValid = input.dateRelay.map {
            guard let date = $0 else { return false }
            return !Calendar.current.isDate(date, inSameDayAs: model.date)
        }
        
        let contentValid = input.contentRelay.map { $0 != model.contents }
        
        self.state = State(
            isValidChangeTitleRelay: titleValid,
            isValidChangeDateRelay:  dateValid,
            isValidChangeContetRelay: contentValid,
            edittedModelRelay: edittedRelay,
            errorRelay: errorRelay,
            isLoadingRelay: loadingRelay
        )
        
        bindEditTap()
    }
    
    private func bindEditTap() {
        self.input.editTap
            .withUnretained(self)
            .flatMap { (self, _) in self.handleEditTodo() }
            .bind(to: edittedRelay)
            .disposed(by: disposeBag)
    }

    private func handleEditTodo() -> Single<TodoModel> {
        return editTodo()
            .handleLoadingState(to: self.loadingRelay)
            .retry(when: { error in
                return self.handelRetry(from: error, in: self.errorRelay)
            })
            .catch { _ in .never() }
    }
    
    
    func editTodo() -> Single<TodoModel> {
        guard let date = self.input.dateRelay.value else {
            preconditionFailure("date 값이 nil 입니다")
        }

        let title = self.input.titleRelay.value
        let contents = self.input.contentRelay.value

        return .deferredWithUnretained(self) { obj in
            return .async {

                let response = try await obj.useCase.editTodo.execute(
                    TodoMapper.toEntity(obj.model),
                    newTitle: title,
                    newDate: date,
                    newContents: contents
                )

                return TodoMapper.toModel(response)
            }
        }
    }
}
