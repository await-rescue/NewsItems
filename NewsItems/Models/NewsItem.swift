//
//  NewsItem.swift
//  NousTest
//

import Foundation

struct NewsItem: Decodable {
    let id: Int
    let title: String
    let description: String
    let imageUrl: URL
}

extension NewsItem {
    struct Response: Decodable {
        var items: [NewsItem]
    }
}
