//
//  TextInputStackViewSwiftUI.swift
//  todoApp
//
//  Created by 조영태 on 6/12/25.
//

import SwiftUI

struct TextInputStackView: View {
    @Binding var title: String
    @Binding var contents: String
        
    var body: some View {
        VStack(spacing: 8) {
            // FiXME
            TextField("제목을 입력하세요", text: $title)
                .frame(height: 36)
                
            Divider().tint(Color(uiColor: .lightGray))
                
            TextEditor(text: $contents)
                .frame(minHeight: 36, maxHeight: 300)
                .fixedSize(horizontal: false, vertical: true)
                .padding(0)
                .padding(.leading, -4)
                .overlay(alignment: .leading, content: {
                    Text("내용을 입력하세요...")
                        .foregroundColor(Color(uiColor: .lightGray))
                        .opacity(contents.isEmpty ? 1 : 0)
                })
        }
        .padding(8)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(uiColor: .systemGray5), lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
            
}


#Preview {
    @State var a = "title"
    @State var b = "content"
    
    TextInputStackView(title: $a, contents: $b)
}
