//
//  Store.swift
//  InAppPurchaseApp
//
//  Created by Mac on 16/03/2023.
//

import Foundation
import SwiftUI
import StoreKit

// Fetch products
// Purchase product
// Update Ui / Fetch product state

class ViewModel: ObservableObject {
    
    @Published var products : [Product] = []
    @Published var purchasedIds : [String] = []
    
    func fetchProducts(){
        Task {
            do {
                let products = try await Product.products(for: ["com.apple.watc"])
                self.products = products
                DispatchQueue.main.async {
                    self.products = products
                }
                if let product = products.first {
                    await isPurchased(product: product)

                }
                
            } catch {
                print(error)
            }
        }
    }
    
    func isPurchased(product: Product) async {

        
        guard  let state = await product.currentEntitlement else { return }
        print("Checking state")
        switch state {
        case .verified(let transaction):
            print("Verified")
            DispatchQueue.main.async {
                self.purchasedIds.append(transaction.productID)
            }
        case .unverified(_):
            print("UnVerified")
            break
        }
        
        
    }
    
    func purchase(){
        Task {
            guard let product = products.first else { return }
            do{
                let result  = try await product.purchase()
                switch result {
                    
                case .success(let verification):
                    switch verification {
                    case .verified(let transaction):
                        print(transaction.productID)
                        DispatchQueue.main.async {
                            self.purchasedIds.append(transaction.productID)
                        }
                    case .unverified(_):
                        break
                    }
                case .userCancelled:
                    break
                case .pending:
                    break
                @unknown default:
                    break
                }
                
            }catch{
                print(error)
            }
            
        }
    }
}
