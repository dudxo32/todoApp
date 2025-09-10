//
//  WritableView.swift
//  PresentationUIKit
//
//  Created by 조영태 on 9/5/25.
//

import Foundation
import UIKit
internal import RxCocoa
internal import RxGesture
internal import RxSwift
internal import SnapKit
internal import Then

//import Shared
import PresentationShared


final class WritableTodoView: UIStackView {
    let textInputStackView: TextInputStackView
    let dateInputStackView: DateInputStackView
    
    let vm: TodoInputVM
    let disposeBag = DisposeBag()
    
    init(_ vm:TodoInputVM) {
        self.vm = vm
        
        self.textInputStackView = TextInputStackView(
            title: vm.input.titleRelay.value,
            content: vm.input.contentRelay.value
        )
        self.dateInputStackView = DateInputStackView(vm.input.dateRelay.value)
                
        super.init(frame: .zero)
        
        setupStackView()
        bindInput()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupStackView() {
        axis = .vertical
        spacing = 24
        alignment = .fill
        distribution = .fill
        
        isUserInteractionEnabled = true
        
        addArrangedSubview(textInputStackView)
        addArrangedSubview(dateInputStackView)
    }
    
    private func bindInput() {
        textInputStackView.titleTextInput.rx.text.orEmpty
            .bind(to: vm.input.titleRelay)
            .disposed(by: disposeBag)
        
        textInputStackView.contentTextInput.rx.text.orEmpty
            .bind(to: vm.input.contentRelay)
            .disposed(by: disposeBag)
        
        dateInputStackView.changedDateRX
            .bind(to: vm.input.dateRelay)
            .disposed(by: disposeBag)
    }
}
