import SwiftUI

struct PlantDiagnosingView: View {
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
    @EnvironmentObject var healthCheckManager: HealthCheckManager
    
    private let steps = [
        "Analyzing image",
        "Detecting health issues",
        "Finalizing diagnosis"
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
                    VStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.green)
                            .frame(height: 6)
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
                    ForEach(0..<steps.count, id: \ .self) { index in
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
        }
        .onAppear {
            startDiagnosingProcess()
        }
        .onDisappear {
            completionTimer?.invalidate()
            completionTimer = nil
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(
                title: Text("Diagnosis Failed"),
                message: Text("Please take another image and try again"),
                dismissButton: .default(Text("Try Again")) {
                    onComplete(false)
                }
            )
        }
    }
    
    private func startDiagnosingProcess() {
        animateScanning()
        simulateSteps()
        healthCheckManager.diagnose(image: image) { result in
            switch result {
            case .success:
                isApiCompleted = true
                checkCompletion()
            case .failure(let error):
                isAnimating = false
                errorMessage = error.localizedDescription
                hasError = true
                completionTimer?.invalidate()
                showErrorAlert = true
            }
        }
    }
    
    private func simulateSteps() {
        let step1Duration = Double.random(in: 4.0...5.2)
        DispatchQueue.main.asyncAfter(deadline: .now() + step1Duration) {
            if hasError { return }
            Haptics.shared.play()
            withAnimation { currentStep = 1 }
            let step2Duration = Double.random(in: 3.5...5.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + step2Duration) {
                if hasError { return }
                Haptics.shared.play()
                withAnimation { currentStep = 2 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                    if hasError { return }
                    Haptics.shared.play()
                    withAnimation {
                        currentStep = 3
                        isAnimating = false
                    }
                    checkCompletion()
                }
            }
        }
    }
    
    private func checkCompletion() {
        if isApiCompleted && currentStep == 3 && !isCompleting {
            isCompleting = true
            completionTimer?.invalidate()
            completionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
                onComplete(true)
            }
        }
    }
    
    private func animateScanning() {
        guard isAnimating, !hasError else { return }
        withAnimation(.linear(duration: 1.5)) {
            if isReversing {
                scanProgress = 0
            } else {
                scanProgress = UIScreen.main.bounds.width * 0.9 - 6
            }
        } completion: {
            if isAnimating {
                isReversing.toggle()
                animateScanning()
            }
        }
    }
} 