//
//  PresentationUIKitTests.swift
//  PresentationUIKitTests
//
//  Created by 조영태 on 7/21/25.
//

import RxCocoa
import RxSwift
import XCTest

@testable import PresentationUIKit

final class TodoInputVMTests: XCTestCase {
    var vm: TodoInputVM!
    var disposeBag: DisposeBag!

    override func setUpWithError() throws {
        let input = TodoInputVM.Input(
            titleRelay: BehaviorRelay(value: ""),
            dateRelay: BehaviorRelay(value: nil),
            contentRelay: BehaviorRelay(value: "")
        )
        
        vm = TodoInputVM(testInput: input)
        disposeBag = DisposeBag()
    }

    override func tearDownWithError() throws {
        vm = nil
        disposeBag = nil
    }

    func testTitle() throws {
        let expectation = XCTestExpectation(description: "제목 입력 테스트 오류")
        let title = "Todo Title"
        
        vm.state.title
            .skip(1) // 초기값("") 제외
            .drive(onNext: { value in
                XCTAssertEqual(value, title)
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        vm.input.titleRelay.accept(title)

        wait(for: [expectation], timeout: 1.0)
    }
    
    func testDate() throws {
        let expectation = XCTestExpectation(description: "날짜 입력 테스트 오류")
        let date = Date()
        
        vm.state.date
            .skip(1) // 초기값("") 제외
            .drive(onNext: { value in
                XCTAssertEqual(value, date)
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        vm.input.dateRelay.accept(date)

        wait(for: [expectation], timeout: 1.0)
    }
    
    func testContents() throws {
        let expectation = XCTestExpectation(description: "내용 입력 테스트 오류")
        let contents = "Contents"
        
        vm.state.contents
            .skip(1) // 초기값("") 제외
            .drive(onNext: { value in
                XCTAssertEqual(value, contents)
                expectation.fulfill()
            })
            .disposed(by: disposeBag)

        vm.input.contentRelay.accept(contents)

        wait(for: [expectation], timeout: 1.0)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {

            // Put the code you want to measure the time of here.
        }
    }

}
