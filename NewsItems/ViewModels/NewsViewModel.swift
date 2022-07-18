//
//  NewsViewModel.swift
//  NousTest
//

import Foundation
import UIKit
import Combine

class NewsViewModel {
    @Published var newsItems = [NewsItem]()
    // Keep a private copy of all data as we will filter the published array
    private var allNewsItems = [NewsItem]()
    var newsItemsCancellable: AnyCancellable?
    
    init() {
        fetchData()
    }

    func fetchData() {
        newsItemsCancellable?.cancel()
        newsItemsCancellable = NousAPI.newsItems()
            .sink(receiveCompletion: { _ in }, receiveValue: {
                let items = $0.items
                // Set data
                self.newsItems = items
                self.allNewsItems = items
                
                // Fetch images and cache them in the background
                Task.detached(priority: .background) {
                    for item in items {
                        let request = URLRequest(url: item.imageUrl)
                        async let (imageData, _) = try URLSession.shared.data(for: request)
                        if let image = try await UIImage(data: imageData) {
                            CacheService.cache.setObject(image, forKey: NSString(string: item.imageUrl.absoluteString))
                        }
                    }
                }
            })
    }

    func search(for text: String) {
        guard text != "" else {
            newsItems = allNewsItems
            return
        }

        newsItems = allNewsItems.filter { $0.title.lowercased().contains(text.lowercased()) || $0.description.lowercased().contains(text.lowercased()) }
    }
}
