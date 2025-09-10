//
//  AccessibilityID.swift
//  PresentationShared
//
//  Created by 조영태 on 9/10/25.
//

import Foundation

public enum UIID {
    public enum TodoList: String {
        case createButton
        case pastTapButton
        case todoList
    }
    
    public enum CreateTodo: String {
        case title
        case titleTextField
        case dateField
        case calendarField
        case conentsTextField
        case createButton
    }
    
    public enum EditTodo: String {
        case title
        case titleTextField
        case dateField
        case calendarField
        case conentsTextField
        case EditButton
    }
}
