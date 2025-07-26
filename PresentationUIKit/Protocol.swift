//
//  IOProtocol.swift
//  todoApp
//
//  Created by 조영태 on 5/1/25.
//

import Foundation
internal import RxSwift

struct IOEmpty {}

protocol HasRxIO {
    associatedtype Input
    associatedtype Output

//    var input: Input { get }
//    var output: Output { get }
    
    var disposeBag: DisposeBag { get }
}
