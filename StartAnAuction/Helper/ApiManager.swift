//
//  ApiManager.swift
//  StartAnAuction
//
//  Created by Arkadijs Makarenko on 21/08/2025.
//

import Foundation
import Combine

struct APIConfig: Equatable {
    let baseURL: URL
    static let prod  = APIConfig(baseURL: URL(string: "https://pie.up-co.com:3010/api/")!)
}

enum APIError: Error, Equatable {
    case invalidURL
    case requestFailed(description: String)
    case decodingFailed(description: String)

    var userMessage: String {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .requestFailed(let d):
            return "Request failed: \(d)"
        case .decodingFailed(let d):
            return "Failed to decode the server response: \(d)"
        }
    }
}


protocol MerchantServiceProtocol {
    func fetchMerchants() -> AnyPublisher<[Merchant], APIError>
}

final class APIManager: MerchantServiceProtocol {
    static let shared: any MerchantServiceProtocol = APIManager(config: .prod)

    private let config: APIConfig
    private let session: URLSession

    init(config: APIConfig, session: URLSession = .shared) {
        self.config = config
        self.session = session
    }

    private func endpoint(_ path: String) -> URL? {
        var base = config.baseURL
        if !base.absoluteString.hasSuffix("/") { base.appendPathComponent("") }
        return base.appendingPathComponent(path)
    }

    func fetchMerchants() -> AnyPublisher<[Merchant], APIError> {
        guard let url = endpoint("merchant") else {
            return Fail(error: .invalidURL).eraseToAnyPublisher()
        }

        return session.dataTaskPublisher(for: url)
            .tryMap { output -> Data in
                guard let http = output.response as? HTTPURLResponse else {
                    throw APIError.requestFailed(description: "No HTTPURLResponse")
                }
                guard (200...299).contains(http.statusCode) else {
                    let body = String(data: output.data, encoding: .utf8) ?? "<non-utf8 body>"
                    throw APIError.requestFailed(description: "HTTP \(http.statusCode): \(body)")
                }
                return output.data
            }
            .handleEvents(receiveOutput: { data in
                #if DEBUG
                if let s = String(data: data, encoding: .utf8) {
                    print("🔎 GET /merchant raw:", s)
                }
                #endif
            })
            .tryMap { data -> [Merchant] in
                if data.isEmpty { return [] }
                return try decodeNow([Merchant].self, from: data)

            }
            .mapError { error -> APIError in
                if let api = error as? APIError { return api }
                return .requestFailed(description: error.localizedDescription)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
}

private func decodeNow<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    // decoder.dateDecodingStrategy = .iso8601 // if needed
    do {
        return try decoder.decode(T.self, from: data)
    } catch {
        throw APIError.decodingFailed(description: String(describing: error))
    }
}
