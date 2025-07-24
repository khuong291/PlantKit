//
//  CameraView.swift
//  PlantKit
//
//  Created by Khuong Pham on 3/6/25.
//

import SwiftUI

struct CameraView: View {
    let dismissAction: () -> Void
    let onSwitchTab: (MainTab.Tab) -> Void
    let showPlantDetailsAfterCamera: (UIImage) -> Void
    @EnvironmentObject var cameraManager: CameraManager
    @EnvironmentObject var identifierManager: IdentifierManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var isShowingPhotoPicker = false
    @State private var capturingImage = false
    @State private var capturedImage: UIImage? = nil
    @State private var isIdentifying = false
    @State private var zoomFactor: CGFloat = 1.0
    @State private var lastZoomValue: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            content
            
            if let image = capturedImage {
                if isIdentifying {
                    PlantIdentifyingView(image: image, onComplete: { success in
                        isIdentifying = false
                        if success {
                            showPlantDetailsAfterCamera(image)
                        } else {
                            capturedImage = nil
                        }
                    })
                } else {
                    PhotoPreviewView(
                        image: image,
                        onIdentify: {
                            withAnimation {
                                isIdentifying = true
                            }
                        },
                        onDismiss: {
                            capturedImage = nil
                        }
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
                .onEnded { value in
                    lastZoomValue = zoomFactor
                }
        )
    }
    
    private var content: some View {
        ZStack {
            // Live camera preview
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

            // Dark overlay with transparent cutout
            Color.black.opacity(0.6)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 16)
                .mask {
                    ScanFocusMask()
                }
                .compositingGroup()
                .opacity(cameraManager.isSessionReady ? 1 : 0)

            // White border around the cutout
            GeometryReader { geo in
                let width: CGFloat = UIScreen.main.bounds.width * 0.9
                let height: CGFloat = UIScreen.main.bounds.width * 0.9
                let centerX = geo.size.width / 2
                let centerY = geo.size.height / 2

                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: width, height: height)
                    .position(x: centerX, y: centerY)
            }
            .opacity(cameraManager.isSessionReady ? 1 : 0)

            closeButton
            
            VStack {
                Spacer()
                ZStack {
                    // Center the capture button
                    captureButton
                    
                    // Position other controls on top
                    HStack {
                        Spacer().frame(width: 20)
                        photoButton
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

struct ScanFocusMask: View {
    var body: some View {
        GeometryReader { geo in
            let width: CGFloat = UIScreen.main.bounds.width * 0.9
            let height: CGFloat = UIScreen.main.bounds.width * 0.9
            let centerX = geo.size.width / 2
            let centerY = geo.size.height / 2
            let cutoutRect = CGRect(
                x: centerX - width / 2,
                y: centerY - height / 2,
                width: width,
                height: height
            )

            Path { path in
                // Full screen
                path.addRect(geo.frame(in: .local))
                // Cutout hole
                path.addRoundedRect(in: cutoutRect, cornerSize: CGSize(width: 16, height: 16))
            }
            .fill(style: FillStyle(eoFill: true)) // "Even-odd" fill rule makes the cutout transparent
        }
    }
}
