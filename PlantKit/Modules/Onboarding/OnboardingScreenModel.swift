//
//  OnboardingScreenModel.swift
//  PlantKit
//
//  Created by Khuong Pham on 27/6/25.
//

import SwiftUI
import Mixpanel

enum OnboardingStep: CaseIterable {
    case welcome
    case experience
    case identifyTime
    case cameraPermission
    case plantDetails
    case chat
    case locationPermission
    case loading
    case rating
    // Add more steps as needed
    
    static var allCases: [OnboardingStep] {
        return [.welcome, .experience, .identifyTime, .cameraPermission, .plantDetails, .chat, .locationPermission, .loading, .rating] // Add more steps here as you add them
    }
}

class OnboardingScreenModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var userExperienceLevel: ExperienceLevel? = nil
    @Published var userIdentifyTime: IdentifyTimeOption? = nil
    @Published var ratingRequested: Bool = false
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false
    
    var continueDisabled: Bool {
        switch currentStep {
        case .experience:
            return userExperienceLevel == nil
        case .identifyTime:
            return userIdentifyTime == nil
        default:
            return false
        }
    }
    
    func goToNextStep() {
        switch currentStep {
        case .welcome:
            currentStep = .experience
        case .experience:
            currentStep = .identifyTime
        case .identifyTime:
            currentStep = .cameraPermission
        case .cameraPermission:
            currentStep = .plantDetails
        case .plantDetails:
            currentStep = .chat
        case .chat:
            currentStep = .locationPermission
        case .locationPermission:
            currentStep = .loading
        case .loading:
            currentStep = .rating
        case .rating:
            // Mark onboarding as completed
            hasCompletedOnboarding = true
            
            // Ensure Mixpanel is initialized before tracking
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if Mixpanel.mainInstance() != nil {
                    Mixpanel.mainInstance().track(event:"Onboarded", properties: [:])
                }
            }
            break
        }
    }
}
