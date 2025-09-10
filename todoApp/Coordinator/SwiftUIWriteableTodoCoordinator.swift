//
//  SwiftUIWriteableTodoCoordinator.swift
//  todoApp
//
//  Created by 조영태 on 7/9/25.
//
import SwiftUI

enum WriteableScene: Identifiable {
    case create, edit
    
    var id: String {
        String(self.hashValue)
    }
}


class SwiftUIWriteableTodoCoordinator: ObservableObject {
    @Published var path: NavigationPath = NavigationPath()
    @Published var modal: WriteableScene? = nil

    
    
    func buildScence(_ scene:WriteableScene) -> some View {
        switch scene {
        case .create:
            return    CreatableTodoVCSwiftUI($addedTodo) { newValue in
                viewModel.action(.addedItem(newValue))
            }
        case .edit:
            return diContainer.makeTodoListVCSwiftUI(initFilter: .today)
        }
    }
}
