//
//  CreateTodoVMTests.swift
//  PresentationUIKitTests
//
//  Created by 조영태 on 9/4/25.
//

import RxSwift
import XCTest
import RxRelay

@testable import Domain
@testable import PresentationUIKit

final class StubAddTodoUseCase: AddTodoUseCase {
    var executeCalledRelay = PublishRelay<Bool>()

    typealias Error = Swift.Error
    var error: Error?
    var repository: any TodoRepository

    init() {
        self.repository = MockTodoRepository()
    }

    func execute(title: String, contents: String, date: Date) async throws
        -> any Todo
    {
        executeCalledRelay.accept(true)
        if let error = error { throw error }
        
        return TodoImpl(
            id: UUID().uuidString,
            title: title,
            date: date,
            contents: contents,
            isDone: false
        )
    }

}

final class CreateTodoVMTests: XCTestCase {
    var disposeBag: DisposeBag!
    var vm: CreateTodoVM1!
    var addTodoUseCase: StubAddTodoUseCase!

    override func setUpWithError() throws {
        self.disposeBag = DisposeBag()
        self.addTodoUseCase = StubAddTodoUseCase()
        self.vm = CreateTodoVM1(useCase: .init(addTodo: addTodoUseCase))
    }

    override func tearDownWithError() throws {
        vm = nil
        disposeBag = nil
        addTodoUseCase = nil
    }

    // Helper 함수: inputValid 검사
    private func assertInputValid(
        _ vm: CreateTodoVM1,
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

    private func inputData(_ vm: CreateTodoVM1) {
        vm.input.titleRelay.accept("title")
        vm.input.dateRelay.accept(Date())
        vm.input.contentRelay.accept("content")
    }
    
    func testInputValidWhenChangeTitleDateNil_IsFalse() {
        let exp = expectation(
            description: "testInputValidWhenChangeTitleDateNil_IsFalse"
        )

        var results = [Bool]()
        
        vm.state.inputValid.skip(1)
            .drive(onNext: { valid in
                results.append(valid)
                if results.count == 2 {
                    XCTAssertEqual(results, [false, false])
                    exp.fulfill()
                }
            })
            .disposed(by: disposeBag)
        
        vm.input.titleRelay.accept("Title")
        vm.input.titleRelay.accept("")
        
        wait(for: [exp], timeout: 1.0)
    }

    func testInputValidWhenChangeTitleDateFilled_TrueToFalse() {
        let exp = expectation(
            description: "testInputValidWhenChangeTitleDateFilled_TrueToFalse"
        )

        var results = [Bool]()
        
        // 초기 설정값및 date 입력시 skip
        vm.state.inputValid.skip(2)
            .drive(onNext: { valid in
                results.append(valid)
                if results.count == 2 {
                    XCTAssertEqual(results, [true, false])
                    exp.fulfill()
                }
            })
            .disposed(by: disposeBag)

        // Date 값 채우기
        vm.input.dateRelay.accept(Date())
        
        vm.input.titleRelay.accept("Title")
        vm.input.titleRelay.accept("")
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func testInputValidWhenChangeDateTitleEmpty_IsFalse() {
        let exp = expectation(
            description: "testInputValidWhenChangeDateTitleEmpty_IsFalse"
        )

        var results = [Bool]()
        
        vm.state.inputValid.skip(1)
            .drive(onNext: { valid in
                results.append(valid)
                if results.count == 2 {
                    XCTAssertEqual(results, [false, false])
                    exp.fulfill()
                }
            })
            .disposed(by: disposeBag)
        
        vm.input.dateRelay.accept(Date())
        vm.input.dateRelay.accept(nil)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func testInputValidWhenChangeDateTilteFilled_TrueToFalse() {
        let exp = expectation(
            description: "testInputValidWhenChangeDateTilteFilled_TrueToFalse"
        )

        var results = [Bool]()
        
        // 초기 설정값및 title 입력시 skip
        vm.state.inputValid.skip(2)
            .drive(onNext: { valid in
                results.append(valid)
                if results.count == 2 {
                    XCTAssertEqual(results, [true, false])
                    exp.fulfill()
                }
            })
            .disposed(by: disposeBag)
        
        // Title 값 채우기
        vm.input.titleRelay.accept("Title")
        
        vm.input.dateRelay.accept(Date())
        vm.input.dateRelay.accept(nil)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func testChangeLoadingFlag_TrueToFalse() throws {
        let exp = expectation(
            description: "testChangeLoadingFlag_TrueToFalse check"
        )
        inputData(vm)
//        vm = makeVM(title: "Title", date: Date(), content: "Content")
        
        var changedFlag = false
        // 초기값 스킵
        vm.state.isLoading.skip(1).drive { value in
            
            if !changedFlag {
                XCTAssertTrue(value, "isLoading flag가 true가 되어야 합니다.")
                changedFlag = true
            } else {
                XCTAssertFalse(value, "isLoading flag가 false가 되어야 합니다.")
                exp.fulfill()
            }
        }.disposed(by: disposeBag)
        
        vm.input.doneTap.accept(())
        
        wait(for: [exp], timeout: 1.0)
    }

    func testCreateModelWhenSuccess_IsFilled() throws {
        let exp = expectation(
            description: "testCreateModelWhenSuccess_IsFilled check"
        )
        inputData(vm)

        vm.state.createdModel
            .drive { _ in exp.fulfill() }
            .disposed(by: disposeBag)

        vm.input.doneTap.accept(()) // 버튼 탭 시뮬레이션

        wait(for: [exp], timeout: 1.0)
    }
    
    func testErrorWhenSuccess_IsNil() throws {
        let exp = expectation(description: "testErrorWhenSuccess_IsNil check")
        exp.isInverted = true
        inputData(vm)

        vm.state.error
            .drive { _ in exp.fulfill() }
            .disposed(by: disposeBag)

        vm.input.doneTap.accept(()) // 버튼 탭 시뮬레이션

        wait(for: [exp], timeout: 1.0)
    }
    
    func testErrorWhenFail_IsFilled() throws {
        let exp = expectation(description: "testErrorWhenFail_IsFilled check")
        
        self.addTodoUseCase.error = NSError(domain: "", code: 0, userInfo: nil)
        inputData(vm)

        vm.state.error
            .drive { error in
                XCTAssertNotNil(error, "Error가 반환 되어야 합니다.")
                exp.fulfill()
            }
            .disposed(by: disposeBag)

        vm.input.doneTap.accept(()) // 버튼 탭 시뮬레이션

        wait(for: [exp], timeout: 1.0)
    }
    
    // 통합 테스트
    func testCallUseCaseExecuteWhenDoneTap() throws {
        let exp = expectation(description: "CallUseCaseExecute check")
        inputData(vm)

        addTodoUseCase.executeCalledRelay
            .subscribe { value in
                XCTAssertTrue(value, "execute()가 호출되어야 합니다.")
                exp.fulfill()
            }
            .disposed(by: disposeBag)
        
        vm.input.doneTap.accept(()) // 버튼 탭 시뮬레이션

        wait(for: [exp], timeout: 1.0)
    }
}
