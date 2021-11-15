//
//  DeliveryDetailVCTests.swift
//  DeliverySampleTests
//

import XCTest
import CoreData
@testable import DeliverySample

class DeliveryDetailVCTests: XCTestCase {
    
    var sut: DeliveryDetailViewController?
    var fetchDelegate: MockFetchResultDelegate!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        sut = nil
//        fetchDelegate = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddFavorite() {
        let mockDM = MockDataManager()
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Delivery", into: mockDM.context) as! Delivery
        entity.name = "test"
        entity.isFavorite = false
        mockDM.saveInCoreDataForTest = true
        mockDM.saveDeliveryContext()
        let vm = DeliveryTableCellViewModel(entity)
        sut = DeliveryDetailViewController(viewModel: vm)
       
        let request: NSFetchRequest<Delivery> = Delivery.fetchRequest()
        let sort = NSSortDescriptor(key: "dateCreated", ascending: true)
        request.sortDescriptors = [sort]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: mockDM.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchDelegate = MockFetchResultDelegate(dm: mockDM)
        fetchedResultsController.delegate = fetchDelegate
        try? fetchedResultsController.performFetch()
        
        sut?.addFavorite(sender: UIButton())
        XCTAssertTrue(fetchDelegate?.fetchDelegateDidChangedCalled ?? false)
    }
}

final class MockFetchResultDelegate: NSObject, NSFetchedResultsControllerDelegate {
    
    var fetchDelegateDidChangedCalled = false
    init(dm: MockDataManager) {
        NotificationCenter.default.addObserver(forName: Notification.Name.favoriteStateDidChange, object: nil, queue: OperationQueue.main, using: { _ in
            dm.saveInCoreDataForTest = true
            dm.saveDeliveryContext()
        })
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        fetchDelegateDidChangedCalled = true
    }
}
