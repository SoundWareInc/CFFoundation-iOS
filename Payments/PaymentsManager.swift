//
//  PaymentsManager.swift
//  CFFoundation
//
//  Created by Benjamin Breier on 3/14/20.
//

import Foundation
import StoreKit

public final class PaymentsManager: NSObject {
    public func purchaseProduct(_ product: SKProduct) {
        SKPaymentQueue.default().add(SKPayment(product: product))
    }

    public func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    let productIdentifiers: [String]
    let handlePurchased: (SKPaymentTransaction) -> Void
    let handleFailed: (SKPaymentTransaction) -> Void
    let handleRestored: (SKPaymentTransaction) -> Void
    public var availableProducts: [SKProduct]?

    var isAuthorizedForPayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }

    deinit {
        SKPaymentQueue.default().remove(self)
    }

    public init(
        productIdentifiers: [String],
        handlePurchased: @escaping (SKPaymentTransaction) -> Void,
        handleFailed: @escaping (SKPaymentTransaction) -> Void,
        handleRestored: @escaping (SKPaymentTransaction) -> Void) {
        self.productIdentifiers = productIdentifiers
        self.handlePurchased = handlePurchased
        self.handleFailed = handleFailed
        self.handleRestored = handleRestored
        super.init()
        SKPaymentQueue.default().add(self)
        fetchProducts()
    }

    private var productRequest: SKProductsRequest?

    func fetchProducts() {
        let identifierSet = Set(productIdentifiers)

        productRequest = SKProductsRequest(productIdentifiers: identifierSet)
        productRequest?.delegate = self

        productRequest?.start()
    }
}

extension PaymentsManager: SKProductsRequestDelegate {
    public func productsRequest(
        _ request: SKProductsRequest,
        didReceive response: SKProductsResponse) {
        if !response.products.isEmpty {
            availableProducts = response.products
        }
    }
}

extension PaymentsManager: SKPaymentTransactionObserver {
    /// Called when there are transactions in the payment queue.
    public func paymentQueue(
        _ queue: SKPaymentQueue,
        updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                break
            case .deferred:
                print("Payment deferred")
            case .purchased:
                let refresh = SKReceiptRefreshRequest(receiptProperties: nil)
                refresh.start()
                handlePurchased(transaction)

                queue.finishTransaction(transaction)
            case .failed:
                let refresh = SKReceiptRefreshRequest(receiptProperties: nil)
                refresh.start()
                handleFailed(transaction)

                queue.finishTransaction(transaction)
            case .restored:
                handleRestored(transaction)

                queue.finishTransaction(transaction)
            @unknown default:
                fatalError("Unknown transaction state encountered")
            }
        }
    }
}

extension SKProduct {
    /// - returns: The cost of the product formatted in the local currency.
    var regularPrice: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)
    }
}
