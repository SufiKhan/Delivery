//
//  Mock.swift

import UIKit
import CoreData
@testable import DeliverySample

final class MockDataManager: DeliveryDataManagerProtocol {
    
    var context: NSManagedObjectContext {
        let ctx = self.persistentContainer.viewContext
        return ctx
    }
    var saveDataCalled = false
    var saveInCoreDataForTest = false
    
    func saveDeliveryContext() {
        saveDataCalled = true
        if saveInCoreDataForTest {
            saveContext()
            saveInCoreDataForTest = false
        }
    }

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "DeliverySample")
        let desc = container.persistentStoreDescriptions.first
        desc?.type = NSInMemoryStoreType
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext () {
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

final class MockTableViewDatasource: NSObject, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    var cellForRowCalled = false
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cellForRowCalled = true
        return UITableViewCell()
    }
}

final class ErrorApiProvider: ApiConfigProvider {
   
    var baseURL: String {
        return "error"
    }
    
    var path: String {
        return "/path"
    }
}

final class SuccessApiProvider: ApiConfigProvider {
   
    var baseURL: String {
        return "success"
    }
    
    var path: String {
        return "/path"
    }
}


final class MockURLSession: URLSession {
   
    override init() {}
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        if url == URL(string: "error/path?offset=0&limit=20") {
            let error = NSError(domain: "HTTP ERROR", code: 400, userInfo: nil)
            print(error.code)
            completionHandler(nil, nil, error)
        } else if url == URL(string: "success/path?offset=0&limit=20") {
            completionHandler(Data(), nil, nil)
        }
        return URLSession.shared.dataTask(with: url)
    }
}

final class MockUINavigationController: UINavigationController {

    var mockPresentViewCalled = false
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        mockPresentViewCalled = true
    }
}

