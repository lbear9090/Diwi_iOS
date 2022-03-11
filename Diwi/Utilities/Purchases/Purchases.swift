//
//  Purchases.swift
//  Diwi
//
//  Created by David Tong on 1/21/22.
//  Copyright © 2022 Trim Agency. All rights reserved.
//

import UIKit
import StoreKit
import RxSwift


class Purchases: NSObject {

    static let `default` = Purchases()
    public let kUnnlockPremiumLooksIdentifier = "com.diwi.premium"
    public var hasFreePlan: Bool {
        get {
            return UserDefaults.standard.bool(
                forKey: "FREE_PLAN"
            )
        }
        set {
            UserDefaults.standard.set(
                newValue,
                forKey: "FREE_PLAN"
            )
            UserDefaults.standard.synchronize()
        }
    }

    public var hasProPlan: Bool {
        get {
            return UserDefaults.standard.bool(
                forKey: "PRO_PLAN"
            )
        }
        set {
            UserDefaults.standard.set(
                newValue,
                forKey: "PRO_PLAN"
            )
            UserDefaults.standard.synchronize()
        }
    }

    // MARK: - Internal Variable Declaration

    internal let disposeBag = DisposeBag()
    public lazy var tokenDidUpdate = {
        return BehaviorSubject<Bool>.init(value: false)
    }()

    /// Checking this device is able to make a payments or not
    /// NO if the device is not able or allowed make payments

    open class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }

    /// Sending a purchase product request to Storekit and processing payment
    /// - Parameters:
    /// productIdentifier : Product identifier for example com.viivio.premium.monthly

    public func purchaseProduct( _ productIdentifier : String) -> Observable<Bool> {
        return Observable.create({ (observer) -> Disposable in
            SwiftyStoreKit.purchaseProduct(productIdentifier, atomically: false) { (result) in
                self.handleTransaction(observer: observer, purchaseResult: result)
            }
            return Disposables.create()
        })
    }

    @available(iOS 12.2, *)
    public func purchaseDiscountProduct( _ productIdentifier : String, discount : SKPaymentDiscount, username: String) -> Observable<Bool> {
        return Observable.create({ (observer) -> Disposable in
            SwiftyStoreKit.purchaseProduct(productIdentifier, atomically: false, applicationUsername: username, discount: discount) { (result) in
                self.handleTransaction(observer: observer, purchaseResult: result)
            }
            return Disposables.create()
        })
    }

    internal func handleTransaction( observer : AnyObserver<Bool>, purchaseResult : PurchaseResult) {
        switch purchaseResult {
        case .success(let purchase):
            guard purchase.needsFinishTransaction, let _ = SwiftyStoreKit.localReceiptData else {
                observer.onError(SKError(.storeProductNotAvailable))
                observer.onCompleted()
                return
            }
            SwiftyStoreKit.finishTransaction(purchase.transaction)
            self.tokenDidUpdate.onNext(true)
            self.hasProPlan = true
            observer.onNext(true)
            observer.onCompleted()
        case .error(let error):
            debugPrint(error.localizedDescription)
            observer.onError(SKError(SKError.Code(rawValue: -1000)!))
            observer.onCompleted()
        }
    }

    /// Fetching product detail based on productIdentifier
    /// - Returns: The observable sequence with [SKProduct] for the `subscribe` method.

    public func fetchAllFeaturesProduct() -> Observable<[SKProduct]?> {
        return Observable.create({ (observer) -> Disposable in
            let productIdentifiers = Set(arrayLiteral: self.kUnnlockPremiumLooksIdentifier)
            SwiftyStoreKit.retrieveProductsInfo(productIdentifiers) { (results) in
                observer.onNext(Array(results.retrievedProducts))
                observer.onCompleted()
            }
            return Disposables.create()
        })
    }

    /// Restoring purchase you have already purchased before when you delete app or switch to new devices.
    /// - Parameters
    /// appUserId: Application user id

    public func restorePurchases() -> Observable<Bool> {
      return Observable.create({ (observer) -> Disposable in
        SwiftyStoreKit.restorePurchases(atomically: false) { (result) in
            guard result.restoredPurchases.count > 0 else {
                observer.onError(SKError(SKError.Code(rawValue: -1000)!))
                observer.onCompleted()
                return
            }
            var restored = false
            for purchase in result.restoredPurchases {
                if purchase.needsFinishTransaction && purchase.productId == self.kUnnlockPremiumLooksIdentifier {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                    restored = true
              }
            }

            if restored == true {
                self.tokenDidUpdate.onNext(true)
                self.hasProPlan = true
                observer.onNext(true)
            } else {
                observer.onError(SKError(SKError.Code(rawValue: -1000)!))
            }
            observer.onCompleted()
        }
        return Disposables.create()
      })
    }

    public func completeTransactions() -> Observable<Bool> {
        return Observable.create({ (observer) -> Disposable in
            SwiftyStoreKit.completeTransactions(atomically: false) { (purchases) in
                guard purchases.count > 0 else {
                    observer.onNext(false)
                    observer.onCompleted()
                    return
                }
                for purchase in purchases {
                    if purchase.productId == self.kUnnlockPremiumLooksIdentifier {
                        self.tokenDidUpdate.onNext(true)
                        observer.onNext(true)
                        self.hasProPlan = true
                        observer.onCompleted()
                        break
                    }
                }

            }
            return Disposables.create()
        })
    }

    
}
