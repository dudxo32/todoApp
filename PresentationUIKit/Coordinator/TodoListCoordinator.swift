//
//  TodoListCoordinator.swift
//  todoApp
//
//  Created by 조영태 on 5/1/25.
//

import Foundation
import UIKit
internal import RxRelay
internal import RxSwift

import DataLayer
import PresentationShared

public protocol TodoListDIContainerProtocol {
    func makeTodoListVM(initFilter: TodoFilterType, env: DataEnvironment) -> TodoListVM
    func makeTodoListVC(_ vm:TodoListVM, initFilter: TodoFilterType) -> TodoListVC
}

final public class TodoListCoordinator: CoordinatorProcotcol {
    public let navigationController: UINavigationController
    let appDIContainer: AppDIContainerProtocol
    
    let diContainer: TodoListDIContainerProtocol
    
    var listVC:TodoListVC?
    var listVM:TodoListVM?
    let disposeBag = DisposeBag()

    public init(
        _ navigationController: UINavigationController,
        appDIContainer: AppDIContainerProtocol
    ) {
        self.navigationController = navigationController
        self.appDIContainer = appDIContainer
        self.diContainer = appDIContainer.makeTodoListDIContainer()
    }
    
    public func start() {
        let vm = diContainer.makeTodoListVM(initFilter: .today, env: .local)
        self.listVM = vm
        
        bindPresentCreateVC(vm)
        bindPresentEditVC(vm)
        
        
        let vc = diContainer.makeTodoListVC(vm, initFilter: .today)
        self.listVC = vc
        
        navigationController.viewControllers = [vc]
    }
    
    private func bindPresentCreateVC(_ vm:TodoListVM) {
        listVM!.input.goCreateItem
                    .debug()
            .withUnretained(self)
            .bind { (this, _) in
                this
                    .startWritableCoordinator(
                        .create,
                        writtenRealy: vm.input.addedItem
                    )
            }
            .disposed(by: vm.disposeBag)
    }

    private func bindPresentEditVC(_ vm:TodoListVM) {
        vm.input.goEditItem
            .withUnretained(self)
            .bind { (this, value) in
                this
                    .startWritableCoordinator(
                        .edit(todo: value),
                        writtenRealy: vm.input.edittedItem
                    )
            }
            .disposed(by: disposeBag)
    }

    private func startWritableCoordinator(
        _ mode:WritableTodoCoordinator.Mode,
        writtenRealy:PublishRelay<any TodoModelProtocol>
    ) {
        let coord = WritableTodoCoordinator(
            self.navigationController,
            diContainer: self.appDIContainer.makeWritableDIContainer(),
            mode: mode,
            written: writtenRealy
        )
        
        coord.start()
    }
//
//    private func bindPresentEditVC() {
//        func presentEditVC(_ todo: any TodoModelProtocol) {
//            let coord = EditableTodoCoordinator(
//                self.navigationController,
//                diContainer: UIK.WritableTodoDIContainer(),
//                mode: .edit(todo: todo)
//            )
//            coord.start()
//
//            coord.output.presentedEditVC
//                .bind(to: self.todoListVC.input.presentedEditVC)
//                .disposed(by: self.disposeBag)
//        }
//        
//        todoListVC.output.presentEditVC
//            .drive(onNext: presentEditVC)
//            .disposed(by: disposeBag)
//    }
}
