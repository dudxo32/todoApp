//
//  TodoInputVM.swift
//  PresentationUIKit
//
//  Created by 조영태 on 9/4/25.
//

import Foundation
internal import RxSwift
internal import RxCocoa
internal import RxRelay

public class TodoInputVM: ViewModelProtocol {
    typealias UseCase = Void
    
    var input: Input
    
    var state: State
    
    struct Input {
        let titleRelay: BehaviorRelay<String>
        let dateRelay: BehaviorRelay<Date?>
        let contentRelay: BehaviorRelay<String>
    }

    struct State {
        let title: Driver<String>
        let date: Driver<Date?>
        let contents: Driver<String>

        fileprivate init(
            titleRealy: BehaviorRelay<String>,
            dateRealy: BehaviorRelay<Date?>,
            contentsRealy: BehaviorRelay<String>
        ) {
            self.title = titleRealy.asDriver(onErrorJustReturn: "")
            self.date = dateRealy.asDriver(onErrorJustReturn: nil)
            self.contents = contentsRealy.asDriver(onErrorJustReturn: "")
        }
    }

    var disposeBag = DisposeBag()
    
    fileprivate let inputValidRelay = BehaviorRelay<Bool>.init(value: false)

    fileprivate init(input: Input) {
        self.input = input
        self.state = .init(
            titleRealy: input.titleRelay,
            dateRealy: input.dateRelay,
            contentsRealy: input.contentRelay
        )
    }

}

#if DEBUG
extension TodoInputVM {
    /// 테스트 전용 생성자
    internal convenience init(testInput: Input) {
        self.init(input: testInput)
    }
}
#endif
