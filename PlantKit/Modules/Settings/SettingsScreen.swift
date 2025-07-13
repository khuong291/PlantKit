//
//  SettingsScreen.swift
//  PlantKit
//
//  Created by Khuong Pham on 7/6/25.
//

import SwiftUI
import StoreKit
import MessageUI
import RevenueCat

struct SettingsScreen: View {
    @Environment(\.requestReview) var requestReview
    @EnvironmentObject private var proManager: ProManager
    @State private var showMailView = false
    @State private var showRateAlert = false
    @State private var showUpgradePro = false
    
    var body: some View {
        ZStack {
            Color.appScreenBackgroundColor
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    accountSection
                    supportSection
                    legalSection
                    aboutSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showUpgradePro) {
            PaywallView()
                .environmentObject(proManager)
        }
        .sheet(isPresented: $showMailView) {
            MailComposeView()
        }
        .alert("Rate PlantKit", isPresented: $showRateAlert) {
            Button("Rate on App Store") {
                rateApp()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("If you enjoy using PlantKit, please take a moment to rate it on the App Store. Your feedback helps us improve!")
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 16) {
            // App Header
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.green)
                }
                
                VStack(spacing: 4) {
                    Text("PlantKit")
                        .font(.system(size: 22))
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(proManager.hasPro ? "Pro Plan" : "Free Plan")
                        .font(.system(size: 15))
                        .foregroundColor(proManager.hasPro ? .green : .secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(proManager.hasPro ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                        )
                }
            }
            .padding(.vertical, 20)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 2)
        )
    }
    
    private var accountSection: some View {
        VStack(spacing: 0) {
            if !proManager.hasPro {
                settingsRow(
                    icon: "crown.fill",
                    iconColor: .yellow,
                    title: "Upgrade to Pro",
                    subtitle: "Unlock unlimited features",
                    showChevron: true,
                    action: { showUpgradePro = true }
                )
                
                Divider()
                    .padding(.leading, 56)
            }
            
            settingsRowWithCopyButton(
                icon: "creditcard.fill",
                iconColor: .blue,
                title: "Purchase ID",
                subtitle: "Your unique identifier",
                action: { copyPurchaseID() }
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private var supportSection: some View {
        VStack(spacing: 0) {
            settingsRow(
                icon: "star.fill",
                iconColor: .yellow,
                title: "Rate PlantKit",
                subtitle: "Share your feedback",
                showChevron: false,
                action: { showRateAlert = true }
            )
            
            Divider()
                .padding(.leading, 56)
            
            settingsRow(
                icon: "envelope.fill",
                iconColor: .green,
                title: "Contact Us",
                subtitle: "Get help and support",
                showChevron: true,
                action: { contactUs() }
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private var legalSection: some View {
        VStack(spacing: 0) {
            settingsRow(
                icon: "hand.raised.fill",
                iconColor: .red,
                title: "Privacy Policy",
                subtitle: "How we protect your data",
                showChevron: true,
                action: { openPrivacyPolicy() }
            )
            
            Divider()
                .padding(.leading, 56)
            
            settingsRow(
                icon: "doc.text.fill",
                iconColor: .gray,
                title: "Terms of Service",
                subtitle: "Our terms and conditions",
                showChevron: true,
                action: { openTermsOfService() }
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private var aboutSection: some View {
        VStack(spacing: 0) {
            settingsRow(
                icon: "info.circle.fill",
                iconColor: .blue,
                title: "About PlantKit",
                subtitle: "Visit our website",
                showChevron: true,
                action: { openAboutWebsite() }
            )
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private func settingsRow(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        showChevron: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            Haptics.shared.play()
            action()
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(iconColor)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 17))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func settingsRowWithCopyButton(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            Haptics.shared.play()
            action()
        }) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(iconColor)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 17))
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "doc.on.doc.fill")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func rateApp() {
        requestReview()
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
    
    private func openAboutWebsite() {
        if let url = URL(string: "https://www.plantkit.app") {
            UIApplication.shared.open(url)
        }
    }
    
    private func contactUs() {
        if MFMailComposeViewController.canSendMail() {
            showMailView = true
        } else {
            // If Mail app is not available, open the website
            if let url = URL(string: "https://www.plantkit.app") {
                UIApplication.shared.open(url)
            }
        }
    }
    
    private func copyPurchaseID() {
        let appUserID = Purchases.shared.appUserID
        UIPasteboard.general.string = appUserID
        Haptics.shared.play()
    }
}

// MARK: - Mail Compose View
struct MailComposeView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailComposer = MFMailComposeViewController()
        mailComposer.mailComposeDelegate = context.coordinator
        mailComposer.setToRecipients(["plantkit.app@gmail.com"])
        mailComposer.setSubject("PlantKit Support")
        
        let iPhoneModel = UIDevice.current.model
        let iOSVersion = UIDevice.current.systemVersion
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let userID = Purchases.shared.appUserID
        
        let messageBody = """
        Hello PlantKit team,
        
        I need help with:
        
        [Please describe your issue here]
        
        Thank you!
        
        
        Device: \(iPhoneModel)
        OS version: \(iOSVersion)
        App version: \(appVersion)
        User ID: \(userID)
        """
        
        mailComposer.setMessageBody(messageBody, isHTML: false)
        return mailComposer
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailComposeView
        
        init(_ parent: MailComposeView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.dismiss()
        }
    }
}

#Preview {
    SettingsScreen()
        .environmentObject(ProManager.shared)
}
