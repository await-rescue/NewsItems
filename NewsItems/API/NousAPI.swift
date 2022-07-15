//
//  NousAPI.swift
//  NousTest
//

import Foundation
import Combine

// Use an enum as we don't want an initialiser for this
enum NousAPI {
    // Define network loaders and the response type
    private static let newsNetworkService = NetworkService<NewsItem.Response>()
}

extension NousAPI {
    static func newsItems() -> AnyPublisher<NewsItem.Response, NetworkError> {
        let newsItemsUrl = URL(string: Endpoint.newsEndpoint.rawValue)!
        let request = URLRequest(url: newsItemsUrl)
        return newsNetworkService.execute(request: request)
    }
}
