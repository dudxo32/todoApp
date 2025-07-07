//
//  ViewModelProtocol.swift
//  todoApp
//
//  Created by 조영태 on 2022/10/03.
//
import SwiftUI
import Combine
//import Combine

protocol ViewModelObservableObject: ObservableObject {
  associatedtype Action
  
  func action(_ action: Action)
}

protocol LoadingProtocolSwiftUI: ViewModelObservableObject {
    var isShowLoadingIndicator: Bool { get }
}

protocol RetryProtocolSwiftUI: ViewModelObservableObject {
    var retryError: Error? { get }
    var retryTrigger: PassthroughSubject<Void, Never> { get }
}
