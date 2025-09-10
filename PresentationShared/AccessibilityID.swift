//
//  AccessibilityID.swift
//  PresentationShared
//
//  Created by 조영태 on 9/10/25.
//

import Foundation

public enum UIID {
    public enum TodoList {
        case createButton
        case pastTapButton
        case table
        
        public var value: String {
            return "\(Self.self)_\(self)"
        }
    }
    
    public enum CreateTodo {
        case title
        case titleTextField
        case dateLabel
        case datePicker
        case conentsTextField
        case createButton
        
        public var value: String {
            return "\(Self.self)_\(self)"
        }
    }
    
    public enum EditTodo {
        case title
        case titleTextField
        case dateLabel
        case datePicker
        case conentsTextField
        case editButton
        
        public var value: String {
            return "\(Self.self)_\(self)"
        }
    }
}
