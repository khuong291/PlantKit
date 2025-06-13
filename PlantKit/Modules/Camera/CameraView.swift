//
//  CameraView.swift
//  PlantKit
//
//  Created by Khuong Pham on 3/6/25.
//

import SwiftUI

struct CameraView: View {
    let dismissAction: () -> Void
    @EnvironmentObject var cameraManager: CameraManager
    
    @State private var isShowingPhotoPicker = false
    @State private var capturingImage = false
    @State private var capturedImage: UIImage? = nil
    @State private var isIdentifying = false
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            content
            
            if let image = capturedImage {
                if isIdentifying {
                    PlantIdentifyingView(image: image, onComplete: {
                        capturedImage = nil
                        isIdentifying = false
                        dismissAction()
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
        .sheet(isPresented: $isShowingPhotoPicker) {
            PhotoPicker { image in
                if let selectedImage = image?.croppedToCenterSquare() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        capturedImage = selectedImage
                    }
                }
            }
        }
    }
    
    private var content: some View {
        ZStack {
            // Live camera preview
            CameraPreview(session: cameraManager.session)
                .ignoresSafeArea()

            // Dark overlay with transparent cutout
            Color.black.opacity(0.6)
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 16)
                .mask {
                    ScanFocusMask()
                }
                .compositingGroup()

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

            closeButton
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                        .frame(width: 20)
                    
                    photoButton
                        .opacity(0)
                        .disabled(true)
                    
                    Spacer()
                    
                    captureButton
                    
                    Spacer()
                    
                    photoButton
                    
                    Spacer()
                        .frame(width: 20)
                }
                .padding(.bottom, 50)
            }
        }
    }
    
    private var closeButton: some View {
        VStack {
            HStack {
                Spacer()
                Button {
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
