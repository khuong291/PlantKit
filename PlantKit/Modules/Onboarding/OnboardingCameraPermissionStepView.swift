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
                    Text("Or upload one from your gallery")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 24)
                
                Spacer()
                
                // Phone mockup with sample image
                ZStack {
                    RoundedRectangle(cornerRadius: 36, style: .continuous)
                        .fill(Color(.systemBackground))
                        .shadow(radius: 8)
                        .frame(width: 260, height: 520)
                    Image("photo-taken-img")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 240, height: 500)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
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
} 