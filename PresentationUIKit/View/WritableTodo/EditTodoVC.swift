//
//  EditTodoVC.swift
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

public class EditTodoVC: UIViewController {
    // MARK: UI
    private let scrollView = VerticalScrollView().then {
        $0.contentMargins = .init(top: 16, left: 16, bottom: 0, right: 16)
    }
    private let loadingIndicator = LoadingIndicator()
    
    // MARK: View
    private let inputDataView: WritableTodoView
    
    // MARK: VM
    private let editVM: EditTodoVM
    private let inputVM: TodoInputVM
    private let disposeBag = DisposeBag()
    
    // MARK: Init
    public init(vm: EditTodoVM, inputVM: TodoInputVM) {
        self.editVM = vm
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
        self.title = I18N.editTodo
        self.navigationController?.navigationBar.accessibilityIdentifier = UIID.EditTodo.title.rawValue

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
        
        editVM.state.isLoading
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
        
        editVM.state.inputValid
            .drive(editButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        editButton.rx.tap
            .bind(to: editVM.input.editTap)
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        inputVM.state.title.asObservable()
            .bind(to: editVM.input.titleRelay)
            .disposed(by: disposeBag)
        
        inputVM.state.date.asObservable()
            .bind(to: editVM.input.dateRelay)
            .disposed(by: disposeBag)
        
        inputVM.state.contents.asObservable()
            .bind(to: editVM.input.contentRelay)
            .disposed(by: disposeBag)
        
        editVM.state.edittedModel
            .drive(onNext: { [weak self] _ in
                self?.navigationController?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        editVM.state.error
            .compactMap { $0?.localizedDescription }
            .drive(onNext: { [weak self] msg in
                self?.rx.showRetry(
                    message: msg,
                    retryAction: { _ in self?.editVM.input.retryTrigger.accept(.retry) },
                    confirmAction: { _ in self?.editVM.input.retryTrigger.accept(.none) }
                )
            })
            .disposed(by: disposeBag)
    }
}
