//
//  LoadingProtocolTests.swift
//  PresentationUIKitTests
//
//  Created by 조영태 on 9/5/25.
//

import XCTest
import RxSwift
@testable import PresentationUIKit

protocol LoadingProtocolTests: XCTestCase {
    associatedtype VM:LoadingProtocol
    var disposeBag: DisposeBag! { get set }
    var vm: VM! { get set }
}

extension LoadingProtocolTests {
    func observeLoadingChanges_TrueFalse(_ completion: @escaping ([Bool]) -> Void) {
        var values = [Bool]()

        vm.state.isLoading.skip(1)
            .drive(onNext: { value in
                values.append(value)
                if values.count == 2 {
                    completion(values)
                }
            })
            .disposed(by: disposeBag)
    }
}
