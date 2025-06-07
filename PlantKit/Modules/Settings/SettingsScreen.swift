//
//  SettingsScreen.swift
//  PlantKit
//
//  Created by Khuong Pham on 7/6/25.
//

import SwiftUI

struct SettingsScreen: View {
    var body: some View {
        ZStack {
            Color.appScreenBackgroundColor
                .edgesIgnoringSafeArea(.all)
            Text("Settings")
        }
    }
}

#Preview {
    SettingsScreen()
}
