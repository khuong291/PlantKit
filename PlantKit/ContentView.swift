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
        MainTab()
            .onAppear {
                ProManager.shared.setup()
            }
            .fullScreenCover(isPresented: $proManager.showsUpgradeProView) {
                PaywallView()
            }
    }
}

#Preview {
    ContentView()
}
