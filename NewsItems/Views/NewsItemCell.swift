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
    
    private func storeConstraints(imageHeight: CGFloat) {
        let imageHeightConstraint = headerImageView.heightAnchor.constraint(equalToConstant: imageHeight)
        imageHeightConstraint.priority = .defaultHigh
        
        imageConstraints = [
            headerImageView.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor, constant: 10),
            headerImageView.widthAnchor.constraint(equalTo: contentView.layoutMarginsGuide.widthAnchor),
            imageHeightConstraint,
            headerImageView.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
        ]
        
        stackViewConstraints = [
            stackView.topAnchor.constraint(equalTo: headerImageView.layoutMarginsGuide.bottomAnchor, constant: 10),
            stackView.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor)
        ]
    }
    
    private func activateConstraints(imageHeight: CGFloat = 200) {
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
        self.layoutIfNeeded()
    }
    
    /// Configure and add all the views to our contentView
    private func setupViews() {
        headerImageView.contentMode = .scaleAspectFit
        headerImageView.clipsToBounds = true
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
    
    func configure(headline: String, body: String, row: Int) {
        self.headline.text = headline
        self.body.text = body
        activateConstraints(imageHeight: headerImageView.image?.size.height ?? 0)
    }
    
    func setImage(_ image: UIImage) {
        headerImageView.image = image
        activateConstraints(imageHeight: image.size.height)
    }
}
