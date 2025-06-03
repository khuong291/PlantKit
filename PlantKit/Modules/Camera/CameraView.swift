//
//  CameraView.swift
//  PlantKit
//
//  Created by Khuong Pham on 3/6/25.
//

import SwiftUI

struct CameraView: View {
    let dismissAction: () -> Void
    let onImageCaptured: (UIImage) -> Void
    @EnvironmentObject var cameraManager: CameraManager
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            content
        }
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .onAppear {
            DispatchQueue.global(qos: .userInitiated).async {
                cameraManager.configure()
            }
        }
    }
    
    private var content: some View {
        ZStack {
            // Live camera preview
            CameraPreview(session: cameraManager.session)
                .ignoresSafeArea()

            // Dark overlay with transparent cutout
            Color.black.opacity(0.5)
                .ignoresSafeArea()
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

            // Dismiss button
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
            .padding(.top, 30)
            .padding(.trailing, 10)
            
            VStack {
                Spacer()
                Button(action: {
                    Haptics.shared.play()
                    cameraManager.capturePhoto { image in
                        if let capturedImage = image {
                            onImageCaptured(capturedImage)
                        }
                        dismissAction()
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
                }
                .padding(.bottom, 50)
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
