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
import PresentationShared

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

    public init(title:String = "", date:Date? = nil, contents:String = "") {
        self.input = .init(
            titleRelay: .init(value:  title),
            dateRelay: .init(value: date),
            contentRelay: .init(value: contents)
        )
        
        self.state = .init(
            titleRealy: input.titleRelay,
            dateRealy: input.dateRelay,
            contentsRealy: input.contentRelay
        )
    }

}
