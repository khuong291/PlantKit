//
//  ContentView.swift
//  PlantKit
//
//  Created by Khuong Pham on 30/5/25.
//

import SwiftUI

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
        }
    }
}

#Preview {
    ContentView()
}
