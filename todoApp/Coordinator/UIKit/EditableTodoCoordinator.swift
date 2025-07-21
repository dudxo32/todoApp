//
//  EditableTodoCoordinator.swift
//  todoApp
//
//  Created by 조영태 on 5/1/25.
//

import Foundation
import RxSwift
import UIKit
import SwiftUI
import PresentationShared

extension EditableTodoCoordinator: HasRxIO {
    typealias Input = IOEmpty
    
    struct Output {
        let presentedCreateVC = PublishSubject<CreateTodoVC>()
        let presentedEditVC = PublishSubject<EditTodoVC>()
    }
}

class EditableTodoCoordinator: CoordinatorProcotcol {
    enum Mode {
        case create
        case edit(todo: any TodoModelProtocol)
    }

    let navigationController: UINavigationController
    let editableVC: EditableTodoVC
    
    let output = Output()
    let disposeBag = DisposeBag()

    init(
        _ navigationController: UINavigationController,
        diContainer: UIK.WritableTodoDIContainer,
        mode: Mode
    ) {
        self.navigationController = navigationController
        
        switch mode {
        case .create:
            self.editableVC = diContainer.makeCreateTodoVC()
        case .edit(let todo):
            self.editableVC = diContainer.makeEditTodoVC(todoModel: todo)
        }
            }

    func start() {
        presentEditableVC()
    }
    
    private func presentEditableVC() {
        let modalNavi = UINavigationController()
        modalNavi.viewControllers = [editableVC]
//        modalNavi.viewControllers = [UIHostingController(rootView: editableVCSwiftUI)]
        
        self.navigationController.present(modalNavi, animated: true) {
            switch self.editableVC {
                
            case let createVC as CreateTodoVC:
                self.output.presentedCreateVC.onNext(createVC)
                self.output.presentedEditVC.onCompleted()
            
            case let editVC as EditTodoVC:
                self.output.presentedEditVC.onNext(editVC)
                self.output.presentedEditVC.onCompleted()
            
            default:
                break
            }
        }
    }
}
