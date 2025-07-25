//
//  TodoMapper.swift
//  PresentataionSwiftUI
//
//  Created by 조영태 on 7/25/25.
//

import Foundation
import PresentationShared
import Domain

extension TodoMapper {
    static func toModel(_ entity: Todo) -> TodoModel {
        return TodoModel(TodoMapper.toModelProtocol(entity))
    }
}
