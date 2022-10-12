//
//  MainViewModel.swift
//  todoApp
//
//  Created by 조영태 on 2022/10/03.
//

import Foundation
import RxSwift
import RxCocoa

class MainViewModel: ViewModelProtocol {
    struct Input {
        let click:PublishRelay<Void>
    }
    struct Output {
        let move:Signal<Void>
    }
    
    var input:Input
    var output:Output
    
    var disposeBag = DisposeBag()
    
    init() {
        let clickRelay = PublishRelay<Void>()
        self.input = Input(click: clickRelay)
        
        
        
        self.output = Output(move: clickRelay.asSignal())
        
        
//        clickRelay.sub
    }
}
