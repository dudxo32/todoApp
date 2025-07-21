//
//  TodoListVCSwiftUI.swift
//  todoApp
//
//  Created by 조영태 on 6/5/25.
//

import Combine
import SwiftUI
import Shared

var isPreview: Bool {
#if DEBUG
    return ProcessInfo.processInfo
        .environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
#else
    return false
#endif
}
extension SUI {
    private struct NoListLabel: View {
        var body: some View {
            Text(I18N.noList)
                .font(Font.system(size: 20, weight: .bold))

        }
    }

    private struct ListView: View {
        @ObservedObject var viewModel: SUI.TodoListVM
        @State private var tapCellItem: TodoModel?

        var body: some View {
            List {
                ForEach(viewModel.item) { section in
                    Section(header: Text(section.header)) {
                        ForEach(section.items) { item in

                            SUI.TodoCell(model: item) {
                                _ in viewModel.action(.toggleDone(item))
                            }
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.action(
                                    .presentModal(
                                        .edit(todo: item)
                                    )
                                )
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
                                Button(role: .destructive) {
                                    viewModel.action(.tapDelete(item))
                                } label: {
                                    Image(systemName: "trash")
                                }

                            }
                        }
                    }
                }
            }
            .overlay(content: {
                if viewModel.item.isEmpty && !viewModel.isShowLoadingIndicator {
                    NoListLabel()
                }
            })
            .scrollContentBackground(.hidden)
            .background(.white)
        }
    }

    struct TodoListVC: View {
        @StateObject var viewModel: SUI.TodoListVM
        @State private var isShowingError = false
        @State private var addedTodo: TodoModel?

        init(viewModel: SUI.TodoListVM) {
            self._viewModel = StateObject(wrappedValue: viewModel)
        }

        var body: some View {
            VStack(spacing: 0) {
                ListView(viewModel: viewModel)
                    .task {
                        if !isPreview { viewModel.action(.fetchItems) }
                    }

                TabView(viewModel: viewModel)
            }
            .navigationTitleInline(I18N.todo)
            .overlay {
                if viewModel.isShowLoadingIndicator {
                    SUI.LoadingIndicator()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    plusButton
                }
            }
            .errorAlert(
                isPresented: Binding(
                    get: { viewModel.error != nil },
                    set: { _, _ in }
                ),
                message: viewModel.error?.localizedDescription ?? ""
            )
            .retryAlert(
                isPresented: Binding(
                    get: { viewModel.serverError != nil },
                    set: { _, _ in }
                ),
                message: viewModel.serverError?.localizedDescription ?? "",
                retryAction: {
                    viewModel.action(.retryTrigger(_value: .retry))
                },
                noneAction: {
                    viewModel.action(.retryTrigger(_value: .none))
                }
            )
        }

        @ViewBuilder
        var plusButton: some View {
            Button(action: { viewModel.action(.presentModal(.create)) }) {
                Image(systemName: "plus.circle.fill")
            }
        }
    }

    struct TabView: View {
        @ObservedObject var viewModel: SUI.TodoListVM

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
                        VStack(spacing: 4) {
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

        private func getColor(_ type: TodoFilterType) -> Color {
            return viewModel.selectedFilter == type
            ? Color(uiColor: .systemBlue) : Color(uiColor: .systemGray)
        }

        private func getImgageName(_ type: TodoFilterType) -> String {
            switch type {
            case .past: return "arrow.left.circle"
            case .today: return "calendar.circle"
            case .future: return "arrow.right.circle"
            }
        }

        private func getText(_ type: TodoFilterType) -> String {
            switch type {
            case .past: return I18N.past
            case .today: return I18N.today
            case .future: return I18N.future
            }
        }
    }
}

#Preview {
    let today = Date()
    let modifiedDate = Calendar.current.date(
        byAdding: .day,
        value: 1,
        to: today
    )!
    let container = SUI.TodoListDIContainer()
    
    ZStack {
        SUI.TodoListVC(
            viewModel: SUI.MTodoListVM(
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
                    ),
                ]
            )
        )
    }

}
