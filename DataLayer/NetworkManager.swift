//
//  NetworkManager.swift
//  DataLayer
//
//  Created by 조영태 on 7/18/25.
//

import Foundation
internal import Moya

public enum Method {
    case post, get, put, delete
}

public enum NetworkTask {
    case requestPlain
    case requestJSONEncodable(Encodable)
    case requestJSONEncodableToQuery(Encodable)
}

/// Data 환경
@frozen
public enum DataEnvironment: String {
    case stub = "stub"
    case local = "local"
    case production = "production"
}

public protocol APITarget {

    /// The target's base `URL`.
    var baseURL: URL { get }

    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String { get }

    /// The HTTP method used in the request.
    var method: Method { get }

    /// Provides stub data for use in testing. Default is `Data()`.
    var sampleData: Data { get }

    /// The type of HTTP task to be performed.
    var task: NetworkTask { get }

    /// The headers to be used in the request.
    var headers: [String: String]? { get }
}

public extension APITarget {
    /// Provides stub data for use in testing. Default is `Data()`.
    var sampleData: Data { Data() }
}

public final class NetworkManager<Target: APITarget> {
    private let provider: MoyaProvider<AnyTarget>
    
    public init(_ environment: DataEnvironment) {
        switch environment {
        case .production:
            self.provider = MoyaProvider<AnyTarget>()
        case .stub:
            self.provider = MoyaProvider<AnyTarget>(stubClosure: MoyaProvider.delayedStub(1))
        case .local:
            fatalError("Local environment not supported")
        }
    }
    
    // 응답 데이터의 헤더 등 여러 데이터 확인 가능한 Response 반환
    func requestResponse(_ request: Target) async throws -> Response {
        let result = await withCheckedContinuation { continuation in
            let anyTarget = AnyTarget(base: request)
            provider.request(anyTarget) { result in
                continuation.resume(returning: result)
            }
        }
        
        return try result.get()
    }
    
    // 내부 에서 바로 디코딩 해서 반환
    func requestData<R: Decodable>(_ request: Target) async throws -> R {
        let result = await withCheckedContinuation { continuation in
            let anyTarget = AnyTarget(base: request)
            provider.request(anyTarget) { result in
                continuation.resume(returning: result)
            }
        }
        switch result {
        case .success(let response):
            return try response.toDecoded(type: R.self)
        case .failure(let error):
            throw error
        }
    }
}


private struct AnyTarget: TargetType {
    let base: APITarget

    var baseURL: URL { base.baseURL }
    var path: String { base.path }
    var method: Moya.Method {
        switch base.method {
        case .post:
            return .post
        case .get:
            return .get
        case .put:
            return .put
        case .delete:
            return .delete
        }
    }
    
    var sampleData: Data { base.sampleData }
    var task: Moya.Task {
        switch base.task {
        case .requestPlain:
            return .requestPlain
        case .requestJSONEncodable(let encodable):
            return .requestJSONEncodable(encodable)
        case .requestJSONEncodableToQuery(let encodable):
            return .requestJSONEncodableToQuery(encodable)
        }
    }
    
    var headers: [String : String]? { base.headers }
}

private extension Moya.Task {
    static func requestJSONEncodableToQuery(_ encodable: (any Encodable)) -> Moya.Task {
        do {
            let param = try encodable.toJson()

            return .requestParameters(
                parameters: param,
                encoding: URLEncoding.queryString
            )
        } catch {
            assertionFailure(error.localizedDescription)
            return .requestPlain
        }
    }
}

private extension Response {
    func toDecoded<R: Decodable>(type: R.Type) throws -> R {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            let decoded = try decoder.decode(R.self, from: self.data)

            return decoded
        } catch {
            throw DataError.decodedFailed
        }
    }
}

private extension Encodable {
    func toJson() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dictionary = json as? [String: Any] else {
            throw DataError.jsonFailed
        }

        return dictionary
    }
}
