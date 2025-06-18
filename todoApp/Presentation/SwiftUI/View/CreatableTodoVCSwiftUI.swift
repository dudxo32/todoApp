//
//  EditableTodoVCSwiftUI.swift
//  todoApp
//
//  Created by 조영태 on 6/11/25.
//

import SwiftUI

private struct WritableTodoVCSwiftUI: View {
    var vm: AnyWritableTodoVMSwiftUI

    init(_ vm: AnyWritableTodoVMSwiftUI) {
        self.vm = vm
    }

    var body: some View {
        ScrollView {
            LazyVStack {
                VStack(spacing: 8) {
                    TextInputStackViewSwiftUI(
                        title: vm.bindingState.title,
                        contents: vm.bindingState.content
                    )

                    DateInputStackViewSwiftUI(date: vm.bindingState.date)
                    Spacer()
                }

            }
            .padding(.horizontal, 16)
        }
    }
}

private struct WriteToolbarModifier: ViewModifier {
    var vm: AnyWritableTodoVMSwiftUI
    let buttonTitle: String
    let buttonAction: () -> Void
    let didCompleteWriting: (TodoModel) -> Void
    let title: String
    @Environment(\.dismiss) private var dismiss

    var buttonColor: Color {
        vm.state.isValid
            ? Color(uiColor: .systemBlue)
            : Color(uiColor: .systemGray)
    }

    init(
        _ vm: AnyWritableTodoVMSwiftUI,
        title: String,
        buttonTitle: String,
        buttonAction: @escaping () -> Void,
        didCompleteWriting: @escaping (TodoModel) -> Void
    ) {
        self.vm = vm
        self.title = title
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
        self.didCompleteWriting = didCompleteWriting
    }

    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(buttonTitle) { buttonAction() }
                        .disabled(!vm.state.isValid)
                        .foregroundStyle(buttonColor)
                        .onChange(of: vm.writtenTodo) { newValue in
                            guard let newValue = newValue else { return }
                            didCompleteWriting(newValue)
                            dismiss()
                        }
                }
            }
    }
}

private extension View {
    func createNavigationItem(
        _ vm: AnyWritableTodoVMSwiftUI,
        title: String,
        buttonTitle: String,
        buttonAction: @escaping () -> Void,
        didCompleteWriting: @escaping (TodoModel) -> Void
    ) -> some View {
        modifier(
            WriteToolbarModifier(
                vm,
                title: title,
                buttonTitle: buttonTitle,
                buttonAction: buttonAction,
                didCompleteWriting: didCompleteWriting
            )
        )
    }
}

protocol WritableView: View {
    var anyViewModel: AnyWritableTodoVMSwiftUI { get }
}

struct CreatableTodoVCSwiftUI: WritableView {
    @ObservedObject var viewModel: CreateTodoVMSwiftUI
    @Binding var writtenTodo: TodoModel?

    var anyViewModel: AnyWritableTodoVMSwiftUI
    
    init(_ writtenTodo: Binding<TodoModel?>) {
        let viewModel = CreateTodoVMSwiftUI(
            CreateTodoVMSwiftUI
                .UseCase(
                    addTodo: DefaultAddTodoUseCase(
                        repository: TodoRepositoryImpl(TodoLocalDataSource())
                    )
                )
        )

        self._writtenTodo = writtenTodo
        self.viewModel = viewModel
        self.anyViewModel = .init(viewModel)
    }

    var body: some View {
        NavigationStack {
            WritableTodoVCSwiftUI(anyViewModel)
                .createNavigationItem(
                    anyViewModel,
                    title: I18N.createTodo,
                    buttonTitle: I18N.confirm,
                    buttonAction: { self.viewModel.action(.doWrite) },
                    didCompleteWriting: { self.writtenTodo = $0 }
                )
        }

    }
}

#Preview {
    @State var a = "title"
    @State var b = "content"
    @State var d: TodoModel?
    NavigationStack {
        CreatableTodoVCSwiftUI($d)
    }

}
