//
//  NetworkEX.swift
//  Data
//
//  Created by 조영태 on 7/18/25.
//

import Foundation
import Shared

/// Data 환경
@frozen
public enum DataEnvironment: String {
    case stub = "stub"
    case local = "local"
    case production = "production"
}

extension _Concurrency.Task where Success == Never, Failure == Never {
    static func delayTwoSecond() async throws {
        try await _Concurrency.Task<Success, Failure>.sleep(for: .seconds(2))
    }
}

struct SampleDataFactory {
    private init() {}
    
    static func make<T: Encodable>(_ value: T) -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        do {
            return try encoder.encode(value)
        } catch {
            assertionFailure("sample data encoding error")
            return Data()
        }
    }

    static func makeRaw(_ dict: [String: Any]) -> Data {
        do {
            return try JSONSerialization.data(withJSONObject: dict)
        } catch {
            assertionFailure("sample data encoding error")
            return Data()
        }
    }

    static func loadJSONFile(named fileName: String) -> Data {
        guard
            let url = Bundle.main.url(
                forResource: fileName,
                withExtension: "json"
            )
        else {
            fatalError("Missing file: \(fileName).json")
        }
        return try! Data(contentsOf: url)
    }
}

//extension MoyaProvider {
//    static func makeProvider(for environment: APIEnvironment) -> MoyaProvider<
//        Target
//    > {
//        switch environment {
//        case .production:
//            return MoyaProvider<Target>()
//        case .stub:
//            return MoyaProvider<Target>(
//                stubClosure: MoyaProvider.delayedStub(1)
//            )
//        case .local:
//            assertionFailure("local environment not supported")
//            return MoyaProvider<Target>()
//        }
//    }
//
//    func request(_ target: Target) async -> Result<Response, MoyaError> {
//        await withCheckedContinuation { continuation in
//            self.request(target) { result in
//                continuation.resume(returning: result)
//            }
//        }
//    }
//}

