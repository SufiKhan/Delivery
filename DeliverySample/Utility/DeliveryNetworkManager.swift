//
//  DeliveryNetworkManager.swift
//  DeliverySample

import Foundation
import UIKit
import CoreData

enum Result<T, U> {
    case success(T)
    case failure(U)
}

class DeliveryNetworkManager {

    private let session: URLSession
    private let apiConfig: ApiConfigProvider?
    
    init(session: URLSession, apiConfig: ApiConfigProvider?) {
        self.session = session
        self.apiConfig = apiConfig
    }
    
    func fetchDeliveriesFromServer(offset: Int, limit: Int, completionHandler: @escaping (Result<Bool, Error>)  -> Void) {
        guard let config = apiConfig else {
            return
        }
        guard let url = URL(string: "\(config.baseURL)\(config.path)?offset=\(offset)&limit=\(limit)") else {
            return
        }
        
        let task = session.dataTask(with: url, completionHandler: { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completionHandler(.failure(error))
                } else if let data = data {
                    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
                    if let _ = try? JSONDecoder(context: appDelegate.persistentContainer.viewContext).decode([Delivery].self, from: data) {
                        appDelegate.saveContext()
                        completionHandler(.success(true))
                    } else {
                        //The occurence of this error is often observed in this api call and data fetched is as not expected.
                        completionHandler(.failure(NSError(domain: "Internal Server Error! Please try Again", code: 500, userInfo: nil)))
                    }
                }
            }
            
        })
        task.resume()
    }
}

