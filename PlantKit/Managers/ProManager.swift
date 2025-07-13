//
//  ProManager.swift
//  PlantKit
//
//  Created by Khuong Pham on 19/6/25.
//

import SwiftUI
import ReuseAcross
import RevenueCat

let appGroup = AppGroup(
    teamId: "SKNJUSC35K",
    bundleId: "app.plantkit.PlantKit"
)

final class ProManager: ObservableObject {
    static let shared = ProManager()
    
    @AppStorage("ProManager.PlantKit", store: appGroup.userDefaults)
    var hasPro = false
    
    @Published var showsUpgradeProView = false
    
    // RevenueCat
    @Published var packages: [RevenueCat.Package] = []
    @Published var isPurchasing = false
    @Published var isRestoring = false
    @Published var error: PublicError?
    @Published var purchaseError: PublicError?

    public func setup() {
        Purchases.logLevel = .error
        Purchases.configure(withAPIKey: "appl_bxrRMvhnPxCJPPdqvYjgdfwxQwy")
        checkExistingPurchase()
        fetchProducts()
    }
    
    private func fetchProducts() {
        Purchases.shared.getOfferings { (offerings, _) in
            DispatchQueue.main.async {
                guard let offerings else {
                    return
                }
                for (offeringIdentifider, offering) in offerings.all {
                    if offeringIdentifider == "default" {
                        self.packages = offering.availablePackages
                    }
                }
            }
        }
    }
    
    func showUpgradeProIfNeeded() {
        if !hasPro {
            showsUpgradeProView = true
        }
    }
    
    func showUpgradePro() {
        showsUpgradeProView = true
    }
    
    func purchase(package: RevenueCat.Package, completion: @escaping () -> Void) {
        isPurchasing = true
        
        Purchases.shared.purchase(package: package) { (transaction, purchaseInfo, error, userCancelled) in
            _ = transaction
            _ = userCancelled
            
            Task { @MainActor in
                self.isPurchasing = false
                self.purchaseError = error
                self.handle(purchaseInfo: purchaseInfo)
                completion()
            }
        }
    }
    
    func restorePurchase() {
        isRestoring = true
        
        Purchases.shared.restorePurchases { (purchaseInfo, error) in
            Task { @MainActor in
                self.isRestoring = false
                self.error = error
                self.handle(purchaseInfo: purchaseInfo)
            }
        }
    }
    
    private func checkExistingPurchase() {
        Purchases.shared.getCustomerInfo { (customerInfo, _) in
            Task { @MainActor in
                self.handle(purchaseInfo: customerInfo)
            }
        }
    }
    
    private func handle(purchaseInfo: RevenueCat.CustomerInfo?) {
        hasPro = purchaseInfo?.entitlements["Autorenew"]?.isActive == true
//#if DEBUG
//        hasPro = true
//        #endif
    }
}

extension ProManager {
    var weeklyPackage: RevenueCat.Package? {
        return packages.first(where: { $0.packageType == .weekly })
    }
    
    var yearlyPackage: RevenueCat.Package? {
        return packages.first(where: { $0.packageType == .annual })
    }
    
    var appUserID: String {
        return Purchases.shared.appUserID
    }
    
    var weeklyPriceString: String {
        if let package = weeklyPackage {
            return "\(package.localizedPriceString)"
        }
        return ""
    }
    
    var yearlyPriceString: String {
        if let package = yearlyPackage {
            return package.localizedPriceString
        }
        return ""
    }
    
    var calculatedWeeklyPriceFromYearlyPriceString: String {
        if let package = yearlyPackage {
            guard let pricePerWeek = package.storeProduct.localizedPricePerWeek else {
                return ""
            }
            
            return "\(pricePerWeek)/week"
        }
        return ""
    }
}
