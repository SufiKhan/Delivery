//
//  DeliveryListTableViewCell.swift
//  iDelivery
//
//

import UIKit
import Kingfisher

class DeliveryTableViewCell: UITableViewCell {

    static let CellIdentifier = "DeliveryCell"

    private let deliveryImageViewHeight: CGFloat = Constants.eighty

    private let fromLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = Constants.two
        label.textColor = .darkGray
        label.font = Constants.italicFont
        return label
    }()
    
    private let toLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = Constants.one
        label.textColor = .darkGray
        label.font = Constants.italicFont
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = Constants.one
        label.textColor = .black
        label.font = Constants.boldFont
        return label
    }()

    private let deliveryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Constants.eighty / CGFloat(Constants.two)
        return imageView
    }()
    
    private let favoriteImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "star_selected")
        return imageView
    }()
    
    private let placeholderImage = UIImage(named: "truck")
    
    var viewModel: DeliveryTableCellViewModel? {
        didSet {
            configureData()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func setupUI() {
        backgroundColor = .white
        accessoryType = .disclosureIndicator
        selectionStyle = .none
        contentView.addSubview(deliveryImageView)
        contentView.addSubview(fromLabel)
        contentView.addSubview(toLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(favoriteImage)
        contentView.subViewRemoveMaskConstraint()
        NSLayoutConstraint.activate([
            deliveryImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.ten),
            deliveryImageView.widthAnchor.constraint(equalToConstant: deliveryImageViewHeight),
            deliveryImageView.heightAnchor.constraint(equalToConstant: deliveryImageViewHeight),
            deliveryImageView.topAnchor.constraint(equalTo: topAnchor, constant: Constants.ten),

            fromLabel.leadingAnchor.constraint(equalTo: deliveryImageView.trailingAnchor, constant: Constants.ten),
            fromLabel.trailingAnchor.constraint(equalTo: favoriteImage.leadingAnchor, constant: -Constants.ten),
            fromLabel.topAnchor.constraint(equalTo: deliveryImageView.topAnchor, constant: Constants.ten),

            toLabel.leadingAnchor.constraint(equalTo: fromLabel.leadingAnchor),
            toLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Constants.ten),
            toLabel.topAnchor.constraint(equalTo: fromLabel.bottomAnchor, constant: Constants.ten),

            priceLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Constants.twenty),
            priceLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Constants.ten),
            
            favoriteImage.widthAnchor.constraint(equalToConstant: Constants.twenty),
            favoriteImage.heightAnchor.constraint(equalToConstant: Constants.twenty),
            favoriteImage.trailingAnchor.constraint(equalTo: priceLabel.trailingAnchor),
            favoriteImage.topAnchor.constraint(equalTo: deliveryImageView.topAnchor)
            ])
    }
    
    func configureData() {
        if let from = viewModel?.from {
            fromLabel.text = from
        }
        if let to = viewModel?.to {
            toLabel.text = to
        }
        if let price = viewModel?.price {
            priceLabel.text = price
        }
        guard let urlString = viewModel?.goodsPictureURLString else {
            deliveryImageView.image = placeholderImage
            return
        }
        if let isFav = viewModel?.isFavorite {
            favoriteImage.isHidden = !isFav
        }
        deliveryImageView.kf.setImage(with: URL(string: urlString), placeholder: placeholderImage, options: nil, progressBlock: nil)
        
    }
}
