//
//  TodoListVCSwiftUI.swift
//  todoApp
//
//  Created by 조영태 on 6/5/25.
//

import SwiftUI

var isPreview: Bool {
#if DEBUG
    return ProcessInfo.processInfo
        .environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
#else
    return false
#endif
}

private struct NoListLabel: View {
    var body: some View {
        Text(I18N.noList)
            .font(Font.system(size: 20, weight: .bold))
            
    }
}

private struct ListView: View {
    @ObservedObject var viewModel:TodoListVMSwiftUI
    
    var body: some View {
        List {
            ForEach(viewModel.item) { section in
                Section(header: Text(section.header)) {
                    ForEach(section.items) { item in
                        TodoCellSwiftUI(model: item) { _ in
                            viewModel.action(.toggleDone(item))
                        }
                        .listRowInsets(
                            EdgeInsets(
                                top: 8,
                                leading: 1,
                                bottom: 8,
                                trailing: 16
                            )
                        )
                        .swipeActions {
                            Button(role:.destructive) {
                                viewModel.action(.tapDelete(item))
                            } label: {
                                Image(systemName: "trash")
                            }
                            
                        }
                        
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(.white)
        .ignoresSafeArea()
    }
}

struct TodoListVCSwiftUI: View {
    @ObservedObject var viewModel:TodoListVMSwiftUI
    @State private var isShowingError = false

    init(viewModel: TodoListVMSwiftUI) {
        self.viewModel = viewModel
    }
        
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ListView(viewModel: viewModel)
                    .task {
                        if !isPreview {viewModel.action(.fetchItems)}
                    }
                    
                    
                TabView(viewModel: viewModel)
            }
        }
        .navigationTitle(I18N.todo)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { print("버튼 눌림") }) {
                    Image(systemName:"plus.circle.fill")
                }
            }
        }
        .alert(
            I18N.serverError,
            isPresented: Binding(
                get: { viewModel.error != nil },
                set: {_,_ in })
        ) {
            Button(I18N.confirm, role: .cancel) {}
            Button(I18N.retry) {}

        } message: {
            Text(viewModel.error?.localizedDescription ?? "")
        }
    }
}

    
struct TabView: View {
    @ObservedObject var viewModel:TodoListVMSwiftUI
        
    var body: some View {
        HStack {
            ForEach(TodoFilterType.values) { type in
                let imageName = getImgageName(type)
                let text = getText(type)
                let color = getColor(type)
                    
                Spacer()
                    
                Button(
                    action: { viewModel.action(.tapFilter(type)) }
                ) {
                    VStack(spacing: 4 ) {
                        Image(systemName: imageName)
                            .font(.system(size: 22))
                            .foregroundColor(color)
                            
                        Text(text)
                            .font(.caption)
                            .foregroundColor(color)
                    }
                }
                    
                Spacer()
                    
            }
        }
        .padding(.top, 6)
        .padding(.bottom, 8)
        .overlay(Divider(), alignment: .top)
        .frame(height: 64)
    }
        
    private func getColor(_ type:TodoFilterType) -> Color {
        return viewModel.selectedFilter == type ?
        Color(uiColor: .systemBlue) :
        Color(uiColor: .systemGray)
    }
        
    private func getImgageName(_ type:TodoFilterType) -> String {
        switch type {
        case .past: return "arrow.left.circle"
        case .today: return "calendar.circle"
        case .future: return "arrow.right.circle"
        }
    }
        
    private func getText(_ type:TodoFilterType) -> String {
        switch type {
        case .past: return I18N.past
        case .today: return I18N.today
        case .future: return I18N.future
        }
    }
}

    
#Preview {
    let today = Date()
    let modifiedDate = Calendar.current.date(byAdding: .day, value: 1, to: today)!
    
    ZStack {
        TodoListVCSwiftUI(
            viewModel: MTodoListVMSwiftUI(
                [
                    TodoModel(
                        id: "",
                        title: "1",
                        date: Date(),
                        contents: "c",
                        isDone: false
                    ),
                    TodoModel(
                        id: "",
                        title: "2",
                        date: Date(),
                        contents: "c",
                        isDone: false
                    ),
                    TodoModel(
                        id: "",
                        title: "3",
                        date: Date(),
                        contents: "c",
                        isDone: false
                    ),
                    TodoModel(
                        id: "",
                        title: "3",
                        date: modifiedDate,
                        contents: "c",
                        isDone: false
                    )
                ]
            )
        )
    }
        
}

