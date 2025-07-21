//
//  EditableTodoVCSwiftUI.swift
//  todoApp
//
//  Created by 조영태 on 6/11/25.
//

import SwiftUI
import Shared

extension SUI {
    struct WritableTodoVC<VM: WritableViewModelProtocol>: View {
        @ObservedObject var vm:VM
        
        var title: String {
            switch vm.type {
            case .create:
                I18N.createTodo
            case .edit:
                I18N.editTodo
            }
        }

        var buttonColor: Color {
            vm.state.isValid
            ? Color(uiColor: .systemBlue)
            : Color(uiColor: .systemGray)
        }

        init(_ vm:VM) {
            self.vm = vm
        }
        
        var body: some View {
            NavigationStack {
                ScrollView {
                    WritableViewWidget(
                        title: $vm.state.title,
                        content: $vm.state.content,
                        date: $vm.state.date
                    )
                }
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(I18N.done) { vm.action(.doWrite) }
                            .disabled(!vm.state.isValid)
                            .foregroundStyle(buttonColor)
                    }
                    
                }
                .overlay {
                    if vm.isShowLoadingIndicator {
                        SUI.LoadingIndicator()
                    }
                }
                .errorAlert(
                    isPresented: Binding(
                        get: { vm.error != nil },
                        set: { _, _ in }
                    ),
                    message: vm.error?.localizedDescription ?? ""
                )
                .retryAlert(
                    isPresented: Binding(
                        get: { vm.retryError != nil },
                        set: { _, _ in }
                    ),
                    message: vm.retryError?.localizedDescription ?? "",
                    retryAction: {
                        vm.action(.retryAction(.retry))
                    },
                    noneAction: {
                        vm.action(.retryAction(.none))
                    }
                )
               
            }
        }
    }

    private struct WritableViewWidget: View {
        @Binding var title: String
        @Binding var content: String
        @Binding var date: Date?

        var body: some View {
            LazyVStack(spacing: 8) {
                SUI.TextInputStackView(
                    title: $title,
                    contents: $content
                )

                SUI.DateInputStackView(date: $date)
                Spacer()
            }
            .padding(.horizontal, 16)
        }
    }
}


#Preview {
    NavigationStack {
        SUI.WritableTodoDIContainer().makeCreatableTodoScene()
    }

}
