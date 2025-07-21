//
//  TodoSectionModel.swift
//  todoApp
//
//  Created by 조영태 on 7/21/25.
//

import Foundation
internal import Differentiator

import PresentationShared

typealias TodoGroup = [TodoFilterType: [TodoModelDiff]]

struct TodoModelDiff: TodoModelProtocol, IdentifiableType {
    let underlying: TodoModel
    
    var identity: String { self.underlying.id }
    var id: String { self.underlying.id }
    var title: String { self.underlying.title }
    var date: Date { self.underlying.date }
    var contents: String { self.underlying.contents }
    var isDone: Bool { self.underlying.isDone }
}

struct TodoSectionDiff: TodoSectionProtocol, SectionModelType {
    var id: String
    var header: String
    var items: [TodoModelDiff]
    
    init(header: String, items: [TodoModelDiff]) {
       self.id = UUID().uuidString
       self.header = header
       self.items = items
   }
    
    init(original: TodoSectionDiff, items: [TodoModelDiff]) {
        self = original
        self.items = items
    }
}
