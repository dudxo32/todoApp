//
//  EditableTodoVCSwiftUI.swift
//  todoApp
//
//  Created by 조영태 on 6/11/25.
//

import SwiftUI

struct WritableTodoVCSwiftUI<VM: WritableViewModelProtocol>: View {
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
                    LoadingIndicatorSwiftUI()
                }
            }
        }
    }
}

private struct WriteToolbarModifier<VM: WritableViewModelProtocol>: ViewModifier {
    @ObservedObject var vm: VM

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

    init(_ vm: VM) {
        self.vm = vm
    }

    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(I18N.done) { vm.action(.doWrite) }
                        .disabled(!vm.state.isValid)
                        .foregroundStyle(buttonColor)
                }
            }
    }
}

extension View {
    fileprivate func createNavigationItem<VM: WritableViewModelProtocol> (
        _ vm: VM
    ) -> some View {
        modifier(
            WriteToolbarModifier(vm)
        )
    }
}

struct CreatableTodoVCSwiftUI: View {
    @ObservedObject var vm: CreateTodoVMSwiftUI

    init(_ vm: CreateTodoVMSwiftUI) {
        self.vm = vm
    }

    var body: some View {
        WritableViewWidget(
            title: $vm.state.title,
            content: $vm.state.content,
            date: $vm.state.date
        )
        //        .createNavigationItem(vm)
    }
}

struct EditableTodoVCSwiftUI: View {
    @ObservedObject var vm: EditTodoVMSwiftUI

    init(_ todo: TodoModelProtocol) {
        let viewModel = EditTodoVMSwiftUI(
            todo,
            useCase:
                EditTodoVMSwiftUI
                .UseCase(
                    editTodo: DefaultEditTodoUseCase(
                        repository: TodoRepositoryImpl(TodoLocalDataSource())
                    )
                )
        )

        self.vm = viewModel
    }

    var body: some View {
        WritableViewWidget(
            title: $vm.state.title,
            content: $vm.state.content,
            date: $vm.state.date
        )
        .createNavigationItem(vm)
    }
}

private struct WritableViewWidget: View {
    @Binding var title: String
    @Binding var content: String
    @Binding var date: Date?

    var body: some View {
        LazyVStack(spacing: 8) {
            TextInputStackViewSwiftUI(
                title: $title,
                contents: $content
            )

            DateInputStackViewSwiftUI(date: $date)
            Spacer()
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    let vm = CreateTodoVMSwiftUI(
        CreateTodoVMSwiftUI
            .UseCase(
                addTodo: DefaultAddTodoUseCase(
                    repository: TodoRepositoryImpl(TodoLocalDataSource())
                )
            )
    )

    NavigationStack {
        CreatableTodoVCSwiftUI(vm)
    }

}
