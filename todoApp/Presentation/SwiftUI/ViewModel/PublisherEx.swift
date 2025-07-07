//
//  PublisherEx.swift
//  todoApp
//
//  Created by 조영태 on 7/7/25.
//

import Combine

extension Publisher {
    func withUnretained<Object: AnyObject>(_ object: Object)
    -> AnyPublisher<(Object, Output), Failure> {
        self
            .compactMap { [weak object] value in
                guard let object = object else { return nil }
                return (object, value)
            }
            .eraseToAnyPublisher()
    }

    func handleLoading(_ isLoading: @escaping (Bool) -> Void) -> Publishers.HandleEvents<Self> {
        self.handleEvents(
            receiveSubscription: { _ in isLoading(true) },
            receiveCompletion: { _ in isLoading(false) },
            receiveCancel: { isLoading(false) }
        )
    }
}
