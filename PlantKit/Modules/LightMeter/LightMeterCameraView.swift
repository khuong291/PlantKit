//
//  LightMeterCameraView.swift
//  PlantKit
//
//  Created by Khuong Pham on 14/6/24.
//

import SwiftUI
import AVFoundation

struct LightMeterCameraView: View {
    @StateObject private var lightMeterManager = LightMeterManager()
    @State private var cameraPreviewAppeared = false
    @State private var sessionStarted = false
    @State private var cameraViewId = UUID()
    var dismissAction: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            // Camera preview or loading state
            cameraContent
            
            closeButton
            
            lightLevelIndicator
        }
        .onAppear {
            // Reset state for new camera session
            cameraPreviewAppeared = false
            sessionStarted = false
            cameraViewId = UUID() // Force new CameraPreview instance
            
            // Configure camera immediately when view appears
            lightMeterManager.configure()
        }
        .onReceive(lightMeterManager.$setupState) { state in
            print("LightMeterCameraView: Setup state changed to \(state)")
            if case .configured = state, cameraPreviewAppeared, !sessionStarted {
                // Ensure session is running when configured and preview is ready
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    print("LightMeterCameraView: Starting camera session from state change")
                    lightMeterManager.start()
                    sessionStarted = true
                }
            }
        }
        .onDisappear {
            print("LightMeterCameraView: View disappearing, cleaning up")
            lightMeterManager.reset()
        }
    }
    
    @ViewBuilder
    private var cameraContent: some View {
        switch lightMeterManager.setupState {
        case .notConfigured, .configuring:
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
                Text("Preparing camera...")
                    .foregroundColor(.white)
                    .font(.system(size: 17))
            }
            
        case .configured:
            if let session = lightMeterManager.getCaptureSession() {
                ZStack {
                    // Add a colored background to see if the view is being displayed
                    Color.black
                        .edgesIgnoringSafeArea(.all)
                    
                    CameraPreview(session: session)
                        .id(cameraViewId)
                        .edgesIgnoringSafeArea(.all)
                        .onAppear {
                            cameraPreviewAppeared = true
                            print("LightMeterCameraView: Camera preview appeared")
                            // Ensure session is running when preview appears
                            if !sessionStarted {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    print("LightMeterCameraView: Starting camera session")
                                    lightMeterManager.start()
                                    sessionStarted = true
                                }
                            }
                        }
                }
            } else {
                Color.black.edgesIgnoringSafeArea(.all)
                VStack(spacing: 16) {
                    Image(systemName: "camera.slash")
                        .font(.system(size: 48))
                        .foregroundColor(.white)
                    Text("Camera not available")
                        .foregroundColor(.white)
                        .font(.system(size: 17))
                }
            }
            
        case .failed(let error):
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 48))
                    .foregroundColor(.orange)
                Text("Camera Error")
                    .foregroundColor(.white)
                    .font(.system(size: 17))
                Text(error)
                    .foregroundColor(.white.opacity(0.8))
                    .font(.system(size: 15))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button("Retry") {
                    lightMeterManager.reset()
                    lightMeterManager.configure()
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .cornerRadius(8)
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
        .padding(.top)
        .padding(.trailing, 10)
    }
    
    private var lightLevelIndicator: some View {
        VStack(spacing: 16) {
            Spacer()
            VStack(spacing: 8) {
                ProgressView(value: lightProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: .yellow))
                    .frame(height: 8)
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .cornerRadius(4)
                
                HStack(spacing: 12) {
                    Image(systemName: "sun.max.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.yellow)
                    
                    VStack(alignment: .leading) {
                        Text(lightMeterManager.lightLevel.rawValue)
                            .bold()
                        Text("Current Level")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            
            Text("Light: Use the light meter from 10 AM to 7 PM for the most accurate results.")
                .font(.system(size: 15))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 50)
        }
        .padding()
        .opacity(lightMeterManager.setupState == .configured ? 1 : 0)
    }

    private var lightProgress: Double {
        switch lightMeterManager.lightLevel {
        case .dark:
            return 0.1
        case .veryLow:
            return 0.2
        case .low:
            return 0.4
        case .medium:
            return 0.6
        case .bright:
            return 0.8
        case .veryBright:
            return 1.0
        }
    }
}

//struct CameraPreview: UIViewRepresentable {
//    let session: AVCaptureSession
//    
//    func makeUIView(context: Context) -> some UIView {
//        let view = UIView()
//        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
//        previewLayer.videoGravity = .resizeAspectFill
//        view.layer.addSublayer(previewLayer)
//        
//        DispatchQueue.main.async {
//            previewLayer.frame = view.bounds
//        }
//        
//        return view
//    }
//    
//    func updateUIView(_ uiView: UIViewType, context: Context) {
//        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
//            DispatchQueue.main.async {
//                previewLayer.frame = uiView.bounds
//            }
//        }
//    }
//} 
