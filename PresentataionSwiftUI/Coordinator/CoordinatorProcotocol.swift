//
//  CoordinatorProcotocl.swift
//  todoApp
//
//  Created by 조영태 on 5/1/25.
//

import Foundation
import DataLayer

//public protocol CoordinatorProcotcol: AnyObject {
//    var navigationController: UINavigationController { get }
//    
//    func start()
//}

public protocol AppDIContainerProtocol {
    func makeTodoListDIContainer() -> TodoListDIContainerProcotcol
    func makeWritableDIContainer() -> WritableTodoDIContainerProtocol
}
