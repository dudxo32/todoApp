//
//  TodoListCoordinator.swift
//  todoApp
//
//  Created by 조영태 on 5/1/25.
//

import Foundation
import RxRelay
import RxSwift
import UIKit
import PresentationShared

final class TodoListCoordinator: CoordinatorProcotcol {
    let navigationController: UINavigationController
    let todoListVC: TodoListVC
    
    let disposeBag = DisposeBag()

    init(
        _ navigationController: UINavigationController,
        diContainer: UIK.TodoListDIContainer
    ) {
        self.navigationController = navigationController
        self.todoListVC = diContainer.makeTodoListVC(initFilter: .today)
    }

    func start() {
        navigationController.viewControllers = [todoListVC]
        
        bindPresentCreateVC()
        bindPresentEditVC()
    }

    private func bindPresentCreateVC() {
        func presentCreateVC() {
            let coord = EditableTodoCoordinator(
                self.navigationController,
                diContainer: UIK.WritableTodoDIContainer(),
                mode: .create
            )
            coord.start()

            coord.output.presentedCreateVC
                .bind(to: self.todoListVC.input.presentedCreateVC)
                .disposed(by: self.disposeBag)
        }

        todoListVC.output.presentCreateVC
            .drive(onNext: presentCreateVC)
            .disposed(by: disposeBag)
    }

    private func bindPresentEditVC() {
        func presentEditVC(_ todo: any TodoModelProtocol) {
            let coord = EditableTodoCoordinator(
                self.navigationController,
                diContainer: UIK.WritableTodoDIContainer(),
                mode: .edit(todo: todo)
            )
            coord.start()

            coord.output.presentedEditVC
                .bind(to: self.todoListVC.input.presentedEditVC)
                .disposed(by: self.disposeBag)
        }
        
        todoListVC.output.presentEditVC
            .drive(onNext: presentEditVC)
            .disposed(by: disposeBag)
    }
}
