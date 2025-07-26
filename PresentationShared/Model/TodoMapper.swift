//
//  TodoMapper.swift
//  todoApp
//
//  Created by 조영태 on 5/11/25.
//

import Foundation
import Domain

public enum TodoMapper {
    static public func toEntity(_ model: any TodoModelProtocol) -> Todo {
        return TodoImpl(
            id: model.id,
            title: model.title,
            date: model.date,
            contents: model.contents,
            isDone: model.isDone
        )
    }
    
    static public func toModelProtocol(_ entity: Todo) -> any TodoModelProtocol {
        return TodoModelImpl(
            id: entity.id,
            title: entity.title,
            date: entity.date,
            contents: entity.contents,
            isDone: entity.isDone
        )
    }
    
//    static public func toModel1(_ entity: Todo) -> TodoModel {
//        return TodoModel(
//            id: entity.id,
//            title: entity.title,
//            date: entity.date,
//            contents: entity.contents,
//            isDone: entity.isDone
//        )
//    }
}
private struct TodoModelImpl: TodoModelProtocol {
    var id: String
    var title: String
    var date: Date
    var contents: String
    var isDone: Bool
}

private struct TodoImpl: Todo {
    var id: String
    var title: String
    var date: Date
    var contents: String
    var isDone: Bool
}
