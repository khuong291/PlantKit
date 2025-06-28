//
//  OnboardingLoadingStepView.swift
//  PlantKit
//
//  Created by Khuong Pham on 27/6/25.
//

import SwiftUI
import SFSafeSymbols
import ConfettiSwiftUI

struct OnboardingLoadingStepView: View {
    private let stageText = [
        "Optimizing identification engine...",
        "Training your AI plan expert...",
        "Preparing your toolkit...",
        "Finalizing result..."
    ]
    
    @State private var loadingStage = 0
    @State private var progress: CGFloat = 0.0
    @State private var isComplete = false
    @State private var trigger: Int = 0

    let onFinish: () -> ()
    
    var body: some View {
        VStack {
            if isComplete {
                Spacer()
                
                VStack(spacing: 24) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.1))
                            .frame(width: 160, height: 160)
                        
                        Image(systemSymbol: .checkmarkCircleFill)
                            .resizable()
                            .foregroundColor(.green)
                            .frame(width: 80, height: 80)
                    }

                    Text("Ready!")
                        .font(.largeTitle)
                        .bold()
                        .multilineTextAlignment(.center)
                        .onAppear {
                            trigger += 1
                        }
                }

                Spacer()
            } else {
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                        .frame(width: 200, height: 200)
                    
                    Circle()
                        .trim(from: 0.0, to: progress / 100)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [Color.green, .green]),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: 200, height: 200)
                        .animation(.linear(duration: 0.4), value: progress)
                    
                    Text("\(Int(progress))%")
                        .font(.system(size: 50, weight: .bold, design: .rounded))
                }
                
                Spacer().frame(height: 30)
                
                Text("We're personalizing your experience")
                    .multilineTextAlignment(.center)
                    .font(.title)
                    .bold()
                
                Spacer().frame(height: 16)
                
                Text(stageText[safe: loadingStage] ?? "")
                    .multilineTextAlignment(.center)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
        }
        .padding()
        .frame(maxWidth: 300)
        .confettiCannon(trigger: $trigger, num: 50, confettiSize: 20)
        .onAppear {
            Task {
                let totalSteps = 100
                let stages = stageText.count
                let stepsPerStage = totalSteps / stages
                
                for i in 0 ..< stages {
                    Haptics.shared.play()
                    self.loadingStage = i
                    for j in 0 ..< stepsPerStage {
                        await MainActor.run {
                            self.progress = CGFloat(i * stepsPerStage + j)
                        }
                        if i == 3 && [16, 17, 18, 19, 20].contains(j) {
                            try? await Task.sleep(nanoseconds: UInt64(Int.random(in: 330_000_000 ... 500_000_000)))
                        } else {
                            try? await Task.sleep(nanoseconds: UInt64(Int.random(in: 20_000_000 ... 120_000_000)))
                        }
                    }
                }

                await MainActor.run {
                    self.progress = 100
                    self.isComplete = true
                    Haptics.shared.play()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        onFinish()
                    }
                }
            }
        }
    }
}

#Preview {
    OnboardingLoadingStepView() {}
}
