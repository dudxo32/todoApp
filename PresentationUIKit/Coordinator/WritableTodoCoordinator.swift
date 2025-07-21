//
//  EditableTodoCoordinator.swift
//  todoApp
//
//  Created by 조영태 on 5/1/25.
//

import Foundation
import UIKit
internal import RxSwift

import PresentationShared
import DataLayer
internal import RxRelay

public protocol WritableTodoDIContainerProtocol {
    func makeCreateTodoVM(_ env: DataEnvironment) -> CreateTodoVM
    
    func makeCreateTodoVC(_ vm: WritableTodoVM) -> CreateTodoVC
    
    func makeEditTodoVM(todoModel: any TodoModelProtocol, env: DataEnvironment) -> EditTodoVM

    func makeEditTodoVC(todoModel: any TodoModelProtocol, vm: EditTodoVM)-> EditTodoVC
}

class WritableTodoCoordinator: CoordinatorProcotcol {
    enum Mode {
        case create
        case edit(todo: any TodoModelProtocol)
    }

    let navigationController: UINavigationController
    
    let diContainer: WritableTodoDIContainerProtocol
    let mode: Mode
    let written: PublishRelay<any TodoModelProtocol>
    
    init(
        _ navigationController: UINavigationController,
        diContainer: WritableTodoDIContainerProtocol,
        mode: Mode,
        written: PublishRelay<any TodoModelProtocol>
    ) {
        self.navigationController = navigationController
        self.mode = mode
        self.diContainer = diContainer
        self.written = written
    }

    func start() {
        var view: WritableTodoVC {
            switch mode {
            case .create:
                let vm = diContainer.makeCreateTodoVM(.local)
                bindWritten(vm)
      
                return diContainer.makeCreateTodoVC(vm)
            
            case .edit(let todo):
                let vm = diContainer.makeEditTodoVM(todoModel: todo, env: .local)
                bindWritten(vm)
                
                return diContainer.makeEditTodoVC(todoModel: todo, vm: vm)
            }
            
        }
        
        presentEditableVC(view)
    }
    
    private func bindWritten(_ vm:WritableTodoVM) {
        vm.state.editedModel
            .asObservable()
            .bind(to: written)
            .disposed(by: vm.disposeBag)
    }
    
    private func presentEditableVC(_ view:UIViewController) {
        let modalNavi = UINavigationController()
        modalNavi.viewControllers = [view]

        self.navigationController.present(modalNavi, animated: true)
    }
}
