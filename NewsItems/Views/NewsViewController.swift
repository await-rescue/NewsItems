//
//  ViewController.swift
//  NousTest
//

import UIKit
import Combine
import MessageUI

class NewsViewController: UITableViewController {
    private let viewModel = NewsViewModel()
    private var cancellable: AnyCancellable?

    override func viewDidLoad() {
        super.viewDidLoad()

        createBindings()
        configureSearchController()
        tableView.register(NewsItemCell.self, forCellReuseIdentifier: "NewsItemCell")
        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableView.automaticDimension
    }

    func createBindings() {
        // Whenever news items update, reload the table data
        cancellable = viewModel.$newsItems
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: { items in
                self.tableView.reloadData()
            })
    }
    
    func configureSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Type here to search"
        navigationItem.searchController = searchController
    }
}

// MARK: TableView methods
extension NewsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.newsItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsItemCell") as! NewsItemCell
        cell.selectionStyle = .none
        
        let item = viewModel.newsItems[indexPath.row]

        cell.configure(headline: item.title,
                       body: item.description)
        
        // Set an indicator of what row the cell was originally intended for
        cell.tag = indexPath.row
        // Clear the image in case we are unable to replace it when the cell is reused
        cell.setImage(nil)
        // Check the cache first, if cache misses, async load the image
        if let cachedImage = CacheService.cache.object(forKey: NSString(string: item.imageUrl.absoluteString)) {
            cell.setImage(cachedImage)
        } else {
            Task {
                let request = URLRequest(url: item.imageUrl)
                async let (imageData, _) = try URLSession.shared.data(for: request)
                if let image = try await UIImage(data: imageData) {
                    if cell.tag == indexPath.row {
                        cell.setImage(image)
                        CacheService.cache.setObject(image, forKey: NSString(string: item.imageUrl.absoluteString))
                        tableView.reloadRows(at: [indexPath], with: .fade)
                    }
                }
            }
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.newsItems[indexPath.row]
        sendEmail(subject: item.title, body: item.description)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}
/// MARK: - Mail Compose delegate methods
extension NewsViewController: MFMailComposeViewControllerDelegate {
    func sendEmail(subject: String, body: String) {
        if MFMailComposeViewController.canSendMail() {
            let mailVC = MFMailComposeViewController()
            mailVC.mailComposeDelegate = self
            mailVC.setSubject(subject)
            mailVC.setMessageBody(body, isHTML: false)
            present(mailVC, animated: true)
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

/// MARK: - Search controller delegate methods
extension NewsViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        viewModel.search(for: searchText)
    }
}
