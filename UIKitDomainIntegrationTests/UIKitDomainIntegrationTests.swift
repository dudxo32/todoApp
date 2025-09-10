//
//  UIKitDomainIntegrationTests.swift
//  UIKitDomainIntegrationTests
//
//  Created by 조영태 on 9/6/25.
//

import XCTest
import RxSwift

@testable import PresentationUIKit
@testable import Domain

class FakeTodoRepository: TodoRepository {
    var error:Error?
    
    func fetchTodoList() async throws -> [any Todo] {
        fatalError()
    }
    
    func writeTodo(_ creatableTodo: any CreatableTodo) async throws -> any Todo {
        if let error = self.error { throw error }
        return TodoImpl(
            id: UUID().uuidString,
            title: creatableTodo.title,
            date: creatableTodo.date,
            contents: creatableTodo.contents,
            isDone: false
        )
    }
    
    func deleteTodo(_ id: String) async throws -> String {
        fatalError()
    }
    
    func updateTodo(_ todo: any Todo) async throws -> any Todo {
        fatalError()
    }
    
    
}
final class CreateTodoIntegrationTests: XCTestCase {

    var disposedBag: DisposeBag!
    var fake: FakeTodoRepository!
    var createVM: CreateTodoVM!
    
    override func setUpWithError() throws {
        disposedBag = DisposeBag()
        fake = FakeTodoRepository()
        let usecase = DefaultAddTodoUseCase(repository: fake)
        createVM = CreateTodoVM(useCase: .init(addTodo: usecase))
    }

    override func tearDownWithError() throws {
        disposedBag = nil
        createVM = nil
    }

    private func inputData(
        _ title:String = "title",
        _ date:Date = Date(),
        _ content:String = "content"
    ) {
        createVM.input.titleRelay.accept(title)
        createVM.input.dateRelay.accept(date)
        createVM.input.contentRelay.accept(content)
    }
    
    func testCreateTodoWhenTapCreateAndSuccess_ModelEmit () throws {
        let expTitle = "expTitle"
        let expDate = Date()
        let expContent = "expContent"
        
        inputData(expTitle, expDate, expContent)
        
        let expectation = XCTestExpectation(
            description: "testCreateTodoWhenTapCreateAndSuccess_ModelEmit"
        )
        
        createVM.state.createdModel.drive { model in
            XCTAssertNotNil(model.id)
            XCTAssertEqual(model.title, expTitle)
            XCTAssertEqual(model.date, expDate)
            XCTAssertEqual(model.contents, expContent)
            XCTAssertFalse(model.isDone)
            expectation.fulfill()
        
        }
        .disposed(by: disposedBag)
            
        createVM.input.createTap.accept(Void())
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCreateTodoWhenTapCreateAndSuccess_ErrorNil () throws {
        inputData()
        
        let expectation = XCTestExpectation(
            description: "testCreateTodoWhenTapCreateAndSuccess_ErrorNil"
        )
        expectation.isInverted = true
        
        createVM.state.error
            .drive()
            .disposed(by: disposedBag)

        createVM.input.createTap.accept(Void())
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCreateTodoWhenTapCreateAndFail_ErrorFilled () throws {
        // set error
        fake.error = DomainError.decodedFailed

        inputData()

        let expectation = XCTestExpectation(
            description: "testCreateTodoWhenTapCreateAndFail"
        )
        
        createVM.state.error.drive { error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        .disposed(by: disposedBag)
        
        createVM.input.createTap.accept(Void())
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testCreateTodoWhenTapCreateAndFail_ModelNotEmit () throws {
        // set error
        fake.error = DomainError.decodedFailed
        
        inputData()
        
        let expectation = XCTestExpectation(
            description: "testCreateTodoWhenTapCreateAndFail"
        )
        expectation.isInverted = true
        
        createVM.state.createdModel.drive { _ in
            expectation.fulfill()
        }
        .disposed(by: disposedBag)
        
        createVM.input.createTap.accept(Void())
        wait(for: [expectation], timeout: 1.0)
    }
}
