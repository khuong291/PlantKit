//
//  CameraManager.swift
//  PlantKit
//
//  Created by Khuong Pham on 3/6/25.
//

import AVFoundation
import SwiftUI

class CameraManager: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    
    private var photoCaptureCompletion: ((UIImage?) -> Void)?

    func configure() {
        session.beginConfiguration()
        
        // Add video input (camera)
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            print("Failed to create camera input")
            session.commitConfiguration()
            return
        }
        session.addInput(input)
        
        // Add photo output
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        
        session.commitConfiguration()
        session.startRunning()
    }

    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        let settings = AVCapturePhotoSettings()
        self.photoCaptureCompletion = completion
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else {
            photoCaptureCompletion?(nil)
            return
        }
        photoCaptureCompletion?(image)
    }

    func setZoomFactor(_ zoomFactor: CGFloat) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        do {
            try device.lockForConfiguration()
            let factor = min(max(zoomFactor, device.minAvailableVideoZoomFactor), device.maxAvailableVideoZoomFactor)
            device.videoZoomFactor = factor
            device.unlockForConfiguration()
        } catch {
            print("Failed to set zoom factor: \(error)")
        }
    }
}
