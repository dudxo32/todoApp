//
//  TodoState.swift
//  todoApp
//
//  Created by 조영태 on 5/11/25.
//

import Foundation

@frozen
public enum TodoFilterType: Int, Identifiable {
    public var id:Int { self.rawValue }
    
    case past = 2
    case today = 0
    case future = 1

    static public var values: [TodoFilterType] {
        return [ .past, .today, .future]
    }
}

public protocol TodoModelProtocol: Equatable, Identifiable {
    var id: String { get }
    var title: String { get }
    var date: Date { get }
    var contents: String { get }
    var isDone: Bool { get }
}

public protocol TodoSectionProtocol: Identifiable {
    associatedtype Item
    
    var id: String { get }
    var header: String { get }
    var items: [Item] { get }
}


