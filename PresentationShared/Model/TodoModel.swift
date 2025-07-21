//
//  TodoState.swift
//  todoApp
//
//  Created by 조영태 on 5/11/25.
//

import Foundation
//import Differentiator
//internal import Differentiator

typealias TodoGroup = [TodoFilterType: [TodoModel]]

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

public extension TodoModelProtocol {
    var asTodoModel: TodoModel {
        return TodoModel(
            id: id,
            title: title,
            date: date,
            contents: contents,
            isDone: isDone
        )
    }
}

public struct TodoModel: TodoModelProtocol {
    public var id: String
    public var title: String
    public var date: Date
    public var contents: String
    public var isDone: Bool
    
    public init(id: String, title: String, date: Date, contents: String, isDone: Bool) {
        self.id = id
        self.title = title
        self.date = date
        self.contents = contents
        self.isDone = isDone
    }
    
    public static func == (lhs: TodoModel, rhs: TodoModel) -> Bool {
        let isSameDay = Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)

        return lhs.id == rhs.id
            && lhs.title == rhs.title
            && lhs.contents == rhs.contents
            && isSameDay
            && lhs.isDone == rhs.isDone
    }
    
    public func copyWith(
        title: String? = nil,
        date: Date? = nil,
        contents: String? = nil,
        isDone: Bool? = nil
    ) -> TodoModel {
        return TodoModel(
            id: self.id,
            title: title ?? self.title,
            date: date ?? self.date,
            contents: contents ?? self.contents,
            isDone: isDone ?? self.isDone
        )
    }
}

//extension TodoModel: IdentifiableType {
//    var identity: String { self.id }
//}
public protocol TodoSectionProtocol: Identifiable {
    associatedtype Item
    
    var id: String { get }
    var header: String { get }
    var items: [Item] { get }
}

public struct TodoSection: TodoSectionProtocol {
    public var id:String
    
    public var header: String
    public var items: [TodoModel]
    
    public init(header: String, items: [TodoModel]) {
        self.id = UUID().uuidString
        self.header = header
        self.items = items
    }
}

//extension TodoSection: SectionModelType {
//    typealias Item = TodoModel
//
//    init(original: TodoSection, items: [Item]) {
//        self = original
//        self.items = items
//    }
//}
