//
//  Delivery+CoreDataClass.swift
//  DeliverySample
//

import Foundation
import CoreData

@objc(Delivery)
class Delivery: NSManagedObject, Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case id, goodsPicture, deliveryFee, surcharge, route, sender
    }
    
    private enum RouteCodingKeys: String, CodingKey {
        case start, end
    }
    
    private enum SenderCodingKeys: String, CodingKey {
        case name
    }

    required convenience public init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else { fatalError("NSManagedObjectContext is missing") }
        let entity = NSEntityDescription.entity(forEntityName: "Delivery", in: context)!
        self.init(entity: entity, insertInto: context)
        do {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            id = try values.decode(String.self, forKey: .id)
            goodsPicture = try values.decode(String.self, forKey: .goodsPicture)
            let fee = try values.decode(String.self, forKey: .deliveryFee).replacingOccurrences(of: "$", with: "")
            let surcharge = try values.decode(String.self, forKey: .surcharge).replacingOccurrences(of: "$", with: "")
            let totalValue = (fee as NSString).floatValue + (surcharge as NSString).floatValue
            price = String(format:"%.2f", totalValue)
            let locationContainer = try values.nestedContainer(keyedBy: RouteCodingKeys.self, forKey: .route)
            start = try locationContainer.decode(String.self, forKey: .start)
            end = try locationContainer.decode(String.self, forKey: .end)
            let senderContainer = try values.nestedContainer(keyedBy: SenderCodingKeys.self, forKey: .sender)
            name = try senderContainer.decode(String.self, forKey: .name)
            isFavorite = false
            dateCreated = Date()
        } catch let e {
            print(e)
        }
        
    }
}
