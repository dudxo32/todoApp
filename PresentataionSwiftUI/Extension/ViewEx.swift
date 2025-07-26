//
//  ViewEx.swift
//  PresentataionSwiftUI
//
//  Created by 조영태 on 7/25/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func navigationTitleInline(_ title: String) -> some View {
        self
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
    }
}
