//
//  NewsViewModel.swift
//  NousTest
//

import Foundation
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
                self.newsItems = $0.items
                self.allNewsItems = $0.items
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
