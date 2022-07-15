//
//  URLSession+Publisher.swift
//  NousTest
//

import Foundation
import Combine

extension URLSession {
    /// Helper function to create a publisher that fetches and decodes data from a URL
    func publisher<T: Decodable>(for request: URLRequest, decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<T, NetworkError> {
        dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: decoder)
            .print()
            .mapError({ error in
                switch error {
                case is Swift.DecodingError:
                    return .decodingError
                case let urlError as URLError:
                    return .sessionFailed(error: urlError)
                default:
                    return .other(error)
                }
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
