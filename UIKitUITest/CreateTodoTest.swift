//
//  CreateTodoTest.swift
//  UIKitUITest
//
//  Created by 조영태 on 9/10/25.
//

import XCTest
import PresentationShared

final class CreateTodoTest: XCTestCase {
    var app: XCUIApplication!
    var createTodoScreenObject: CreateTodoScreenObject!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launch()
        createTodoScreenObject = CreateTodoScreenObject(app: app)
        let list = TodoListScreenObject(app: app)
        list.createTap()
    }

    override func tearDownWithError() throws {
        app = nil
        createTodoScreenObject = nil
    }
    
    func testInitialState() throws {
        XCTAssertFalse(createTodoScreenObject.createButton.isEnabled)
        XCTAssertTrue(createTodoScreenObject.titleField.isHittable)
        XCTAssertTrue(createTodoScreenObject.contentField.isHittable)
        XCTAssertTrue(createTodoScreenObject.dateLabel.isHittable)
        XCTAssertFalse(createTodoScreenObject.datePicker.isHittable)
    }
    
    func testDatePickerToggle() throws {
        createTodoScreenObject.dateLabel.tap()
        XCTAssertTrue(createTodoScreenObject.datePicker.isHittable)
        
        createTodoScreenObject.dateLabel.tap()
        XCTAssertFalse(createTodoScreenObject.datePicker.isHittable)
    }
    
    
    func testInputAndValidation() throws {
        createTodoScreenObject.inputData()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MMMM dd, EEEE"
        formatter.locale = Locale(identifier: "ko")

        guard formatter.date(from: createTodoScreenObject.dateLabel.label) != nil else {
            XCTFail("UILabel 텍스트를 Date로 변환할 수 없습니다: \(createTodoScreenObject.dateLabel.label)")
            return
        }
        
        XCTAssertTrue(createTodoScreenObject.createButton.isEnabled)
    }
    
    func testCreateTodoAddsItemToList() throws {
        let title = "title - \(UUID().uuidString)"
        createTodoScreenObject.inputData(title:title)

        createTodoScreenObject.createButton.tap()

        let todoList = TodoListScreenObject(app: app)
        let todoCell = todoList.todoList.cells.staticTexts[title]
        XCTAssertTrue(todoCell.waitForExistence(timeout: 5))
    }
    
    private func inputData(title:String = "title Todo") {
        let titleField = createTodoScreenObject.titleField
        let contentField = createTodoScreenObject.contentField
        let dateLabel = createTodoScreenObject.dateLabel
        
        titleField.tap()
        titleField.typeText(title)
        
        contentField.tap()
        contentField.typeText("contents")
        
        dateLabel.tap()
    }
}

extension XCUIElement {
    func waitForHittable(timeout: TimeInterval = 2) -> Bool {
        let predicate = NSPredicate(format: "isHittable == true")
        let expectation = XCTNSPredicateExpectation(
            predicate: predicate,
            object: self
        )
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
}

struct CreateTodoScreenObject {
    let app: XCUIApplication
    
    var titleField: XCUIElement {
        app.textFields[UIID.CreateTodo.titleTextField.value]
    }
    var contentField: XCUIElement {
        app.textViews[UIID.CreateTodo.conentsTextField.value]
    }
    var dateLabel: XCUIElement { app.buttons[UIID.CreateTodo.dateLabel.value] }
    var datePicker: XCUIElement {
        app.datePickers[UIID.CreateTodo.datePicker.value]
    }
    var createButton: XCUIElement {
        app.buttons[UIID.CreateTodo.createButton.value]
    }
    
    func inputData(title:String = "title Todo") {
        titleField.tap()
        titleField.typeText(title)
        
        contentField.tap()
        contentField.typeText("contents")
        
        dateLabel.tap()
    }
}
