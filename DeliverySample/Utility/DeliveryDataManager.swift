//
//  DeliveryDataManager.swift
//  DeliverySample
//

import CoreData
import UIKit

class DeliveryDataManager: DeliveryDataManagerProtocol {
        
    var context: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    func saveDeliveryContext() {
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
}

protocol DeliveryDataManagerProtocol: AnyObject {
    var context: NSManagedObjectContext { get }
    func saveDeliveryContext()
}
