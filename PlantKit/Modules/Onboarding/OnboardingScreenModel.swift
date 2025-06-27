//
//  OnboardingScreenModel.swift
//  PlantKit
//
//  Created by Khuong Pham on 27/6/25.
//

import SwiftUI

enum OnboardingStep: CaseIterable {
    case welcome
    case experience
    case identifyTime
    case cameraPermission
    case plantDetails
    case chat
    case loading
    case rating
    // Add more steps as needed
    
    static var allCases: [OnboardingStep] {
        return [.welcome, .experience, .identifyTime, .cameraPermission, .plantDetails, .chat, .loading, .rating] // Add more steps here as you add them
    }
}

class OnboardingScreenModel: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var userExperienceLevel: ExperienceLevel? = nil
    @Published var userIdentifyTime: IdentifyTimeOption? = nil
    @Published var ratingRequested: Bool = false
    
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
            currentStep = .loading
        case .loading:
            currentStep = .rating
        case .rating:
            // Show paywall after rating step
            ProManager.shared.showUpgradePro()
            break
        }
    }
}
