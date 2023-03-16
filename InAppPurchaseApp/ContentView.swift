import SwiftUI
import StoreKit

// MARK: StoreManager
class StoreManager: ObservableObject {
    @Published var allProducts = [SKProduct]()
    @Published var isPurchaseCompleted = false
    
    private let productIds = ["AnnualSubsription", "MonthlySubsription"]
    private var store = InAppPurchaseHandler.shared
    
    init() {
        fetchAllProducts()
    }
    
    func fetchAllProducts() {
        store.fetchAvailableProducts { [weak self] products in
            self?.allProducts = products
        }
    }
    
    func purchase(product: SKProduct) {
        store.purchase(product: product) { [weak self] (message, _, _) in
            self?.isPurchaseCompleted = message == InAppPurchaseMessages.purchased.rawValue
        }
    }
}

// MARK: ContentView
struct ContentView: View {
    @StateObject private var storeManager = StoreManager()
    
    var body: some View {
        NavigationView {
            List(storeManager.allProducts, id: \.productIdentifier) { product in
                VStack {
                    Text(product.localizedTitle ?? "No Title")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    
                    Text(product.localizedDescription ?? "No description available")
                        .padding()
                    
                    Text(getPriceFormatted(for: product) ?? "N/A" ?? "No description available")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding()
                        .onTapGesture {
                            storeManager.purchase(product: product)
                        }
                }
            }
            .navigationTitle("In-App Purchases")
        }
    }
}

// MARK: Helper functions
func getPriceFormatted(for product: SKProduct) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = product.priceLocale
    
    return formatter.string(from: product.price )!
}

// MARK: PreviewProvider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
