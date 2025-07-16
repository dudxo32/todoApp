//
//  TodoCellSwiftUI.swift
//  todoApp
//
//  Created by 조영태 on 6/6/25.
//

import SwiftUI

extension SUI {
    private struct CircularCheckButton: View {
        let isChecked: Bool
        let action: (_ changedValue:Bool) -> Void
        
        var backgroundColor: Color {
            return isChecked ? Color(UIColor.systemBlue) : Color(
                UIColor.systemGray5
            )
        }
        
        var borderColor: Color {
            return isChecked ? Color(UIColor.systemGray5) : Color(
                UIColor.systemBlue
            )
        }
        
        var body: some View {
            
            Circle()
                .fill(backgroundColor)
                .frame(width: 30, height: 30)
                .overlay(
                    Circle()
                        .stroke(lineWidth: 2)
                        .fill(borderColor)
                )
                .gesture(
                    TapGesture(count: 1).onEnded { _ in
                        action(!isChecked)
                    }
                )
        }
    }

    struct TodoCell: View {
        let model: TodoModelProtocol
        let isDoneChanged: (_ changedValue:Bool) -> Void
        
        @State private var isPresentingDetail = false

        var dateStr: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd"
            formatter.locale = Locale(identifier: "ko")
            
            return formatter.string(from: model.date)
        }
        
        var body: some View {
            HStack(spacing: 8) {

                CircularCheckButton(
                    isChecked: model.isDone,
                    action: isDoneChanged
                )
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(model.title)
                            .font(.system(size: 16, weight: .bold))
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text(dateStr)
                            .font(.system(size: 12))
                    }
                    
                    Text(model.contents)
                        .font(.system(size: 14))
                        .lineLimit(1)
                }
            }
        }
    }
}

//#Preview {
//    @State var state:TodoModelProtocol = TodoModel(
//        id: "",
//        title: "",
//        date: Date(),
//        contents: "",
//        isDone: false
//    )
//    
//    
//    TodoCellSwiftUI(model: $state) { changedValue in
//        state = state.asTodoModel.copyWith(isDone: changedValue)
//    }
//}
