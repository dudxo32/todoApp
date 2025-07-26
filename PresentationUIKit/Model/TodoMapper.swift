//
//  TodoMapper.swift
//  PresentationUIKit
//
//  Created by 조영태 on 7/25/25.
//

import Foundation
import Domain
import PresentationShared

extension TodoMapper {
    static func toModel(_ entity: Todo) -> TodoModel {
        return TodoModel(
            TodoMapper.toModelProtocol(entity)
        )
    }
}
