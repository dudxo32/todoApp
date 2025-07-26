//
//  AppDIContainer.swift
//  todoApp
//
//  Created by 조영태 on 4/8/25.
//

import Foundation
import Swinject
import UIKit
import PresentationUIKit

extension UIK {
    final class AppDIContainer: DefaultAppDIContainer, AppDIContainerProtocol {
        static let _shared:AppDIContainer? = nil
        
        static var shared: AppDIContainer {
            if let shared = _shared {
                return shared
            }
            
            return AppDIContainer()
        }

        func makeTodoListDIContainer() -> any TodoListDIContainerProtocol {
            return UIK.TodoListDIContainer(parentContainer: container)
        }
    
        func makeWritableDIContainer() -> any WritableTodoDIContainerProtocol {
            return UIK.WritableTodoDIContainer(parentContainer: container)
        }
    }
    
    class RootNavigationController: UINavigationController {
        var coordinator:TodoListCoordinator!

        override func viewDidLoad() {
            super.viewDidLoad()
            
            self.coordinator = TodoListCoordinator(
                self,
                appDIContainer: AppDIContainer.shared
            )
            
            coordinator.start()
        }
    }
}
