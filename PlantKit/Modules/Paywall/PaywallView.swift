//
//  PaywallView.swift
//  PlantKit
//
//  Created by Khuong Pham on 19/6/25.
//

import SwiftUI
import ReuseAcross
import RevenueCat
import Firebase
import UserNotifications
import SFSafeSymbols

enum ProFeature: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    
    case unlimitedPlants = "Identify unlimited plants"
    case chatAssistance = "Free chat with botanist"
    case growthTips = "Growth & propagation tips"
    case diseaseDetection = "Plant disease detection"
    case toxicityInfo = "Toxicity info for kids & pets"
    case removeAnnoyingPaywalls = "Remove annoying paywalls"
    
    var icon: String {
        switch self {
        case .unlimitedPlants:
            return SFSymbol.leaf.rawValue
        case .chatAssistance:
            return SFSymbol.message.rawValue
        case .growthTips:
            return SFSymbol.arrowClockwise.rawValue
        case .diseaseDetection:
            return SFSymbol.pills.rawValue
        case .toxicityInfo:
            return SFSymbol.pawprint.rawValue
        case .removeAnnoyingPaywalls:
            return SFSymbol.lockIphone.rawValue
        }
    }
}

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var proManager: ProManager = .shared
    
    @State private var selectedPackage: RevenueCat.Package?
    @State private var showsAlert = false
    @State private var isTrialEnabled = true
    @State private var isAnimatingIcon = false
    @State private var isPurchasing = false
    @State private var showCloseButton = false
    @State private var progressValue: Double = 0.0
    
    private let iconAnimationTimer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    private let closeButtonDelay: TimeInterval = 8.0
        
    private let features = ProFeature.allCases
    
    var body: some View {
        ZStack {
            ZStack {
                VStack(spacing: 0) {
                    content
                    
                    VStack(spacing: 4) {
                        if let selectedPackage {
                            if selectedPackage == proManager.weeklyPackage {
                                HStack {
                                    Image(systemName: "checkmark.shield.fill")
                                        .foregroundColor(.green)
                                    Text("No payment now")
                                        .font(.system(size: 13))
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                .padding(.top, 10)
                            } else if selectedPackage == proManager.yearlyPackage {
                                HStack {
                                    Image(systemName: "checkmark.shield.fill")
                                        .foregroundColor(.green)
                                    Text("Cancel anytime. Secured with the App Store.")
                                        .font(.system(size: 13))
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                .padding(.top, 10)
                            }
                        }
                        upgradeButton
                    }
                    .padding(.bottom, 8)
                    
                    HStack {
                        privacyButton
                        eulaButton
                        Spacer()
                        restoreButton
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                
                closeButton
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                ZStack {
                    Image("bg-paywall")
                        .resizable()
                        .scaledToFill()
                        .blur(radius: 4)
                    Color.black.opacity(0.8)
                }
                .ignoresSafeArea()
            )
            .preferredColorScheme(.dark)
            .onAppear {
                selectedPackage = proManager.weeklyPackage
                startCloseButtonTimer()
            }
            .onChange(of: proManager.hasPro) { newValue in
                if newValue {
                    showsAlert = true
                }
            }
            .onChange(of: proManager.weeklyPackage) { newValue in
                if let newValue {
                    selectedPackage = newValue
                }
            }
            .alert("PlantKit Pro Unlocked".localized, isPresented: $showsAlert, actions: {
                Button("Let's go") {
                    dismiss()
                }
            }, message: {
                Text("Unlimited access to all features".localized)
            })
            .disabled(isPurchasing)
            
            if isPurchasing {
                Color.black.opacity(0.5).ignoresSafeArea()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
    }
    
    private var content: some View {
        VStack(spacing: 20) {
            headerView
            featuresView
                .frame(height: 240)
            plansView
        }
        .padding()
    }
    
    private var closeButton: some View {
        Group {
            VStack {
                HStack {
                    Spacer()
                    if showCloseButton || proManager.hasPro {
                        Button(action: {
                            Haptics.shared.play()
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.gray.opacity(0.5))
                                .frame(width: 30, height: 30)
                        }
                    } else {
                        // Circular progress view
                        CircularProgressView(progress: progressValue)
                    }
                }
                .padding(.trailing, 6)
                Spacer()
            }
            .padding()
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 80, height: 80)
                Image(systemName: "viewfinder")
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(.green)
                Image(systemName: "leaf.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.green)
            }
            .rotationEffect(.degrees(isAnimatingIcon ? 5 : 0))
            .onReceive(iconAnimationTimer) { _ in
                withAnimation(.spring(response: 0.4, dampingFraction: 0.2)) {
                    isAnimatingIcon = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.2)) {
                        isAnimatingIcon = false
                    }
                }
            }
            
            Text("Identify Plants in Seconds")
                .font(.system(size: 22)).bold()
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    private var featuresView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(features) { feature in
                    HStack(spacing: 16) {
                        Image(systemName: feature.icon)
                            .font(.system(size: 30))
                            .foregroundColor(.green)
                        Text(feature.rawValue)
                            .font(.system(size: 17))
                            .foregroundStyle(Color.white.opacity(0.9))
                    }
                }
            }
        }
        .scrollIndicators(.hidden)
    }
    
    private var plansView: some View {
        VStack(spacing: 12) {
            if proManager.packages.isEmpty {
                plansShimmerView
            } else {
                yearlyPlanView
                weeklyPlanView
                freeTrialToggleView
            }
        }
    }
    
    private var freeTrialToggleView: some View {
        HStack {
            Text("Free Trial Enabled")
                .font(.system(size: 17)).bold()
            Spacer()
            Toggle("", isOn: $isTrialEnabled)
                .labelsHidden()
                .tint(.green)
                .onChange(of: isTrialEnabled) { newValue in
                    withAnimation {
                        if newValue {
                            selectedPackage = proManager.weeklyPackage
                        } else {
                            selectedPackage = proManager.yearlyPackage
                        }
                    }
                }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private var plansShimmerView: some View {
        VStack(spacing: 12) {
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 80)
                .cornerRadius(16)
                .shimmer(isActive: true)
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 80)
                .cornerRadius(16)
                .shimmer(isActive: true)
        }
    }
    
    private func planView(title: String, price: String, subtext: String? = nil, badge: (text: String, color: Color)? = nil, isSelected: Bool) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.system(size: 17)).bold()
                if let subtext = subtext {
                    Text(subtext)
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.8))
                } else {
                    Text(price)
                        .font(.system(size: 15))
                        .strikethrough(true, color: .white.opacity(0.5))
                }
            }
            
            Spacer()
            
            if let badge = badge {
                Text(badge.text)
                    .font(.system(size: 12)).bold()
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(badge.color)
                    .cornerRadius(12)
            }
            
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 22))
                .foregroundColor(isSelected ? .green : .gray)
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? .green : Color.gray.opacity(0.3), lineWidth: 2)
        )
    }
    
    private var weeklyPlanView: some View {
        Button(action: {
            if let packageToPurchase = proManager.weeklyPackage {
                isPurchasing = true
                Haptics.shared.play()
                withAnimation {
                    selectedPackage = packageToPurchase
                    isTrialEnabled = true
                }
                proManager.purchase(package: packageToPurchase) {
                    isPurchasing = false
                }
            }
        }) {
            planView(
                title: "Weekly Plan",
                price: "",
                subtext: "then \(proManager.weeklyPriceString) per week",
                badge: (text: "3-Day FREE", color: .green),
                isSelected: selectedPackage == proManager.weeklyPackage
            )
        }
        .buttonStyle(.plain)
    }
    
    private var yearlyPlanView: some View {
        VStack(spacing: 4) {
            Button(action: {
                if let packageToPurchase = proManager.yearlyPackage {
                    isPurchasing = true
                    Haptics.shared.play()
                    withAnimation {
                        selectedPackage = packageToPurchase
                        isTrialEnabled = false
                    }
                    proManager.purchase(package: packageToPurchase) {
                        isPurchasing = false
                    }
                }
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Yearly Plan")
                            .font(.system(size: 17)).bold()
                        
                        HStack(spacing: 8) {
                            Text("$260.19")
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.6))
                                .strikethrough()
                            Text("\(proManager.yearlyPriceString) per year")
                                .font(.system(size: 15))
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    
                    Spacer()
                    
                    Text("SAVE 90%")
                        .font(.system(size: 12)).bold()
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.red)
                        .cornerRadius(12)
                    
                    Image(systemName: selectedPackage == proManager.yearlyPackage ? "circle.inset.filled" : "circle")
                        .font(.system(size: 22))
                        .foregroundColor(selectedPackage == proManager.yearlyPackage ? .green : .gray)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(selectedPackage == proManager.yearlyPackage ? .green : Color.gray.opacity(0.3), lineWidth: 2)
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    private var restoreButton: some View {
        Button {
            Haptics.shared.play()
            proManager.restorePurchase()
        } label: {
            Text("Restore purchases")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
                .underline()
        }
        .buttonStyle(.plain)
    }
    
    private var privacyButton: some View {
        Button {
            Haptics.shared.play()
            openPrivacyPolicy()
        } label: {
            Text("Privacy Policy")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
                .underline()
        }
        .buttonStyle(.plain)
    }
    
    private var eulaButton: some View {
        Button {
            Haptics.shared.play()
            openTermsOfService()
        } label: {
            Text("Terms of Use")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.7))
                .underline()
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var upgradeButton: some View {
        let title = (selectedPackage == proManager.weeklyPackage && isTrialEnabled) ? "Try for Free ($0)" : "Continue"
        ShinyBorderButton(systemName: "sparkles", title: title) {
            guard let selectedPackage else {
                return
            }
            isPurchasing = true
            Haptics.shared.play()
            proManager.purchase(package: selectedPackage) {
                isPurchasing = false
            }
        }
        .shadow(color: Color.green.opacity(0.8), radius: 8, x: 0, y: 0)
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }
    
    private func openPrivacyPolicy() {
        if let url = URL(string: "https://www.plantkit.app/privacy") {
            UIApplication.shared.open(url)
        }
    }
    
    private func openTermsOfService() {
        if let url = URL(string: "https://www.plantkit.app/terms") {
            UIApplication.shared.open(url)
        }
    }
    
    private func startCloseButtonTimer() {
        // Reset states
        showCloseButton = false
        progressValue = 0.0
        
        // Animate progress from 0 to 1 over 8 seconds
        withAnimation(.linear(duration: closeButtonDelay)) {
            progressValue = 1.0
        }
        
        // Show close button after 8 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + closeButtonDelay) {
            withAnimation(.easeInOut(duration: 0.3)) {
                showCloseButton = true
            }
        }
    }
}

// MARK: - Circular Progress View

struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 4)
                .frame(width: 24, height: 24)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.gray.opacity(0.5), style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 24, height: 24)
                .rotationEffect(.degrees(-90))
        }
    }
}

#Preview {
    PaywallView()
}
