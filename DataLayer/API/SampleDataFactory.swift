//
//  SampleDataFactory.swift
//  DataLayer
//
//  Created by 조영태 on 7/19/25.
//

import Foundation

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
