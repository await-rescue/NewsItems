//
//  NewsItemCell.swift
//  NousTest
//

import Foundation
import UIKit

class NewsItemCell: UITableViewCell {
    var headerImageView = UIImageView()
    var stackView: UIStackView!
    var imageConstraints = [NSLayoutConstraint]()
    var stackViewConstraints = [NSLayoutConstraint]()

    var headline: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 2
        return label
    }()

    var body: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func storeConstraints(imageHeight: CGFloat = 250) {
        imageConstraints = [
            headerImageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: 10),
            headerImageView.widthAnchor.constraint(equalTo: contentView.layoutMarginsGuide.widthAnchor),
            headerImageView.heightAnchor.constraint(equalToConstant: imageHeight),
            headerImageView.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
        ]
        
        stackViewConstraints = [
            stackView.topAnchor.constraint(equalTo: headerImageView.layoutMarginsGuide.bottomAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor)
        ]
    }
    
    func reactivateConstraints(imageHeight: CGFloat = 250) {
        // Remove existing constraints and replace them with a modified image height
        for constraint in imageConstraints {
            constraint.isActive = false
        }
        for constraint in stackViewConstraints {
            constraint.isActive = false
        }

        storeConstraints(imageHeight: imageHeight)
        let constraints = imageConstraints + stackViewConstraints
        NSLayoutConstraint.activate(constraints)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        storeConstraints()
        reactivateConstraints()
    }
    
    /// Configure and add all the views to our contentView
    private func setupViews() {
        headerImageView.contentMode = .scaleAspectFit
        headerImageView.clipsToBounds = true
        headerImageView.frame = CGRect(x: 0,y: 0, width: 100, height: 100)
        headerImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(headerImageView)

        stackView = UIStackView(arrangedSubviews: [headline, body])
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        layoutIfNeeded()
    }
    
    func configure(headline: String, body: String, imageUrl: URL, row: Int) {
        headerImageView.image = nil
        self.headline.text = headline
        self.body.text = body
        
        // If we find a cached version we use that
        if let cachedImage = CacheService.cache.object(forKey: NSString(string: imageUrl.absoluteString)) {
            self.headerImageView.image = cachedImage
            self.reactivateConstraints(imageHeight: cachedImage.size.height)
            self.layoutIfNeeded()
        } else {
            // Otherwise fetch and cache the image
            Task {
                let request = URLRequest(url: imageUrl)
                do {
                    let (data, _) = try await URLSession.shared.data(for: request)

                    if let image = UIImage(data: data) {
                        headerImageView.image = image
                        CacheService.cache.setObject(image, forKey: NSString(string: imageUrl.absoluteString))
                        await MainActor.run {
                            self.reactivateConstraints(imageHeight: image.size.height)
                            self.layoutIfNeeded()
                        }
                    }
                } catch {
                    // If the image is missing or fails then don't make space for it
                    print(error)
                    self.reactivateConstraints(imageHeight: 0)
                    self.layoutIfNeeded()
                }
            }
        }
    }
}
