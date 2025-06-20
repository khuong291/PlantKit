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
    
    case unlimitedHabits = "Unlimited Habits"
    case interactiveWidgets = "Interactive Widgets"
    case editHabitHistory = "Edit Habit History"
    case appleHealth = "Apple Health"
    case supportSmallTeam = "Support Indie Developers"
    
    var subTitle: String {
        switch self {
        case .unlimitedHabits:
            return "Create and track as many habits as you want, and see how your life improve."
        case .interactiveWidgets:
            return "Track your habits directly on your home screen with interactive widgets."
        case .editHabitHistory:
            return "Easy to track your habits for the previous days on the calendar in case you forgot."
        case .appleHealth:
            return "Track your health data automatically from Apple Health."
        case .supportSmallTeam:
            return "Your purchase mean a lot to us, it supports our small team to keep improving the app."
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .unlimitedHabits:
            return .systemGreen
        case .interactiveWidgets:
            return .systemPurple
        case .editHabitHistory:
            return .systemOrange
        case .appleHealth:
            return .appPrimaryColor
        case .supportSmallTeam:
            return .cyan
        }
    }
    
    var icon: SFSymbol {
        switch self {
        case .unlimitedHabits:
            return .figureRun
        case .interactiveWidgets:
            return .rectangleSplit2x2
        case .editHabitHistory:
            return .calendar
        case .appleHealth:
            return .heartFill
        case .supportSmallTeam:
            return .starFill
        }
    }
}

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var proManager: ProManager = .shared
    
    @State private var selectedPackage: RevenueCat.Package?
    @State private var showsAlert = false
    @State private var shine = false
    @State private var isShimmering = true
    private let timer = Timer.publish(every: 5.0, on: .main, in: .common).autoconnect()
        
    private let features = ProFeature.allCases
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.black, Color(hex: "8B5DFF"), Color.black]), startPoint: .top, endPoint: .bottom)
            VStack(spacing: 0) {
                content
                if !proManager.hasPro {
                    VStack(spacing: 4) {
                        Text("Cancel Anytime. 24/7 support.".localized)
                            .font(.footnote)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.top, 10)
                        upgradeButton
                    }
                    .cornerRadius(12, corners: [.topLeft, .topRight])
                }
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                shine.toggle()
            }
        }
        .onChange(of: proManager.hasPro) { hasPro in
            if hasPro {
                showsAlert = true
            }
        }
        .alert("Habit Tracker - HabitPal Pro Unlocked".localized, isPresented: $showsAlert, actions: {
            Button("Let's go") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    if let selectedPackage {
                        let db = Firestore.firestore()
                        let referralQuery = db.collection("referrals")
                            .whereField("purchaseId", isEqualTo: Purchases.shared.appUserID)

                        referralQuery.getDocuments { snapshot, error in
                            if let documents = snapshot?.documents, let doc = documents.first {
                                doc.reference.updateData([
                                    "purchasePlan": selectedPackage.storeProduct.productIdentifier
                                ]) { error in
                                    if let error = error {
                                        print("Failed to update purchasePlan: \(error.localizedDescription)")
                                    } else {
                                        print("purchasePlan updated successfully")
                                    }
                                }
                            } else {
                                print("No referral document found for this purchaseId")
                            }
                        }
                    }
                    PopupManager.shared.showAskForRatingAlert = true
                    let content = UNMutableNotificationContent()
                    content.title = "Small steps lead to big changes."
                    content.subtitle = "Consistency is the key to success. Open the app, track your progress and achieve your goals!"
                    content.sound = UNNotificationSound.default
                    
                    // show this notification five seconds from now
                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 86400 * 2, repeats: false)
                    
                    // choose a random identifier
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    
                    // add our notification request
                    UNUserNotificationCenter.current().add(request)
                }
                dismiss()
            }
        }, message: {
            Text("Unlimited access to all features".localized)
        })
    }
    
    private var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack {
                    Button("Restore".localized) {
                        Haptics.shared.play()
                        proManager.restorePurchase()
                    }
                    .foregroundColor(.white.opacity(0.7))
                    .font(.subheadline)
                    Spacer()
                }
                
                Spacer().frame(height: 12)
                
                Text("Build better habits and transform your life with HabitPal".localized)
                    .font(.title3)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .padding(.top)

                Text(proManager.hasPro ? "Thanks for your purchase! We hope you enjoy the app.".localized : "Unlock HabitPal Premium: unlimited habits, interactive widgets, history editing, Health sync & more.".localized)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, 4)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, 4)

                Spacer().frame(height: 18)
                
                visualImagesView
                
                Spacer().frame(height: 18)
                
                if !proManager.hasPro {
                    if !proManager.packages.isEmpty {
                        plansView
                    } else {
                        plansShimmerView
                    }
                }
                
                Spacer().frame(height: 40)
                
                Image("img-chart")
                    .resizable()
                    .aspectRatio(1536/1024, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(12)
                
                Spacer().frame(height: 18)
                
                trustedUsersView
                
                Spacer().frame(height: 40)
                
                testimonialsView
                
                Spacer().frame(height: 18)
                
                Spacer().frame(height: 8)
                
                HStack(spacing: 16) {
                    termsButton
                    privacyButton
                }
                .padding(.top, 2)
                
                Spacer().frame(height: 18)
            }
            .padding()
        }
        .scrollIndicators(.hidden)
    }
    
    private var visualImagesView: some View {
        // Screenshots
        HStack(alignment: .bottom, spacing: 0) {
            ForEach([3, 2, 1], id: \.self) { idx in
                Image("screenshot\(idx)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: idx == 2 ? 128 : 118, height: idx == 2 ? 250 : 230)
                    .rotation3DEffect(
                        .degrees(idx == 3 ? 10 : idx == 1 ? -10 : 0),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .offset(x: idx == 3 ? 25 : idx == 1 ? -25 : 0) // Adjust based on visual position
                    .zIndex(idx == 2 ? 1 : 0) // Center image on top
            }
        }
    }
    
    private var plansView: some View {
        VStack {
            HStack(spacing: 12) {
                weeklyPlanView
                yearlyPlanView
            }
        }
    }
    
    private var plansShimmerView: some View {
        VStack {
            HStack(spacing: 12) {
                shimmerPlanView
                shimmerPlanView
            }
            shimmerLifetimePlanView
        }
    }
    
    private var shimmerPlanView: some View {
        VStack(spacing: 4) {
            VStack(spacing: 2) {
                Text("")
                    .font(.caption2)
                    .fontWeight(.semibold)
                Text("")
                    .font(.headline)
            }
            .frame(width: 140, height: 70)
            .background(Color.white.opacity(0.15))
            .cornerRadius(12)
            .shimmer(isActive: true)
            Text("")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .padding(.top, 2)
        }
    }
    
    private var shimmerLifetimePlanView: some View {
        VStack(spacing: 4) {
            VStack(spacing: 2) {
                Text("")
                    .font(.caption2)
                    .fontWeight(.semibold)
                Text("")
                    .font(.headline)
            }
            .frame(width: 292, height: 70)
            .background(Color.white.opacity(0.15))
            .cornerRadius(12)
            .shimmer(isActive: true)
            Text("")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .padding(.top, 2)
        }
    }
    
    private var weeklyPlanView: some View {
        // Monthly Plan
        VStack(spacing: 4) {
            Button(action: {
                Haptics.shared.play()
                withAnimation(.linear(duration: 0.2)) { selectedPackage = proManager.weeklyPackage }}) {
                VStack(spacing: 2) {
                    Text("WEEKLY".localized)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(selectedPackage == proManager.weeklyPackage ? .black : .white)
                    Text("\(proManager.weeklyPriceString)/week")
                        .font(.headline)
                        .foregroundColor(selectedPackage == proManager.weeklyPackage ? .black : .white)
                }
                .frame(width: 140, height: 70)
                .background(selectedPackage == proManager.weeklyPackage ? Color.white : Color.white.opacity(0.15))
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
            Text("3 days free trial".localized)
                .font(.caption)
                .foregroundColor(selectedPackage == proManager.weeklyPackage ? .white : .white.opacity(0.7))                .padding(.top, 2)
        }
    }
    
    private var yearlyPlanView: some View {
        // Yearly Plan
        VStack(spacing: 4) {
            ZStack(alignment: .top) {
                Button(action: {
                    Haptics.shared.play()
                    withAnimation(.linear(duration: 0.2)) { selectedPackage = proManager.yearlyPackage }}) {
                    VStack(spacing: 2) {
                        Spacer().frame(height: 6) // Space for badge
                        Text("YEARLY".localized)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(selectedPackage == proManager.yearlyPackage ? .black : .white)
                        Text("\(proManager.yearlyPriceString)/yr")
                            .font(.headline)
                            .foregroundColor(selectedPackage == proManager.yearlyPackage ? .black : .white)
                    }
                    .frame(width: 140, height: 70)
                    .background(selectedPackage == proManager.yearlyPackage ? Color.white : Color.white.opacity(0.15))
                    .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                
                if selectedPackage == proManager.yearlyPackage {
                    HStack(spacing: 4) {
                        Image("ic-offer")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 13, height: 13)
                        Text("SAVE 90%".localized)
                            .font(.caption2)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(Color.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white, lineWidth: 1)
                    )
                    .cornerRadius(10)
                    .offset(y: -8)
                    .zIndex(1)
                }
            }
            Text(proManager.calculatedWeeklyPriceFromYearlyPriceString)
                .font(.caption)
                .foregroundColor(selectedPackage == proManager.yearlyPackage ? .white : .white.opacity(0.7))
                .padding(.top, 2)
        }
        .onAppear {
            selectedPackage = proManager.yearlyPackage
        }
    }
    
    private var trustedUsersView: some View {
        HStack(spacing: 0) {
            Image("ic-laurel-leading")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 120)
                .foregroundColor(.yellow)
            VStack(spacing: 6) {
                Text("Trusted by 200k+ users".localized)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                HStack(spacing: 6) {
                    Text("4.8")
                        .fontWeight(.black)
                        .foregroundColor(.yellow)
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { starIndex in
                            Image("ic-star")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                        }
                    }
                }
            }
            Image("ic-laurel-trailing")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 120)
                .foregroundColor(.yellow)
        }
    }
    
    private var testimonialsView: some View {
        VStack(spacing: 40) {
            TestimonialPage(name: "@Thomas", text: "Downloaded this app yesterday and already loving it! The user interface is simple and easy to navigate. Honestly, it took no time to setup. A lot of the habits that I set up would be easier to measure by allowing me to enter a target quantity for a specific daily, weekly or monthly habit and then entering the quantity accomplished as I go.", index: 0)
            TestimonialPage(name: "@Alice", text: "I've tried a majority of the habit trackers on the App Store. This app has all that and just works. It has a clean, easy to use design and isn't buggy like some of the others I've tried. Overall, I highly recommend this app to anyone looking for a high quality habit tracker!", index: 1)
            TestimonialPage(name: "@James", text: "My biggest goal I want to create this year is creating habits! I've realized after analyzing my productivity is that I want to create habits and keep myself accoutable to the actions in my day that I know will make my life easier and create a better version of myself. This app makes it quick, simple, and seamless to create habits that you want to make and others you want to break.", index: 2)
        }
    }
    
    private var termsButton: some View {
        Button {
            if let url = Config.app.termsUrl {
                AppActionManager.shared.open(url: url)
            }
        } label: {
            Text("Terms".localized)
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
            Text("Privacy Policy".localized)
                .font(.footnote)
                .foregroundColor(.white.opacity(0.7))
                .underline()
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var upgradeButton: some View {
        Button(action: {
            if let selectedPackage {
                Haptics.shared.play()
                proManager.purchase(package: selectedPackage)
            }
        }) {
            Text(selectedPackage == proManager.weeklyPackage ? "Try for free".localized : "Continue".localized)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 70)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color(hex: "7A1CAC"), Color(hex: "2F58CD")]), startPoint: .leading, endPoint: .trailing)
                )
                .clipShape(.capsule)
                .overlay(
                    Capsule().stroke(Color.white, lineWidth: 2)
                )
                .shine(shine, duration: 2, clipShape: Capsule())
                .onReceive(timer) { _ in
                    shine.toggle()
                }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .contentTransition(.numericText())
        .animation(.linear, value: selectedPackage)
    }
}

struct TestimonialPage: View {
    let name: String
    let text: String
    let index: Int

    var body: some View {
        ZStack(alignment: index == 1 ? .topTrailing : .topLeading) {
            VStack(spacing: 20) {
                HStack {
                    if index == 0 || index == 2 {
                        Spacer()
                    }
                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { starIndex in
                            Image("ic-star")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                        }
                    }
                    if index == 1 {
                        Spacer()
                    }
                }
                Text(text.localized)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.white)
            }
            .padding()
            .background(Color.black.opacity(0.7))
            .cornerRadius(12)
            HStack(spacing: 0) {
                if index == 1 {
                    Text(name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .offset(y: 20)
                }
                Image("ic-memoji\(index + 1)")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                if index == 0 || index == 2 {
                    Text(name)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .offset(y: 20)
                }
            }
            .offset(x: 8, y: -40)
        }
    }
}


#Preview {
    PaywallView()
}
