//
//  DateInputStackViewSwiftUI.swift
//  todoApp
//
//  Created by 조영태 on 6/13/25.
//

import SwiftUI
import Shared

struct DateInputStackView: View {
    @Binding var date: Date?
    @State private var localDate: Date = Date() // 내부 관리용
        
    @State private var showDatePicker = false

    init(date: Binding<Date?>) {
        self._date = date
        // ✅ nil이면 오늘 날짜로 초기화
        self._localDate = State(initialValue: date.wrappedValue ?? Date())
    }
        
    var labelColor:Color {
        return date == nil ? Color(uiColor: .lightGray) : .black
    }
        
    var labelText:String {
        return date == nil ? I18N.selectDate : dateToString(localDate)
    }
        
    var body: some View {
        VStack(alignment: .leading) {
            Text(labelText)
                .foregroundStyle(labelColor)
                .frame(maxWidth: .infinity, minHeight: 36, alignment: .leading)
                .onTapGesture {
                    withAnimation {
                        showDatePicker.toggle()
                    }
                }

            if showDatePicker {
                VStack {
                    Divider()
                        
                    DatePicker(
                        "",
                        selection: $localDate,
                        displayedComponents: .date
                    )
                    .task { date = localDate }
                    .onChange(of: localDate) { date = $0 }
                    .datePickerStyle(.graphical)
                    .transition(
                        .asymmetric(
                            insertion: 
                                    .move(edge: .top)
                                    .combined(with: .opacity),
                            removal: .move(edge: .top).combined(with: .opacity)
                        )
                    )
                }
            }

        }
        .padding(8)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(uiColor: .systemGray5), lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
        
    private func dateToString(_ date:Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MMMM dd, EEEE"
        formatter.locale = Locale(identifier: "ko")

        return formatter.string(from: date)
    }
}



#Preview {
    @State var d:Date? = nil
    DateInputStackView(date: $d)
}
