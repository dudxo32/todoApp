//
//  TodoSectionModel.swift
//  todoApp
//
//  Created by 조영태 on 7/21/25.
//

import Foundation
internal import Differentiator
import Domain
import PresentationShared

typealias TodoGroup = [TodoFilterType: [TodoModel]]

struct TodoModel: TodoModelProtocol {
    var id: String
    var title: String
    var date: Date
    var contents: String
    var isDone: Bool
    
    init(id: String, title: String, date: Date, contents: String, isDone: Bool) {
        self.id = id
        self.title = title
        self.date = date
        self.contents = contents
        self.isDone = isDone
    }
    
    init(_ `protocol`:any TodoModelProtocol) {
        self.id = `protocol`.id
        self.title = `protocol`.title
        self.date = `protocol`.date
        self.contents = `protocol`.contents
        self.isDone = `protocol`.isDone
    }
}

extension TodoModel: IdentifiableType {
    var identity: String { self.id }
}

struct TodoSection: TodoSectionProtocol {
    var id: String
    var header: String
    var items: [TodoModel]
    
    init(header: String, items: [TodoModel]) {
       self.id = UUID().uuidString
       self.header = header
       self.items = items
   }
}

extension TodoSection: SectionModelType {
    init(original: TodoSection, items: [TodoModel]) {
        self = original
        self.items = items
    }
}
