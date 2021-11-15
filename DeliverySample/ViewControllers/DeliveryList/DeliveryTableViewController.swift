//
//  ViewController.swift
//  DeliverySample
//

import UIKit
import CoreData

class DeliveryTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
   
    // MARK: DECLARATION
    private var fetchedResultsController: NSFetchedResultsController<Delivery>?
    private lazy var request: NSFetchRequest<Delivery> = {
        let req: NSFetchRequest<Delivery> = Delivery.fetchRequest()
        req.returnsObjectsAsFaults = false
        req.fetchLimit = Int(Constants.twenty)
        return req
    }()
    private var currentOffset: Int = Constants.zero
    private var isLastPage: Bool = false
    private var contentUpdated = false
    private(set) var arrayDelivery = [Delivery]()
    
    private var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .gray)
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicatorView
    }()
    
    private var retry = Constants.zero
    
    private lazy var indicatorBgView: UIView = {
        let view = UIView()
       return view
    }()
    
    private var selectedIndexPath: IndexPath?
    private var observerForFavoriteDelivery: NSObjectProtocol?
    private var observerForFetchStatus: NSKeyValueObservation?
    private var observerForResults: NSKeyValueObservation?
    private let dataManager: DeliveryDataManagerProtocol
    @objc var viewModel: DeliveryViewModel
    
    // MARK: END OF DECLARATION
    
    init(dataManager: DeliveryDataManagerProtocol, apiClientManager: DeliveryNetworkManager) {
        self.dataManager = dataManager
        viewModel = DeliveryViewModel(apiClientManager: apiClientManager)
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        configureObservers()
        //Configure observe before calling any action on viewmodel
        viewModel.fetchDeliveriesFromNetworkManager(offset: currentOffset, isLastPage: isLastPage)
    }
    
    private func configureObservers() {
        observerForFavoriteDelivery = NotificationCenter.default.addObserver(forName: Notification.Name.favoriteStateDidChange, object: nil, queue: OperationQueue.main, using: { _ in
            self.dataManager.saveDeliveryContext()
        })
        observerForFetchStatus = observe(\.viewModel.isFetchingDeliveries, changeHandler: { object, change in
            self.updateFetchStatus(isFetching: object.viewModel.isFetchingDeliveries)
        })
        
        observerForResults = observe(\.viewModel.shouldLoadResults, changeHandler: { object, change in
            self.loadResultsFromDBinTableView()
        })

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !contentUpdated {
            selectedIndexPath = nil
            return
        }
        guard let indexPath = selectedIndexPath else { return }
        tableView.reloadRows(at: [indexPath], with: .none)
        selectedIndexPath = nil
    }
    
    private func setUpView() {
        view.backgroundColor = .white
        self.title = Constants.header
        indicatorBgView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 50)
        indicatorBgView.addSubview(activityIndicatorView)
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: indicatorBgView.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: indicatorBgView.centerYAnchor)
        ])
        tableView.register(DeliveryTableViewCell.self, forCellReuseIdentifier: DeliveryTableViewCell.CellIdentifier)
        tableView.showsVerticalScrollIndicator = false
    }
    
    private func showAlert(error : NSError?) {
        if retry > Constants.zero {
            return
        }
        var message = Constants.generalError
        if let msg = error?.localizedDescription {
            message = msg
        }
        let alertController = UIAlertController(title: Constants.strAlert, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: Constants.strOk, style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: Constants.strRetry, style: .default, handler: { _ in
            self.retry += Constants.one
            self.viewModel.fetchDeliveriesFromNetworkManager(offset: self.currentOffset, isLastPage: self.isLastPage)
        }))
        navigationController?.present(alertController, animated: true, completion: nil)
    }
    
    deinit {
        if let observer = observerForFavoriteDelivery {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}

// MARK: UITABLEVIEW METHODS
extension DeliveryTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayDelivery.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DeliveryTableViewCell.CellIdentifier, for: indexPath) as? DeliveryTableViewCell else {
            return UITableViewCell()
        }
        
        cell.viewModel = DeliveryTableCellViewModel(arrayDelivery[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.rowHeight
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == arrayDelivery.count - 1 {
            if !viewModel.isFetchingDeliveries {
                viewModel.fetchDeliveriesFromNetworkManager(offset: currentOffset, isLastPage: isLastPage)

            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVc = DeliveryDetailViewController(viewModel: DeliveryTableCellViewModel(arrayDelivery[indexPath.row]))
        selectedIndexPath = indexPath
        self.navigationController?.pushViewController(detailVc, animated: true)
    }
}

extension DeliveryTableViewController {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        contentUpdated = true
        guard let index = selectedIndexPath?.row else {
            return
        }
        if anObject is Delivery {
            arrayDelivery[index] = anObject as! Delivery
        }
    }
}

extension DeliveryTableViewController {

    func updateFetchStatus(isFetching: Bool) {
        if isFetching {
            tableView.tableFooterView = indicatorBgView
            activityIndicatorView.startAnimating()
            activityIndicatorView.isHidden = false
        } else {
            DispatchQueue.main.async {
                self.tableView.tableFooterView = UIView(frame: .zero)
                self.activityIndicatorView.stopAnimating()
            }
        }
    }

    func loadResultsFromDBinTableView() {
        if isLastPage { return }
        request.fetchOffset = currentOffset
        do {
            if fetchedResultsController == nil {
                let sort = NSSortDescriptor(key: "dateCreated", ascending: true)
                request.sortDescriptors = [sort]
                fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: dataManager.context, sectionNameKeyPath: nil, cacheName: nil)
                fetchedResultsController?.delegate = self
            }
            try fetchedResultsController?.performFetch()
            let fetchedObjects = try dataManager.context.fetch(request)
            if !fetchedObjects.isEmpty {
                arrayDelivery.append(contentsOf: fetchedObjects)
                tableView.reloadData()
            }
            if fetchedObjects.count == Constants.zero && viewModel.apiError != nil {
                self.showAlert(error: viewModel.apiError as NSError?)
                return
            } else {
                // update the offset for next page fetch
                self.currentOffset += fetchedObjects.count
                self.isLastPage = fetchedObjects.count == Constants.zero
            }
        } catch {}
    }
}
