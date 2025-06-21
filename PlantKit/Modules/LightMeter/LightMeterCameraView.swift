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
    var dismissAction: () -> Void
    
    var body: some View {
        ZStack {
            if let session = lightMeterManager.getCaptureSession() {
                CameraPreview(session: session)
                    .edgesIgnoringSafeArea(.all)
            } else {
                Color.black.edgesIgnoringSafeArea(.all)
                Text("Preparing camera...")
                    .foregroundColor(.white)
            }
            
            closeButton
            
            lightLevelIndicator
        }
        .onAppear {
            lightMeterManager.start()
        }
        .onDisappear {
            lightMeterManager.stop()
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
                        .font(.title)
                        .foregroundColor(.yellow)
                    
                    VStack(alignment: .leading) {
                        Text(lightMeterManager.lightLevel.rawValue)
                            .bold()
                        Text("Current Level")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            
            Text("Light: Use the light meter from 10 AM to 7 PM for the most accurate results.")
                .font(.caption)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 50)
        }
        .padding()
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
