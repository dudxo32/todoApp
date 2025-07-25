//
//  LoadingIndicatorSwiftUI.swift
//  todoApp
//
//  Created by 조영태 on 7/7/25.
//

import SwiftUI

struct LoadingIndicator: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.2).ignoresSafeArea()
            ProgressView()
                .progressViewStyle(
                    CircularProgressViewStyle(tint: .white)
                )
        }
    }
}

#Preview {
    LoadingIndicator()
}
