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
        textInputStackView.titleTextRX.orEmpty
            .bind(to: vm.input.titleRelay)
            .disposed(by: disposeBag)
        
        textInputStackView.contentTextRX.orEmpty
            .bind(to: vm.input.contentRelay)
            .disposed(by: disposeBag)
        
        dateInputStackView.changedDateRX
            .bind(to: vm.input.dateRelay)
            .disposed(by: disposeBag)
    }
}

//class WritableTodoView: UIView {
//    // MARK: UI Components
//    fileprivate let textInputStackView: TextInputStackView
//    fileprivate let dateInputStackView: DateInputStackView
//    
//    // MARK: Input VM
//    let vm: TodoInputVM
//    private let disposeBag = DisposeBag()
//    
//    // MARK: Init
//    init(_ vm:TodoInputVM) {
//        self.vm = vm
//        
//        self.textInputStackView = TextInputStackView(
//            title: vm.input.titleRelay.value,
//            content: vm.input.contentRelay.value
//        )
//        self.dateInputStackView = DateInputStackView(vm.input.dateRelay.value)
//        
//        super.init(frame: .zero)
//        
//        setupUI()
//        bindInput()
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    // MARK: UI
//    private func setupUI() {
//        self.addSubview(textInputStackView)
//        self.addSubview(dateInputStackView)
//        
//        textInputStackView.snp.makeConstraints { make in
//            make.top.leading.trailing.equalToSuperview()
//        }
//        
//        dateInputStackView.snp.makeConstraints { make in
//            make.top.equalTo(textInputStackView.snp.bottom).offset(24)
//            make.leading.trailing.equalToSuperview()
//        }
//    }
//    
//    // MARK: Binding
//    private func bindInput() {
//        textInputStackView.titleTextRX.orEmpty
//            .bind(to: vm.input.titleRelay)
//            .disposed(by: disposeBag)
//        
//        textInputStackView.contentTextRX.orEmpty
//            .bind(to: vm.input.contentRelay)
//            .disposed(by: disposeBag)
//        
//        dateInputStackView.changedDateRX
//            .bind(to: vm.input.dateRelay)
//            .disposed(by: disposeBag)
//    }
//}
