//
//  TodoModel.swift
//  PresentataionSwiftUI
//
//  Created by 조영태 on 7/25/25.
//

import Foundation
import PresentationShared

typealias TodoGroup = [TodoFilterType: [TodoModel]]

struct TodoModel: TodoModelProtocol {
    var id: String
    var title: String
    var date: Date
    var contents: String
    var isDone: Bool

    init(id: String, title: String, date: Date, contents: String, isDone: Bool)
    {
        self.id = id
        self.title = title
        self.date = date
        self.contents = contents
        self.isDone = isDone
    }

    init(_ `protocol`: any TodoModelProtocol) {
        self.id = `protocol`.id
        self.title = `protocol`.title
        self.date = `protocol`.date
        self.contents = `protocol`.contents
        self.isDone = `protocol`.isDone
    }

    public static func == (lhs: TodoModel, rhs: TodoModel) -> Bool {
        let isSameDay = Calendar.current.isDate(lhs.date, inSameDayAs: rhs.date)

        return lhs.id == rhs.id
            && lhs.title == rhs.title
            && lhs.contents == rhs.contents
            && isSameDay
            && lhs.isDone == rhs.isDone
    }
}

struct TodoSection: TodoSectionProtocol, Equatable {
    var id: String
    var header: String
    var items: [TodoModel]

    init(header: String, items: [TodoModel]) {
        self.id = UUID().uuidString
        self.header = header
        self.items = items
    }

    public static func == (lhs: TodoSection, rhs: TodoSection) -> Bool {
        return lhs.header == rhs.header
            && lhs.items == rhs.items
            && lhs.id == rhs.id
    }
}
