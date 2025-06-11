//
//  ViewModelProtocol.swift
//  todoApp
//
//  Created by 조영태 on 2022/10/03.
//
import SwiftUI
//import Combine

protocol ViewModelableSwiftUI: ObservableObject {
  associatedtype Action
  
  func action(_ action: Action)
}
