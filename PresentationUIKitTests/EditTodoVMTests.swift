//
//  CreateTodoVMTests.swift
//  PresentationUIKitTests
//
//  Created by 조영태 on 9/4/25.
//

import RxRelay
import RxSwift
import XCTest

@testable import Domain
@testable import PresentationUIKit

final class StubEditTodoUseCase: EditTodoUseCase {
    typealias Error = Swift.Error
    var error: Error?
    var repository: any TodoRepository

    init() {
        self.repository = MockTodoRepository()
    }

    func execute(
        _ target: any Todo, newTitle: String?, newDate: Date?, newContents: String?
    ) async throws -> any Todo {
        if let error = error { throw error }

        return TodoImpl(
            id: UUID().uuidString,
            title: newTitle ?? target.title,
            date: newDate ?? target.date,
            contents: newContents ?? target.contents,
            isDone: false
        )
    }

}

final class EditTodoVMTests: XCTestCase {
    var disposeBag: DisposeBag!
    var vm: EditTodoVM!
    var editTodoUseCase: StubEditTodoUseCase!

    override func setUpWithError() throws {
        self.disposeBag = DisposeBag()
        self.editTodoUseCase = StubEditTodoUseCase()
        self.vm = EditTodoVM(
            model: TodoModel(
                id: UUID().uuidString,
                title: "editTitle",
                date: Date(),
                contents: "contents",
                isDone: false
            ),
            useCase: .init(editTodo: editTodoUseCase)
        )
    }

    override func tearDownWithError() throws {
        vm = nil
        disposeBag = nil
        editTodoUseCase = nil
    }

    // Helper 함수: inputValid 검사
    private func assertInputValid(
        _ vm: CreateTodoVM,
        expected: Bool,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "inputValid check")

        vm.state.inputValid
            .drive(onNext: { valid in
                XCTAssertEqual(expected, valid)
                exp.fulfill()
            })
            .disposed(by: disposeBag)

        wait(for: [exp], timeout: 1.0)
    }

    private func changeData(_ vm: EditTodoVM) {
        vm.input.titleRelay.accept("title")
    }

    func testInputValidWhenTitleRemoveChangeUnChange_FalseTrueFalse() {
        let exp = expectation(
            description: "testInputValidWhenTitleRemoveChangeUnChange_FalseTrueFalse"
        )

        var results = [Bool]()

        vm.state.inputValid.skip(1)
            .drive(onNext: { valid in
                results.append(valid)
                if results.count == 3 {
                    print(results)
                    XCTAssertEqual(results, [false, true, false])
                    exp.fulfill()
                }
            })
            .disposed(by: disposeBag)
        let initalTitle = vm.input.titleRelay.value
        
        vm.input.titleRelay.accept("") // 제거
        vm.input.titleRelay.accept("change") // 변경
        vm.input.titleRelay.accept(initalTitle) // 그대로

        wait(for: [exp], timeout: 1.0)
    }

    func testInputValidWhenDateRemoveChangeUnChange_FasleTrueFalse() {
        let exp = expectation(
            description: "testInputValidWhenDateRemoveChangeUnChange_FasleTrueFalse"
        )

        var results = [Bool]()

        vm.state.inputValid.skip(1)
            .drive(onNext: { valid in
                results.append(valid)
                if results.count == 3 {
                    XCTAssertEqual(results, [false, true, false])
                    exp.fulfill()
                }
            })
            .disposed(by: disposeBag)

        let initalDate = vm.input.dateRelay.value
        
        vm.input.dateRelay.accept(nil)
        let today = Date()
        if let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) {
            vm.input.dateRelay.accept(tomorrow)
        }
        vm.input.dateRelay.accept(initalDate)


        wait(for: [exp], timeout: 1.0)
    }

    func testInputValidWhenContentsChangeUnChange_TrueFalse() {
        let exp = expectation(
            description: "testInputValidWhenContentsChangeUnChange_TrueFalse"
        )

        var results = [Bool]()

        vm.state.inputValid.skip(1)
            .drive(onNext: { valid in
                results.append(valid)
                if results.count == 2 {
                    XCTAssertEqual(results, [true, false])
                    exp.fulfill()
                }
            })
            .disposed(by: disposeBag)

        let inital = vm.input.contentRelay.value
        vm.input.contentRelay.accept("change")
        vm.input.contentRelay.accept(inital)

        wait(for: [exp], timeout: 1.0)
    }

    func testEdittedModelWhenSuccess_IsFilled() throws {
        let exp = expectation(
            description: "testCreateModelWhenSuccess_IsFilled check"
        )
        changeData(vm)

        vm.state.edittedModel
            .drive { _ in exp.fulfill() }
            .disposed(by: disposeBag)

        vm.input.editTap.accept(())

        wait(for: [exp], timeout: 1.0)
    }

    func testErrorWhenSuccess_IsNil() throws {
        let exp = expectation(description: "testErrorWhenSuccess_IsNil check")
        exp.isInverted = true
        changeData(vm)

        vm.state.error
            .drive { _ in exp.fulfill() }
            .disposed(by: disposeBag)

        vm.input.editTap.accept(())

        wait(for: [exp], timeout: 1.0)
    }

    func testErrorWhenFail_IsFilled() throws {
        let exp = expectation(description: "testErrorWhenFail_IsFilled check")

        self.editTodoUseCase.error = NSError(domain: "", code: 0, userInfo: nil)
        changeData(vm)

        vm.state.error
            .drive { error in
                XCTAssertNotNil(error, "Error가 반환 되어야 합니다.")
                exp.fulfill()
            }
            .disposed(by: disposeBag)

        vm.input.editTap.accept(())

        wait(for: [exp], timeout: 1.0)
    }
}

extension EditTodoVMTests: LoadingProtocolTests {
    func testChangeLoadingFlag_TrueToFalse() throws {
        let exp = expectation(
            description: "testChangeLoadingFlag_TrueToFalse check"
        )
        changeData(vm)

        observeLoadingChanges_TrueFalse { values in
            XCTAssertEqual(values, [true, false])
            exp.fulfill()
        }
        
        vm.input.editTap.accept(())
        
        wait(for: [exp], timeout: 1.0)
    }

}
