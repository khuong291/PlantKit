//
//  OnboardingWelcomeStepView.swift
//  PlantKit
//
//  Created by Khuong Pham on 27/6/25.
//

import SwiftUI

struct OnboardingWelcomeStepView: View {
    @EnvironmentObject private var viewModel: OnboardingScreenModel
    
    var body: some View {
        content
            .padding(.top, 80)
    }
    
    private var content: some View {
        ScrollView {
            VStack {
                Text("Welcome to PlantKit")
                    .font(.system(size: 50).bold())
                    .multilineTextAlignment(.center)
                
                Text("Identify Plants. Get Care Tips. Grow Together.")
                    .font(.system(size: 28))
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
                    .padding(.top, 4)
                
                HStack(spacing: 0) {
                    Spacer()
                    LottieWrapperView(name: "plant-identifying", loopMode: .loop)
                        .frame(width: 300, height: 300)
                    Spacer()
                }
            }
            .padding()
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    OnboardingWelcomeStepView()
}

