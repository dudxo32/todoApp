//
//  AppDIContainer.swift
//  todoApp
//
//  Created by 조영태 on 7/25/25.
//

import Foundation
import Swinject

class DefaultAppDIContainer {
    let container = Container()

    init(_ assemblys: [Assembly] = []) {
        _ = Assembler(
            [
             
                // 전역 공통 의존성 (예: 네트워크, 유틸 등)
            ] + assemblys,
            container: container
        )
    }
}
