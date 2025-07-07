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
    
    func handleLoadingWithUnretained<Object: AnyObject>(
        _ object: Object,
        _ update: @escaping (Object, Bool) -> Void
    ) -> Publishers.HandleEvents<Self> {
        self.handleEvents(
            receiveSubscription: { [weak object] _ in
                guard let object else { return }
                update(object, true)
            },
            receiveCompletion: { [weak object] _ in
                guard let object else { return }
                update(object, false)
            },
            receiveCancel: { [weak object] in
                guard let object else { return }
                update(object, false)
            }
        )
    }
    
    func catchWithUnretained<Object: AnyObject, Fallback: Publisher>(
        _ object: Object,
        _ fallback: @escaping (_ this:Object, Failure) -> Fallback
    ) -> Publishers.Catch<Self, Fallback> {
        return self.catch { [weak object] error in
            guard let object = object else {
                return Empty() as! Fallback
            }
            return fallback(object, error)
        }
    }
}
