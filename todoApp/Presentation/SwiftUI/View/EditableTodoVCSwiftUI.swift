//
//  EditableTodoVCSwiftUI.swift
//  todoApp
//
//  Created by 조영태 on 6/11/25.
//

import SwiftUI

struct EditableTodoVCSwiftUI: View {
    @ObservedObject var viewModel = CreateTodoVMSwiftUI(
        CreateTodoVMSwiftUI
            .UseCase(
                addTodo: DefaultAddTodoUseCase(
                    repository: TodoRepositoryImpl(TodoLocalDataSource())
                )
            )
    )
    @State private var showDatePicker = false
    @Binding var writtenTodo: TodoModel?
    @Environment(\.dismiss) private var dismiss

    init(_ writtenTodo: Binding<TodoModel?>) {
        self._writtenTodo = writtenTodo
    }
    
    var buttonColor: Color {
        viewModel.state.isValid ? Color(uiColor: .systemBlue) : Color(
            uiColor: .systemGray
        )
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack {
                    VStack(spacing: 8) {
                        TextInputStackViewSwiftUI(
                            title: $viewModel.state.title ,
                            contents: $viewModel.state.content
                        )
                        
                        DateInputStackViewSwiftUI(date: $viewModel.state.date)
                        
                        Spacer()
                    }
                    
                }
                .padding(.horizontal, 16)
            }
            .navigationTitle(I18N.createTodo)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    
                    Button("완료") {
                        self.viewModel.action(.doWrite)
                    }
                    .disabled(!viewModel.state.isValid)
                    .foregroundStyle(buttonColor)
                    .onChange(of: viewModel.writenTodo) { newValue in
                        guard let newValue = newValue else { return }
                        self.writtenTodo = newValue
                        self.dismiss()
                    }
                }
            }
        }

    }

}

#Preview {
    @State var a = "title"
    @State var b = "content"
    @State var d:TodoModel?
    NavigationStack {
        EditableTodoVCSwiftUI($d)
        //        EditableTodoVCSwiftUI(title: $a, contents: $b)
    }
    
}
