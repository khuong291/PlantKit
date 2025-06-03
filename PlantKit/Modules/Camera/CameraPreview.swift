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

        // Create a video preview layer using the session from CameraManager
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill // Fill the screen nicely
        previewLayer.frame = view.bounds

        view.layer.addSublayer(previewLayer)

        DispatchQueue.main.async {
            // Ensure it resizes correctly once view is laid out
            previewLayer.frame = view.bounds
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if let previewLayer = uiView.layer.sublayers?.first as? AVCaptureVideoPreviewLayer {
            // Keep it updated if the SwiftUI layout changes
            previewLayer.frame = uiView.bounds
        }
    }
}
