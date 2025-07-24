import SwiftUI

struct HealthCheckCameraView: View {
    let dismissAction: () -> Void
    @EnvironmentObject var cameraManager: CameraManager
    @EnvironmentObject var healthCheckManager: HealthCheckManager

    @State private var isShowingPhotoPicker = false
    @State private var capturingImage = false
    @State private var capturedImage: UIImage? = nil
    @State private var isDiagnosing = false
    @State private var showResults = false
    @State private var zoomFactor: CGFloat = 1.0
    @State private var lastZoomValue: CGFloat = 1.0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            content

            if let image = capturedImage {
                if isDiagnosing {
                    PlantDiagnosingView(image: image, onComplete: { success in
                        isDiagnosing = false
                        if success {
                            showResults = true
                        } else {
                            capturedImage = nil
                        }
                    })
                    .environmentObject(healthCheckManager)
                } else if showResults, let diagnosis = healthCheckManager.lastDiagnosis {
                    PlantDiagnosisResultView(
                        image: image,
                        diagnosis: diagnosis,
                        onDismiss: {
                            showResults = false
                            capturedImage = nil
                            dismissAction()
                        }
                    )
                } else {
                    PhotoPreviewView(
                        image: image,
                        onIdentify: {
                            withAnimation { isDiagnosing = true }
                        },
                        onDismiss: {
                            capturedImage = nil
                        },
                        buttonTitle: "Diagnose"
                    )
                }
            }
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .onAppear {
            DispatchQueue.global(qos: .userInitiated).async {
                cameraManager.configure()
            }
        }
        .onDisappear {
            cameraManager.stopSession()
        }
        .sheet(isPresented: $isShowingPhotoPicker) {
            PhotoPicker { image in
                if let selectedImage = image?.croppedToCenterSquare() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        capturedImage = selectedImage
                    }
                }
            }
        }
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    let newZoom = min(max(lastZoomValue * value, 1.0), 5.0)
                    zoomFactor = newZoom
                    cameraManager.setZoomFactor(zoomFactor)
                }
                .onEnded { _ in
                    lastZoomValue = zoomFactor
                }
        )
    }

    private var content: some View {
        ZStack {
            if cameraManager.isSessionReady {
                CameraPreview(session: cameraManager.captureSession)
                    .ignoresSafeArea()
            } else {
                // Loading state while camera is initializing
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    Text("Preparing camera...")
                        .foregroundColor(.white)
                        .font(.system(size: 17).weight(.semibold))
                }
            }
            
            Color.black.opacity(0.6)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 16)
                .mask { ScanFocusMask() }
                .compositingGroup()
                .opacity(cameraManager.isSessionReady ? 1 : 0)
                
            GeometryReader { geo in
                let width: CGFloat = UIScreen.main.bounds.width * 0.9
                let centerX = geo.size.width / 2
                let centerY = geo.size.height / 2
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: width, height: width)
                    .position(x: centerX, y: centerY)
            }
            .opacity(cameraManager.isSessionReady ? 1 : 0)
            
            closeButton
            VStack {
                Spacer()
                HStack(alignment: .center) {
                    Spacer().frame(width: 20)
                    photoButton
                    Spacer()
                    captureButton
                    Spacer()
                    ZoomWedgeControl(
                        zoomFactor: $zoomFactor,
                        minZoom: 1.0,
                        maxZoom: 5.0,
                        onZoomChanged: { newValue in
                            cameraManager.setZoomFactor(newValue)
                        }
                    )
                    Spacer().frame(width: 20)
                }
                .padding(.bottom, 50)
            }
            .opacity(cameraManager.isSessionReady ? 1 : 0)
        }
    }

    private var closeButton: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    Haptics.shared.play()
                    dismissAction()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                        .padding()
                }
            }
            Spacer()
        }
        .padding(.top, 50)
        .padding(.trailing, 10)
    }

    private var photoButton: some View {
        Button(action: {
            Haptics.shared.play()
            isShowingPhotoPicker = true
        }) {
            Image(systemName: "photo.on.rectangle")
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .foregroundColor(.white)
                .padding(10)
                .background(Color.clear)
                .clipShape(Circle())
        }
    }

    private var captureButton: some View {
        Button(action: {
            Haptics.shared.play()
            capturingImage = true
            cameraManager.capturePhoto { image in
                if let captured = image?.croppedToCenterSquare() {
                    capturingImage = false
                    capturedImage = captured
                }
            }
        }) {
            Circle()
                .fill(Color.white)
                .frame(width: 70, height: 70)
                .overlay(
                    Circle()
                        .stroke(Color.green, lineWidth: 4)
                )
                .shadow(color: Color.green.opacity(0.8), radius: 10, x: 0, y: 0)
                .opacity(capturingImage ? 0.5 : 1)
                .overlay {
                    if capturingImage {
                        ProgressView()
                    }
                }
        }
    }
} 
