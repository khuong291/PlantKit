import SwiftUI
import AVFoundation

struct OnboardingCameraPermissionStepView: View {
    @EnvironmentObject private var viewModel: OnboardingScreenModel
    @State private var cameraAuthorized = false
    @State private var showPermissionAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(alignment: .center, spacing: 8) {
                    Text("Just take a photo")
                        .font(.largeTitle).bold()
                        .padding(.top, 20)
                        .multilineTextAlignment(.center)
                    Text("Or upload one from your gallery")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 24)
                
                Spacer()
                
                ZStack(alignment: .topLeading) {
                    Image("photo-taken-img")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 500)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    Image("ic-camera")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.green)
                        .clipShape(.circle)
                        .rotationEffect(.degrees(-15))
                        .offset(x: 10)
                }
                .padding(.bottom, 32)
                
                Spacer()
            }
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea(edges: .top)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 32)
        }
        .onAppear {
            checkCameraPermission()
        }
        .alert(isPresented: $showPermissionAlert) {
            Alert(
                title: Text("Camera Access Needed"),
                message: Text("Please allow camera access to take plant photos."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    private func checkCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            cameraAuthorized = true
        case .notDetermined:
            requestCameraPermission()
        default:
            cameraAuthorized = false
        }
    }
    
    private func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                cameraAuthorized = granted
                if !granted {
                    showPermissionAlert = true
                }
            }
        }
    }
}

#Preview {
    OnboardingCameraPermissionStepView()
        .preferredColorScheme(.dark)
}
