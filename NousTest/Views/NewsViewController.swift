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
        tableView.estimatedRowHeight = UITableView.automaticDimension
    }

    func createBindings() {
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
        let cell = NewsItemCell()
        cell.selectionStyle = .none
        let item = viewModel.newsItems[indexPath.row]
        cell.configure(headline: item.title,
                       body: item.description,
                       imageUrl: item.imageUrl)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.newsItems[indexPath.row]
        sendEmail(subject: item.title, body: item.description)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func onLayoutChange() {
        tableView.beginUpdates()
        tableView.endUpdates()
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
