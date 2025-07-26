//
//  ViewModelProtocol.swift
//  todoApp
//
//  Created by 조영태 on 2022/10/03.
//
import SwiftUI
import Combine

protocol ViewModelObservableObject: ObservableObject {
    associatedtype Action
  
    func action(_ action: Action)
}

protocol LoadingProtocol: ViewModelObservableObject {
    var isShowLoadingIndicator: Bool { get }
}


enum RetryAction { case retry, none }

protocol RetryProtocol: ViewModelObservableObject {
    var retryError: Error? { get }
    var retryTrigger: PassthroughSubject<RetryAction, Never> { get }
}
