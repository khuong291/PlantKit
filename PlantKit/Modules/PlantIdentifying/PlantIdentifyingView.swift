//
//  PlantIdentifyingView.swift
//  PlantKit
//
//  Created by Khuong Pham on 13/6/25.
//

import SwiftUI

struct PlantIdentifyingView: View {
    let image: UIImage
    let onComplete: (Bool) -> Void
    
    @State private var currentStep = 0
    @State private var scanProgress: CGFloat = 0
    @State private var isReversing = false
    @State private var isAnimating = true
    @State private var isApiCompleted = false
    @State private var isCompleting = false
    @State private var completionTimer: Timer?
    @State private var errorMessage: String? = nil
    @State private var hasError: Bool = false
    @State private var showErrorAlert: Bool = false
    @EnvironmentObject var identifierManager: IdentifierManager
    
    private let steps = [
        "Analyzing image",
        "Identifying characteristics",
        "Finalizing results"
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
                            if index == currentStep || (index == 2 && currentStep == 3) {
                                ProgressView()
                                    .tint(.white)
                            } else if index < currentStep && index != 2 {
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
//            // Error overlay
//            if let errorMessage = errorMessage {
//                Color.black.opacity(0.7).ignoresSafeArea()
//                VStack(spacing: 24) {
//                    Image(systemName: "exclamationmark.triangle.fill")
//                        .font(.system(size: 48))
//                        .foregroundColor(.yellow)
//                    Text("Identification Failed")
//                        .font(.title2)
//                        .fontWeight(.bold)
//                        .foregroundColor(.white)
//                    Text(errorMessage)
//                        .font(.body)
//                        .foregroundColor(.white)
//                        .multilineTextAlignment(.center)
//                    Button(action: {
//                        onComplete(false)
//                    }) {
//                        Text("Try Again")
//                            .font(.headline)
//                            .foregroundColor(.black)
//                            .padding()
//                            .frame(maxWidth: .infinity)
//                            .background(Color.yellow)
//                            .cornerRadius(12)
//                    }
//                    .padding(.horizontal, 40)
//                }
//                .padding(32)
//                .background(Color.black.opacity(0.85))
//                .cornerRadius(24)
//                .padding(32)
//            }
        }
        .onAppear {
            startIdentificationProcess()
        }
        .onDisappear {
            completionTimer?.invalidate()
            completionTimer = nil
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Identification Failed"),
                message: Text("Please take another image and try again"),
                dismissButton: .default(Text("Try Again")) {
                    onComplete(false)
                }
            )
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
                isAnimating = false
                errorMessage = error.localizedDescription
                hasError = true
                completionTimer?.invalidate()
                showErrorAlert = true
            }
        }
    }
    
    private func simulateSteps() {
        // Step 1: Analyzing image
        let step1Duration = Double.random(in: 4.0...5.2)
        DispatchQueue.main.asyncAfter(deadline: .now() + step1Duration) {
            if hasError { return }
            print("Step 1 complete")
            Haptics.shared.play()
            withAnimation {
                currentStep = 1
            }
            
            // Step 2: Identifying characteristics
            let step2Duration = Double.random(in: 3.5...5.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + step2Duration) {
                if hasError { return }
                print("Step 2 complete")
                Haptics.shared.play()
                withAnimation {
                    currentStep = 2
                }
                
                // Step 3: Preparing results
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                    if hasError { return }
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
            completionTimer?.invalidate()
            completionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                print("Calling onComplete (success)")
                onComplete(true)
            }
        } else {
            print("Conditions not met - waiting for both API completion and step 3")
        }
    }
    
    private func animateScanning() {
        guard isAnimating, !hasError else { return }
        
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
