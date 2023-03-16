//
//  InAppPurchaseView.swift
//  InAppPurchaseApp
//
//  Created by Mac on 16/03/2023.
//

import SwiftUI
import StoreKit


struct InAppPurchaseView: View {
    
    @StateObject var viewModel = ViewModel()
    
    
    
    var body: some View {
        VStack {
            Image(systemName: "applelogo")
                .resizable()
                .frame(width: 70, height: 70)
            
            Text("Apple Store")
                .bold()
                .font(.system(size: 32))
            
            Image("watch")
                .resizable()
                .aspectRatio(nil, contentMode: .fit)
                .frame(width: 250, height: 250)
            
            if let product = viewModel.products.first {
                Text(product.displayName.isEmpty ? "Name Here" : product.displayName)
                Text(product.description.isEmpty ? "Description here" : product.description)
               
                
                Button(action: {
                    if viewModel.purchasedIds.isEmpty {
                        viewModel.purchase()
                    }
            
                }) {
                    Text(viewModel.purchasedIds.isEmpty ? "Buy Now (\(product.displayPrice))" :"Purchased")
                        .bold()
                        .foregroundColor(Color.white)
                        .frame(width: 220, height: 50)
                        .background(viewModel.purchasedIds.isEmpty ? Color.blue : Color.green)
                        .cornerRadius(8)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
        }
        .onAppear {
            viewModel.fetchProducts()
        }
    }
}

struct InAppPurchaseView_Previews: PreviewProvider {
    static var previews: some View {
        InAppPurchaseView()
    }
}
