//
//  DeliveryTableViewModel.swift
//  DeliverySample
//
//

import Foundation

class DeliveryViewModel: NSObject {
    @objc dynamic private(set) var isFetchingDeliveries = false
    @objc dynamic private(set) var shouldLoadResults = false
    private let apiClientManager: DeliveryNetworkManager
    private(set) var apiError: Error?
    
    init(apiClientManager: DeliveryNetworkManager) {
        self.apiClientManager = apiClientManager
    }
    
    func fetchDeliveriesFromNetworkManager(offset: Int, isLastPage: Bool) {
        if isFetchingDeliveries || isLastPage {
            return
        }
        isFetchingDeliveries = true
        apiClientManager.fetchDeliveriesFromServer(offset: offset, limit: Int(Constants.twenty)) { [weak self] (result) in
            self?.isFetchingDeliveries = false
                switch result {
                case .success(_) :
                    self?.shouldLoadResults = true
                case .failure(let error):
                    self?.apiError = error
                    self?.shouldLoadResults = true
                }
        }
    }

}

