//
//  DeliveryDetailViewController.swift
//  DeliverySample
//

import UIKit
import CoreData

class DeliveryDetailViewController: UIViewController {
    
    private let fromLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = .darkGray
        label.font = Constants.italicFont
        return label
    }()
    
    private let toLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .darkGray
        label.font = Constants.italicFont
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .right
        label.textColor = .black
        label.font = Constants.boldFont
        return label
    }()

    private let deliveryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private var viewModel: DeliveryTableCellViewModel
    private var favoriteButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        setDataForUI()
    }
    
    init(viewModel: DeliveryTableCellViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpView() {
        view.backgroundColor = .white
        self.title = "Details"
        view.addSubview(deliveryImageView)
        view.addSubview(fromLabel)
        view.addSubview(toLabel)
        view.addSubview(priceLabel)
        view.subViewRemoveMaskConstraint()
        NSLayoutConstraint.activate([
            deliveryImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            deliveryImageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            deliveryImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),

            priceLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.ten),
            priceLabel.topAnchor.constraint(equalTo: deliveryImageView.bottomAnchor, constant: Constants.ten),
            
            fromLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.ten),
            fromLabel.topAnchor.constraint(equalTo: priceLabel.topAnchor),
            fromLabel.trailingAnchor.constraint(equalTo: priceLabel.leadingAnchor),

            toLabel.leadingAnchor.constraint(equalTo: fromLabel.leadingAnchor),
            toLabel.topAnchor.constraint(equalTo: fromLabel.bottomAnchor, constant: Constants.ten),
            ])
        
        favoriteButton = UIButton(type: .custom)
        favoriteButton.setBackgroundImage(UIImage(named: "star"), for: .normal)
        favoriteButton.setBackgroundImage(UIImage(named: "star_selected"), for: .selected)
        favoriteButton.addTarget(self, action: #selector(addFavorite(sender:)), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: favoriteButton)
    }
    
    func setDataForUI() {
        favoriteButton.isSelected = viewModel.isFavorite
        fromLabel.text = viewModel.from
        toLabel.text = viewModel.to
        priceLabel.text = viewModel.price
        deliveryImageView.kf.setImage(with: URL(string: viewModel.goodsPictureURLString), placeholder: UIImage(named: "truck"), options: nil, progressBlock: nil)
    }
    
    @objc func addFavorite(sender: UIButton) {
        sender.isSelected = !sender.isSelected
        viewModel.isFavorite = sender.isSelected
    }
}
