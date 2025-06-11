//
//  PhotoPreviewView.swift
//  PlantKit
//
//  Created by Khuong Pham on 5/6/25.
//

import SwiftUI

struct PhotoPreviewView: View {
    let image: UIImage
    let onIdentify: () -> Void
    let onDismiss: () -> Void
    @State private var isIdentifying = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if isIdentifying {
                PlantIdentifyingView(image: image, onComplete: {
//                    onIdentify()
                })
            } else {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            onDismiss()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.camera")
                                Text("Retake")
                            }
                            .foregroundColor(.white)
                            .padding()
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.trailing)

                    Spacer()

                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.width * 0.9)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white, lineWidth: 2)
                        )

                    Spacer()

                    ShinyBorderButton {
                        withAnimation {
                            isIdentifying = true
                        }
                    }
                    .shadow(color: Color.green.opacity(0.8), radius: 8, x: 0, y: 0)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

struct PlantIdentifyingView: View {
    let image: UIImage
    let onComplete: () -> Void
    
    @State private var currentStep = 0
    @State private var scanProgress: CGFloat = 0
    @State private var isReversing = false
    
    private let steps = [
        "Analyzing image",
        "Identifying characteristics",
        "Preparing results"
    ]
    
    var body: some View {
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
                            ProgressView()
                                .tint(.white)
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
        .onAppear {
            startIdentificationProcess()
        }
    }
    
    private func startIdentificationProcess() {
        // Start scanning animation
        animateScanning()
        
        // Step 1: Analyzing image
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation {
                currentStep = 1
            }
            
            // Step 2: Identifying characteristics
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
                withAnimation {
                    currentStep = 2
                }
                
                // Complete the process
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    onComplete()
                }
            }
        }
    }
    
    private func animateScanning() {
        withAnimation(.linear(duration: 1.5)) {
            if isReversing {
                scanProgress = 0
            } else {
                scanProgress = UIScreen.main.bounds.width * 0.9 - 6 // Total height minus line height
            }
        } completion: {
            isReversing.toggle()
            animateScanning()
        }
    }
}

struct ShinyBorderButton: View {
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: "sparkles")
                Text("Identify")
            }
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundColor(.white)

            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(Color.green)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(Color.white.opacity(0.8), lineWidth: 2)
            }
            .overlay {
                ShiningLines()
                    .clipShape(Capsule())
            }
        }
    }
}

struct ShiningLines: View {
    let duration: TimeInterval = 2.0

    var body: some View {
        TimelineView(.animation) { timeline in
            let now = timeline.date.timeIntervalSinceReferenceDate
            let progress = now.truncatingRemainder(dividingBy: duration) / duration
            let shineX = CGFloat(progress) * 400 - 100 // Starts off-screen left and moves to right

            Canvas { context, size in
                let shineWidth: CGFloat = 60
                let topY: CGFloat = 1
                let bottomY: CGFloat = size.height - 1

                let gradient = Gradient(stops: [
                    .init(color: .clear, location: 0.0),
                    .init(color: .white.opacity(0.9), location: 0.5),
                    .init(color: .clear, location: 1.0),
                ])

                // Top shine line
                var topLine = Path()
                topLine.move(to: CGPoint(x: shineX, y: topY))
                topLine.addLine(to: CGPoint(x: shineX + shineWidth, y: topY))
                context.stroke(topLine, with: .linearGradient(gradient,
                                                              startPoint: CGPoint(x: shineX, y: topY),
                                                              endPoint: CGPoint(x: shineX + shineWidth, y: topY)),
                               lineWidth: 2)

                // Bottom shine line
                var bottomLine = Path()
                bottomLine.move(to: CGPoint(x: shineX, y: bottomY))
                bottomLine.addLine(to: CGPoint(x: shineX + shineWidth, y: bottomY))
                context.stroke(bottomLine, with: .linearGradient(gradient,
                                                                 startPoint: CGPoint(x: shineX, y: bottomY),
                                                                 endPoint: CGPoint(x: shineX + shineWidth, y: bottomY)),
                               lineWidth: 2)
            }
        }
    }
}
