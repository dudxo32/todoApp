//
//  CreateTodoVC.swift
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
import Shared
import PresentationShared

public class CreateTodoVC: UIViewController {
    // MARK: UI
    private let scrollView = VerticalScrollView().then {
        $0.contentMargins = .init(top: 16, left: 16, bottom: 0, right: 16)
    }
    private let loadingIndicator = LoadingIndicator()
    
    // MARK: View
    let inputDataView: WritableTodoView

    // MARK: VM
    private let vm: CreateTodoVM
    private let inputVM: TodoInputVM
    private let disposeBag = DisposeBag()
    
    // MARK: Init
    public init(vm: CreateTodoVM, inputVM:TodoInputVM) {
        self.vm = vm
        self.inputVM = inputVM
        self.inputDataView = WritableTodoView(inputVM)
 
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = I18N.createTodo
        self.navigationController?.navigationBar.accessibilityIdentifier = UIID.CreateTodo.title.rawValue

        setupScrollView()
        setupLoadingIndicator()
        setupButtonBinding()
        bindViewModel()
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.addArrangedSubview(inputDataView)
    }
    
    private func setupLoadingIndicator() {
        view.addSubview(loadingIndicator)
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        vm.state.isLoading
            .drive(loadingIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
    }
    
    private func setupButtonBinding() {
        let editButton = UIBarButtonItem(
            title: I18N.done,
            style: .plain,
            target: nil,
            action: nil
        )
        navigationItem.rightBarButtonItem = editButton
        
        vm.state.inputValid
            .drive(editButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        editButton.rx.tap
            .bind(to: vm.input.createTap)
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        inputVM.state.title.asObservable()
            .bind(to: vm.input.titleRelay)
            .disposed(by: disposeBag)
        
        inputVM.state.date.asObservable()
            .bind(to: vm.input.dateRelay)
            .disposed(by: disposeBag)

        inputVM.state.contents.asObservable()
            .bind(to: vm.input.contentRelay)
            .disposed(by: disposeBag)
        
        vm.state.createdModel
            .drive(onNext: { [weak self] _ in
                self?.navigationController?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        vm.state.error
            .compactMap { $0?.localizedDescription }
            .drive(onNext: { [weak self] msg in
                self?.rx.showRetry(
                    message: msg,
                    retryAction: { _ in self?.vm.input.retryTrigger.accept(.retry) },
                    confirmAction: { _ in self?.vm.input.retryTrigger.accept(.none) }
                )
            })
            .disposed(by: disposeBag)
    }
}
