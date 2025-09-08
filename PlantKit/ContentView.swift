//
//  ContentView.swift
//  PlantKit
//
//  Created by Khuong Pham on 30/5/25.
//

import SwiftUI
import Mixpanel

struct ContentView: View {
    @ObservedObject var proManager: ProManager = .shared
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    @AppStorage("didInstall") var didInstall = false
    
    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTab()
            } else {
                OnboardingScreen()
            }
        }
        .fullScreenCover(isPresented: $proManager.showsUpgradeProView) {
            PaywallView()
        }
        .onAppear {
            ProManager.shared.setup()
            
            if !didInstall {
                didInstall = true
                let countryCode = Locale.current.region?.identifier ?? "Unknown"
                
                // Ensure Mixpanel is initialized before tracking
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if Mixpanel.mainInstance() != nil {
                        Mixpanel.mainInstance().track(event:"Installed", properties: [
                            "country": countryCode,
                        ])
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
