//
//  UIKitUITest.swift
//  UIKitUITest
//
//  Created by 조영태 on 9/10/25.
//

import XCTest
import PresentationShared

final class TodoListUITests: XCTestCase {
    var app: XCUIApplication!
    var todoListScreen: TodoListScreenObject!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        todoListScreen = TodoListScreenObject(app: app)
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    @MainActor
    func testGoCreateTodoScreen() throws {
        
        todoListScreen.createTap()

        let titleField = app.navigationBars[UIID.CreateTodo.title.value]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
    }
    
    @MainActor
    func testGoEditTodoScreen() throws {
        
        todoListScreen.pastTapButtonTap()
        let cell = todoListScreen.getFirstCellInTodoList()
        cell.tap()
        
        let titleField = app.navigationBars[UIID.EditTodo.title.value]
        XCTAssertTrue(titleField.waitForExistence(timeout: 2))
    }
    
    @MainActor
    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}

struct TodoListScreenObject {
    let app: XCUIApplication
    
    var todoList: XCUIElement { app.tables[UIID.TodoList.table.value] }
    var createButton: XCUIElement { app.buttons[UIID.TodoList.createButton.value] }
    var pastTapButton: XCUIElement { app.tabBars.buttons[UIID.TodoList.pastTapButton.value] }
    
    func createTap() {
        createButton.tap()
    }
    
    func pastTapButtonTap() {
        pastTapButton.tap()
    }
    
    func getFirstCellInTodoList() -> XCUIElement {
        return todoList.cells.firstMatch
    }
}
