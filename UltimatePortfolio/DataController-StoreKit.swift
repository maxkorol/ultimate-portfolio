//
//  DataController-Storekit.swift
//  UltimatePortfolio
//
//  Created by Max Korol on 02/07/2025.
//

import Foundation
import StoreKit

extension DataController {
    static let unlockPremiumProductID = "software.colorful.UltimatePortfolio.premiumUnlock"

    func finalize(_ transaction: Transaction) async {
        if transaction.productID == Self.unlockPremiumProductID {
            fullVersionUnlocked = transaction.revocationDate == nil
            defaults.setValue(fullVersionUnlocked, forKey: "fullVersionUnlocked")
            await transaction.finish()
        }
    }

    func monitorTransactions() async {
        for await entitlement in Transaction.currentEntitlements {
            if case let .verified(transaction) = entitlement {
                await finalize(transaction)
            }
        }
        for await update in Transaction.updates {
            if let transaction = try? update.payloadValue {
                await finalize(transaction)
            }
        }
    }

    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        if case let .success(validation) = result {
            try await finalize(validation.payloadValue)
        }
    }
}
