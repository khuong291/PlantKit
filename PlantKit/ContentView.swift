//
//  ContentView.swift
//  PlantKit
//
//  Created by Khuong Pham on 30/5/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var proManager: ProManager = .shared
    
    var body: some View {
        VStack {
            //        MainTab()        
            OnboardingScreen()
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
