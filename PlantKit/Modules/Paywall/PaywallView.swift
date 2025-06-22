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
    
    private let iconAnimationTimer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
        
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
                                        .font(.footnote)
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                .padding(.top, 10)
                            } else if selectedPackage == proManager.yearlyPackage {
                                HStack {
                                    Image(systemName: "checkmark.shield.fill")
                                        .foregroundColor(.green)
                                    Text("Cancel anytime. Secured with the App Store.")
                                        .font(.footnote)
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
                
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.gray.opacity(0.5))
                                .frame(width: 30, height: 30)
                        }
                        .padding(.trailing, 6)
                    }
                    Spacer()
                }
                .padding()
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
            }
            .onChange(of: proManager.hasPro) { hasPro in
                if hasPro {
                    showsAlert = true
                }
            }
            .alert("Habit Tracker - HabitPal Pro Unlocked".localized, isPresented: $showsAlert, actions: {
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
                .font(.title2).bold()
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
                            .font(.title2)
                            .foregroundColor(.green)
                            .frame(width: 30)
                        Text(feature.rawValue)
                            .font(.headline)
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
                .font(.headline)
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
                    .font(.headline).bold()
                if let subtext = subtext {
                    Text(subtext)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                } else {
                    Text(price)
                        .font(.subheadline)
                        .strikethrough(true, color: .white.opacity(0.5))
                }
            }
            
            Spacer()
            
            if let badge = badge {
                Text(badge.text)
                    .font(.caption).bold()
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(badge.color)
                    .cornerRadius(12)
            }
            
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.title2)
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
                            .font(.headline.bold())
                        
                        HStack(spacing: 8) {
                            Text("$260.19")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                                .strikethrough()
                            Text("\(proManager.yearlyPriceString) per year")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    
                    Spacer()
                    
                    Text("SAVE 90%")
                        .font(.caption).bold()
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.red)
                        .cornerRadius(12)
                    
                    Image(systemName: selectedPackage == proManager.yearlyPackage ? "circle.inset.filled" : "circle")
                        .font(.title2)
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
                .font(.footnote)
                .foregroundColor(.white.opacity(0.7))
                .underline()
        }
        .buttonStyle(.plain)
    }
    
    private var privacyButton: some View {
        Button {
            if let url = Config.app.privacyPolicyUrl {
                AppActionManager.shared.open(url: url)
            }
        } label: {
            Text("Privacy Policy")
                .font(.footnote)
                .foregroundColor(.white.opacity(0.7))
                .underline()
        }
        .buttonStyle(.plain)
    }
    
    private var eulaButton: some View {
        Button {
            if let url = Config.app.termsUrl {
                AppActionManager.shared.open(url: url)
            }
        } label: {
            Text("EULA")
                .font(.footnote)
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
}

#Preview {
    PaywallView()
}
