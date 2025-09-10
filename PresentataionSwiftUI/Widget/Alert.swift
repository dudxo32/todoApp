//
//  Alert.swift
//  todoApp
//
//  Created by 조영태 on 7/7/25.
//

import SwiftUI
import Shared

extension View {
    func errorAlert(isPresented: Binding<Bool>, message: String) -> some View {
        return self.alert(
            I18N.error,
            isPresented: isPresented,
            actions: {
                Button(I18N.confirm, role: .cancel) {}
            },
            message: { Text(message) }
        )
    }
            
    func retryAlert(isPresented: Binding<Bool>, message: String, retryAction:@escaping () -> Void, noneAction:@escaping () -> Void) -> some View {
        self.alert(
            I18N.serverError,
            isPresented: isPresented,
            actions: {
                Button(I18N.confirm, role: .cancel) { noneAction() }
                Button(I18N.retry) { retryAction() }
            },
            message: { Text(message) }
        )

    }
}
   
 
