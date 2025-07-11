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

    func makeUIView(context: Context) -> CameraPreviewView {
        let view = CameraPreviewView()
        view.setSession(session)
        return view
    }

    func updateUIView(_ uiView: CameraPreviewView, context: Context) {
        uiView.setSession(session)
    }
}

class CameraPreviewView: UIView {
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .black
    }
    
    func setSession(_ session: AVCaptureSession) {
        print("CameraPreviewView: Setting session, running: \(session.isRunning)")
        
        // Create preview layer if it doesn't exist
        if previewLayer == nil {
            let newPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
            newPreviewLayer.videoGravity = .resizeAspectFill
            newPreviewLayer.frame = bounds
            
            layer.addSublayer(newPreviewLayer)
            previewLayer = newPreviewLayer
            
            print("CameraPreviewView: Created new preview layer with frame: \(bounds)")
        } else {
            // Update existing preview layer's session
            previewLayer?.session = session
            print("CameraPreviewView: Updated existing preview layer session")
        }
        
        // Ensure frame is set correctly
        DispatchQueue.main.async {
            self.previewLayer?.frame = self.bounds
            print("CameraPreviewView: Set frame to: \(self.bounds)")
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
        print("CameraPreviewView: Layout subviews, new frame: \(bounds)")
    }
}
