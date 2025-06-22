//
//  CameraPreview.swift
//  PlantKit
//
//  Created by Khuong Pham on 3/6/25.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black

        // Create a video preview layer using the session from CameraManager
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill // Fill the screen nicely
        previewLayer.frame = view.bounds

        view.layer.addSublayer(previewLayer)

        // Ensure the session is running
        if !session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async {
                session.startRunning()
            }
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            // Update frame when the view bounds change
            DispatchQueue.main.async {
                previewLayer.frame = uiView.bounds
            }
        }
    }
}
