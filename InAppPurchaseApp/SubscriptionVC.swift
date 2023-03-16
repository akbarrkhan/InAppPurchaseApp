import Foundation

import UIKit
import StoreKit
import RxRelay
import RxSwift



class SubscriptionVC: UIViewController {
    //MARK: Variables
    let bag = DisposeBag()
    var products = BehaviorRelay<[SKProduct]>(value: [])
    
    //MARK: Outlets
    @IBOutlet weak var annualPriceLabel: UILabel!
    @IBOutlet weak var monthlyPriceLabel: UILabel!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addObservers()
        fetchProducts()
    }
    
    // MARK: IBActions
    @IBAction func didTapOnPurchaseAnnually(_ sender: Any) {
        purchase(product: .Annual)
    }
    
    @IBAction func didTapOnPurchaseMonthly(_ sender: Any) {
        purchase(product: .Monthly)
    }
}

// MARK: Private methods
extension SubscriptionVC {
    private func addObservers() {
        products
            .asObservable()
            .subscribe{ _ in
                let products = self.products.value
                guard let monthly = products
                    .first(where: {$0.productIdentifier == PurchaseProduct.Monthly.rawValue}),
                      let annually = products
                    .first(where: {$0.productIdentifier == PurchaseProduct.Annual.rawValue})
                else { return }
                
                DispatchQueue.main.async {
                    let currency = monthly.priceLocale.currency?.identifier ?? ""
                    
                    let monthlyPrice = monthly.price.decimalValue
                    self.monthlyPriceLabel.text = "\(currency) \(monthlyPrice)/ month"
                    
                    let annualPrice = annually.price.decimalValue
                    self.annualPriceLabel.text = "\(currency) \(annualPrice)/ year"
                }
            }.disposed(by: bag)
    }
}

extension SubscriptionVC {
    private func startLoading() {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .gray
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

extension SubscriptionVC {
    private func stopLoading() {
        if let activityIndicator = view.subviews.first(where: { $0 is UIActivityIndicatorView }) as? UIActivityIndicatorView {
            activityIndicator.removeFromSuperview()
        }
    }
}


// MARK: In app purchase methods
extension SubscriptionVC {
    private func fetchProducts() {
        startLoading()
        
        InAppPurchaseHandler.shared.fetchAvailableProducts { (products) in
            self.stopLoading()
            self.products.accept(products)
        }
    }
    
    private func purchase(product: PurchaseProduct) {
        guard let _product = products.value.first(where: {$0.productIdentifier == product.rawValue}) else {
            print("Product: \(product.rawValue) not found in Products Set")
            return
        }
        
        startLoading()
        
        InAppPurchaseHandler.shared.purchase(product: _product) { (message, product, transaction) in
            self.stopLoading()
            
            if let transaction = transaction, let product = product {
                print("Transaction : \(transaction)")
                print("Product: \(product.productIdentifier)")
                
                if transaction.error == nil {
                    if transaction.transactionState == .purchased {
                        let alertController = UIAlertController(title: "Success", message: message, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
                            self.dismiss(animated: true) {
                                // go to next page
                            }
                        }
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    } else if transaction.transactionState == .failed {
                        let alertController = UIAlertController(title: "Declined", message: message, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
                            self.dismiss(animated: true, completion: nil)
                        }
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                        
                    } else {
                        let alertController = UIAlertController(title: "Declined", message: transaction.error?.localizedDescription ?? message, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok", style: .default) { _ in
                            self.dismiss(animated: true, completion: nil)
                        }
                        alertController.addAction(okAction)
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
}
    
    
