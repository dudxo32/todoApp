//
//  Alert.swift
//  todoApp
//
//  Created by 조영태 on 7/7/25.
//

import SwiftUI

extension View {
    func errorAlert(isPresented: Binding<Bool>, message: String) -> some View {
        return self.alert(
            I18N.serverError,
            isPresented: isPresented,
            actions: {
                Button(I18N.confirm, role: .cancel) {}
            },
            message: { Text(message) }
        )
    }
            
    func retryAlert(isPresented: Binding<Bool>, message: String, retryAction:@escaping () -> Void) -> some View {
        self   .alert(
            I18N.serverError,
            isPresented: isPresented,
            actions: {
                Button(I18N.confirm, role: .cancel) {}
                Button(I18N.retry) { retryAction() }
            },
            message: { Text(message) }
        )

    }
}
   
 
