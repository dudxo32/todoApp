//
//  AppDIContainer.swift
//  todoApp
//
//  Created by 조영태 on 4/8/25.
//

import Foundation
import Swinject
import SwiftUI
import PresentataionSwiftUI

extension SUI {
    final class AppDIContainer: DefaultAppDIContainer, AppDIContainerProtocol {
        static let _shared:AppDIContainer? = nil
        
        static var shared: AppDIContainer {
            if let shared = _shared {
                return shared
            }
            
            return AppDIContainer()
        }

        func makeTodoListDIContainer() -> any TodoListDIContainerProcotcol {
            SUI.TodoListDIContainer(parentContainer: container)
        }
        
        func makeWritableDIContainer() -> any WritableTodoDIContainerProtocol {
            SUI.WritableTodoDIContainer(parentContainer: container)
        }
    }
    
    struct RootView: View {
        let coordinator = TodoListCoordinator(
            initalScene: .list,
            appDiContaeinr: SUI.AppDIContainer.shared,
            diContainer: SUI.AppDIContainer.shared.makeTodoListDIContainer()
        )
        
        var body: some View {
            CoordinatorScene(coordinator: coordinator)
        }
    }
}
