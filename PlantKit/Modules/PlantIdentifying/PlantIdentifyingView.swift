//
//  PlantIdentifyingView.swift
//  PlantKit
//
//  Created by Khuong Pham on 13/6/25.
//

import SwiftUI

struct PlantIdentifyingView: View {
    let image: UIImage
    let onComplete: () -> Void
    
    @State private var currentStep = 0
    @State private var scanProgress: CGFloat = 0
    @State private var isReversing = false
    @State private var isAnimating = true
    @State private var isApiCompleted = false
    @State private var isCompleting = false
    @State private var completionTimer: Timer?
    @EnvironmentObject var identifierManager: IdentifierManager
    
    private let steps = [
        "Analyzing image",
        "Identifying characteristics",
        "Preparing results"
    ]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 32) {
                Spacer()
                
                ZStack(alignment: .top) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.width * 0.9)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white, lineWidth: 2)
                        )
                    
                    // Scanning animation
                    if currentStep < 3 {
                        VStack(spacing: 0) {
                            // Horizontal scanning line
                            Rectangle()
                                .fill(Color.green)
                                .frame(height: 6)
                            
                            // Gradient overlay
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [.green.opacity(0.5), .clear]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(height: UIScreen.main.bounds.width * 0.6)
                        }
                        .offset(y: scanProgress)
                        .animation(.linear(duration: 1.5), value: scanProgress)
                    }
                }
                .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.width * 0.9)
                .cornerRadius(16)
                .clipped()
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white, lineWidth: 2)
                )
                
                VStack(spacing: 24) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        HStack(spacing: 16) {
                            if index == currentStep {
                                if index == 2 && !isApiCompleted {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    ProgressView()
                                        .tint(.white)
                                }
                            } else if index < currentStep {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.green)
                            } else {
                                Circle()
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                                    .frame(width: 20, height: 20)
                            }
                            
                            Text(steps[index])
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(index <= currentStep ? .white : .gray.opacity(0.5))
                        }
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            startIdentificationProcess()
        }
        .onDisappear {
            completionTimer?.invalidate()
            completionTimer = nil
        }
    }
    
    private func startIdentificationProcess() {
        print("Starting identification process")
        // Start scanning animation
        animateScanning()
        
        // Start simulated steps
        simulateSteps()
        
        // Start identification process
        print("Calling identifierManager.identify")
        identifierManager.identify(image: image) { result in
            print("Received result from identifierManager.identify:", result)
            switch result {
            case .success:
                print("API call successful")
                isApiCompleted = true
                print("Setting isApiCompleted to true")
                checkCompletion()
            case .failure(let error):
                print("Failure case - error:", error)
                // Handle error case
                isAnimating = false
                onComplete()
            }
        }
    }
    
    private func simulateSteps() {
        // Step 1: Analyzing image
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            print("Step 1 complete")
            Haptics.shared.play()
            withAnimation {
                currentStep = 1
            }
            
            // Step 2: Identifying characteristics
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                print("Step 2 complete")
                Haptics.shared.play()
                withAnimation {
                    currentStep = 2
                }
                
                // Step 3: Preparing results
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                    print("Step 3 complete")
                    Haptics.shared.play()
                    withAnimation {
                        currentStep = 3
                        // Stop the scanning animation when step 3 is reached
                        isAnimating = false
                    }
                    checkCompletion()
                }
            }
        }
    }
    
    private func checkCompletion() {
        print("Checking completion - isApiCompleted:", isApiCompleted, "currentStep:", currentStep, "isCompleting:", isCompleting)
        // Only complete when both API is done and simulation reached step 3
        if isApiCompleted && currentStep == 3 && !isCompleting {
            print("Both conditions met - waiting 1 second before completion")
            isCompleting = true
            
            // Invalidate any existing timer
            completionTimer?.invalidate()
            
            // Create new timer
            completionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                print("Calling onComplete")
                onComplete()
            }
        } else {
            print("Conditions not met - waiting for both API completion and step 3")
        }
    }
    
    private func animateScanning() {
        guard isAnimating else { return }
        
        withAnimation(.linear(duration: 1.5)) {
            if isReversing {
                scanProgress = 0
            } else {
                scanProgress = UIScreen.main.bounds.width * 0.9 - 6 // Total height minus line height
            }
        } completion: {
            if isAnimating {
                isReversing.toggle()
                animateScanning()
            }
        }
    }
}
