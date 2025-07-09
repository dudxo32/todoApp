//
//  EditableTodoVCSwiftUI.swift
//  todoApp
//
//  Created by 조영태 on 6/11/25.
//

import SwiftUI

struct WritableTodoVCSwiftUI<VM: WritableTodoOutput>: View {
    @ObservedObject var vm: VM

    init(_ vm: VM) {
        self.vm = vm
    }

    var body: some View {
        ScrollView {
            LazyVStack {
                VStack(spacing: 8) {
                    TextInputStackViewSwiftUI(
                        title: $vm.state.title,
                        contents: $vm.state.content
                    )

                    DateInputStackViewSwiftUI(date: $vm.state.date)
                    Spacer()
                }

            }
            .padding(.horizontal, 16)
        }
    }
}

private struct WriteToolbarModifier<
    VM: ActionObservableObject & WritableTodoOutput
>: ViewModifier {
    @ObservedObject var vm: VM
    @Environment(\.dismiss) private var dismiss

    let buttonTitle: String
    let didCompleteWriting: (TodoModel) -> Void
    let title: String

    var buttonColor: Color {
        vm.state.isValid
            ? Color(uiColor: .systemBlue)
            : Color(uiColor: .systemGray)
    }

    init(
        _ vm: VM,
        title: String,
        buttonTitle: String,
        didCompleteWriting: @escaping (TodoModel) -> Void
    ) {
        self.vm = vm
        self.title = title
        self.buttonTitle = buttonTitle
        self.didCompleteWriting = didCompleteWriting
    }

    func body(content: Content) -> some View {
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(buttonTitle) { vm.action(.doWrite) }
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

extension View {
    fileprivate func createNavigationItem<
        VM: ActionObservableObject & WritableTodoOutput
    >(
        _ vm: VM,
        title: String,
        buttonTitle: String,
        didCompleteWriting: @escaping (TodoModel) -> Void
    ) -> some View {
        modifier(
            WriteToolbarModifier(
                vm,
                title: title,
                buttonTitle: buttonTitle,
                didCompleteWriting: didCompleteWriting
            )
        )
    }
}

protocol WritableView: View {
    var didCompleteWriting: (TodoModel) -> Void { get }
}

struct CreatableTodoVCSwiftUI: WritableView {
    @ObservedObject var viewModel: CreateTodoVMSwiftUI
    let didCompleteWriting: (TodoModel) -> Void

    init(didCompleteWriting: @escaping (TodoModel) -> Void) {
        let viewModel = CreateTodoVMSwiftUI(
            CreateTodoVMSwiftUI
                .UseCase(
                    addTodo: DefaultAddTodoUseCase(
                        repository: TodoRepositoryImpl(TodoLocalDataSource())
                    )
                )
        )

        self.didCompleteWriting = didCompleteWriting
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            WritableTodoVCSwiftUI(viewModel)
                .createNavigationItem(
                    viewModel,
                    title: I18N.createTodo,
                    buttonTitle: I18N.done,
                    didCompleteWriting: didCompleteWriting
                )
        }
        .overlay {
            if viewModel.isShowLoadingIndicator {
                LoadingIndicatorSwiftUI()
            }
        }

    }
}

struct EditableTodoVCSwiftUI: WritableView {
    @ObservedObject var viewModel: EditTodoVMSwiftUI
    let didCompleteWriting: (TodoModel) -> Void

    init(
        _ todo: TodoModelProtocol,
        didCompleteWriting: @escaping (TodoModel) -> Void
    ) {
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

        self.didCompleteWriting = didCompleteWriting
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            WritableTodoVCSwiftUI(viewModel)

                .createNavigationItem(
                    viewModel,
                    title: I18N.editTodo,
                    buttonTitle: I18N.done,
                    didCompleteWriting: didCompleteWriting
                )
        }

    }
}

#Preview {
    @State var a = "title"
    @State var b = "content"
    NavigationStack {
        CreatableTodoVCSwiftUI(didCompleteWriting: { _ in })
    }

}
