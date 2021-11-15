//
//  DeliveryTableCellViewModel.swift
//  DeliverySample
//
//  Created by sarfaraz.d.khan on 12/11/2021.
//  Copyright © 2021 SARFARAZ KHAN. All rights reserved.
//

import Foundation

class DeliveryTableCellViewModel {
    
    private var deliveryModel: Delivery
    
    init(_ model: Delivery) {
        deliveryModel = model
    }
    
    var from: String {
        return "From: \(deliveryModel.name), \(deliveryModel.start)"
    }
    
    var to: String {
        return "To: \(deliveryModel.end)"
    }
    
    var price: String {
        return "$\(deliveryModel.price)"
    }
    
    var goodsPictureURLString: String {
        return deliveryModel.goodsPicture
    }
    
    var isFavorite: Bool {
        set {
            deliveryModel.isFavorite = newValue
            NotificationCenter.default.post(Notification(name: Notification.Name.favoriteStateDidChange))
        } get {
            return deliveryModel.isFavorite
        }
    }
}
