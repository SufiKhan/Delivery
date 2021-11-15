//
//  Delivery+CoreDataProperties.swift
//  DeliverySample
//

import Foundation
import CoreData


extension Delivery {

    @nonobjc class func fetchRequest() -> NSFetchRequest<Delivery> {
        return NSFetchRequest<Delivery>(entityName: "Delivery")
    }

    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var goodsPicture: String
    @NSManaged var start: String
    @NSManaged var end: String
    @NSManaged var price: String
    @NSManaged var isFavorite: Bool
    @NSManaged var dateCreated: Date

}
