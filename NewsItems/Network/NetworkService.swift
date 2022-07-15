//
//  NetworkService.swift
//  NousTest
//

import Foundation
import Combine

enum NetworkError: Error {
    case sessionFailed(error: URLError)
    case decodingError
    case other(Error)
}

/// Network service allows for execution of func that returns a generic Decodable type or network error for a given URL
struct NetworkService<Model: Decodable> {
    private let urlSession = URLSession.shared
    
    func execute(request: URLRequest) -> AnyPublisher<Model, NetworkError> {
        // Generics for calling this function are inferred through the return type of this function
        urlSession.publisher(for: request)
    }
}
