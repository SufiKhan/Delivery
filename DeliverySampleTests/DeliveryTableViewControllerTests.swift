//
//  DeliverySampleTests.swift
//  DeliverySampleTests
//

import XCTest
@testable import DeliverySample
import CoreData

class DeliveryTableViewControllerTests: XCTestCase {

    var sut: DeliveryTableViewController?
    var mockDataManager = MockDataManager()
    
    override func setUp() {
        let apiClientManager = DeliveryNetworkManager.init(session: MockURLSession(), apiConfig: nil)
        sut = DeliveryTableViewController(dataManager: mockDataManager,apiClientManager: apiClientManager)
        let tableView = UITableView()
        sut?.tableView = tableView
    }

    override func tearDown() {
        sut = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testViewDidLoadAndObserving() {
        sut?.viewDidLoad()
        NotificationCenter.default.post(Notification(name: Notification.Name.favoriteStateDidChange))
        XCTAssertTrue(mockDataManager.saveDataCalled)
    }
    
    func testViewDidAppearNoUpdateRequiredForTableView() {
        sut?.contentUpdated = false
        sut?.viewDidAppear(false)
        XCTAssertNil(sut?.selectedIndexPath)
    }
    
    func testViewDidAppearUpdateRequiredForTableView() {
        sut?.contentUpdated = true
        sut?.selectedIndexPath = IndexPath(row: 0, section: 0)
        guard let dataSource: MockTableViewDatasource = sut?.tableView.dataSource as? MockTableViewDatasource else {return}
        sut?.tableView.dataSource = dataSource
        sut?.viewDidAppear(false)
        XCTAssertTrue(dataSource.cellForRowCalled)
        XCTAssertNil(sut?.selectedIndexPath)
    }
    
    func testErrorFetchFromNetworkButFetchFromLocalCache() {
        let context = mockDataManager.context
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Delivery", into: context) as! Delivery
        entity.name = "test"
        mockDataManager.saveInCoreDataForTest = true
        mockDataManager.saveDeliveryContext()
        guard let dataSource: MockTableViewDatasource = sut?.tableView.dataSource as? MockTableViewDatasource else {return}
        sut?.tableView.dataSource = dataSource
        let apiClientManager = DeliveryNetworkManager.init(session: MockURLSession(), apiConfig: ErrorApiProvider())
        sut = DeliveryTableViewController(dataManager: mockDataManager,apiClientManager: apiClientManager)

        var errorCode: Int?
        apiClientManager.fetchDeliveriesFromServer(offset: 0, limit: 20) { (res) in
            switch res {
            case .failure(let error as NSError):
                errorCode = error.code
            case .success(_):
                break
            }
        }
        let expectation = XCTestExpectation(description: "errorCallback")
        sut?.viewModel.fetchDeliveriesFromNetworkManager(offset: 0, isLastPage: false)
        _ = XCTWaiter.wait(for: [expectation], timeout: 0.1)
        XCTAssertEqual(errorCode, 400)
        XCTAssertTrue(dataSource.cellForRowCalled)
    }
    
    func testFetchFromNetworkSuccess() {
        let context = mockDataManager.context
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Delivery", into: context) as! Delivery
        entity.name = "test"
        mockDataManager.saveInCoreDataForTest = true
        mockDataManager.saveDeliveryContext()
        guard let dataSource: MockTableViewDatasource = sut?.tableView.dataSource as? MockTableViewDatasource else {return}
        sut?.tableView.dataSource = dataSource
        let apiClientManager = DeliveryNetworkManager.init(session: MockURLSession(), apiConfig: SuccessApiProvider())
        sut = DeliveryTableViewController(dataManager: mockDataManager,apiClientManager: apiClientManager)

        var didSucceed = false
        apiClientManager.fetchDeliveriesFromServer(offset: 0, limit: 20) { (res) in
            switch res {
            case .success(let success): didSucceed = success
            case .failure(_): break
            }
        }
        let expectation = XCTestExpectation(description: "successCallBack")
        sut?.viewModel.fetchDeliveriesFromNetworkManager(offset: 0, isLastPage: false)
        _ = XCTWaiter.wait(for: [expectation], timeout: 0.1)
        XCTAssertTrue(didSucceed)
        XCTAssertTrue(dataSource.cellForRowCalled)
    }
}
