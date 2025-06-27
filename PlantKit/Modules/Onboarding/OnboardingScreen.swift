//
//  OnboardingScreen.swift
//  PlantKit
//
//  Created by Khuong Pham on 27/6/25.
//

import SwiftUI
import SFSafeSymbols

struct OnboardingScreen: View {
    @StateObject private var viewModel = OnboardingScreenModel()
    @State private var harmfulFactStep = 0
    @ObservedObject var proManager: ProManager = .shared
        
    private var showProgressBar: Bool {
        guard let idx = OnboardingStep.allCases.firstIndex(of: viewModel.currentStep) else { return false }
        return idx > 0
    }

    private var progressValue: Double {
        guard let idx = OnboardingStep.allCases.firstIndex(of: viewModel.currentStep), OnboardingStep.allCases.count > 1 else { return 0 }
        return Double(idx) / Double(OnboardingStep.allCases.count - 1)
    }
    
    var body: some View {
        VStack {
            if showProgressBar && viewModel.currentStep != .loading {
                ProgressView(value: progressValue)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color.green))
                    .frame(height: 4)
                    .padding(.top, 12)
                    .padding(.horizontal)
            }
            Group {
                switch viewModel.currentStep {
                case .welcome:
                    OnboardingWelcomeStepView()
                case .experience:
                    OnboardingExperienceStepView(selectedLevel: $viewModel.userExperienceLevel)
                case .identifyTime:
                    OnboardingIdentifyTimeStepView(selectedTime: $viewModel.userIdentifyTime)
                case .cameraPermission:
                    OnboardingCameraPermissionStepView()
                case .plantDetails:
                    OnboardingPlantDetailsStepView()
                case .chat:
                    OnboardingChatStepView()
                case .loading:
                    OnboardingLoadingStepView() {
                        viewModel.goToNextStep()
                    }
                case .rating:
                    OnboardingGiveRatingStepView(requested: $viewModel.ratingRequested)
                }
            }
            .padding(.horizontal)
            .animation(.easeInOut, value: viewModel.currentStep)
            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            
            if viewModel.currentStep == .welcome {
                ShinyBorderButton(systemName: "sparkles", title: "Get Started") {
                    Haptics.shared.play()
                    withAnimation {
                        viewModel.goToNextStep()
                    }
                }
                .shadow(color: Color.green.opacity(0.8), radius: 8, x: 0, y: 0)
                .padding(.horizontal)
                .padding(.horizontal, 8)
                .padding(.bottom, 20)
            } else if viewModel.currentStep != .loading {
                continueButton
                    .padding(.horizontal)
                    .padding(.bottom, 20)
            }
        }
        .background(
            ZStack {
                Image("bg-image")
                    .resizable()
                    .scaledToFill()
                    .blur(radius: 6)
                Color.black.opacity(0.7)
            }
                .ignoresSafeArea()
        )
        .ignoresSafeArea(.keyboard)
        .environmentObject(viewModel)
        .preferredColorScheme(.dark)
    }
    
    private var continueButton: some View {
        Button {
            Haptics.shared.play()
            withAnimation {
                viewModel.goToNextStep()
            }
        } label: {
            Text("Continue")
                .font(.system(size: 20))
                .bold()
                .foregroundColor(viewModel.continueDisabled ? .white.opacity(0.5) : .black)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(viewModel.continueDisabled ? Color.white.opacity(0.2) : Color.white)
                .clipShape(Capsule())
                .padding(.horizontal)
        }
        .disabled(viewModel.continueDisabled)
        .buttonStyle(CardButtonStyle())
    }
}

#Preview {
    OnboardingScreen()
}
