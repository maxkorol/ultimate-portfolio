//
//  StoreView.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 02/07/2025.
//

import SwiftUI
import StoreKit

struct StoreView: View {
    @Environment(DataController.self) var dataController
    @State private var products = [Product]()
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            if let product = products.first {
                VStack(alignment: .leading) {
                    Text(product.displayName)
                    Text(product.description)
                    Text(product.displayPrice)
                    Button("Buy Now") {
                        purchase(product)
                    }
                }
            }
        }
        .task {
            await load()
        }
        .onChange(of: dataController.fullVersionUnlocked) {
            checkForPurchase()
        }
    }

    func checkForPurchase() {
        if dataController.fullVersionUnlocked {
            dismiss()
        }
    }

    func purchase(_ product: Product) {
        Task {
            try await dataController.purchase(product)
        }
    }

    func load() async {
        products = (try? await Product.products(for: [DataController.unlockPremiumProductID])) ?? []
    }
}
