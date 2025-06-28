//
//  CameraManager.swift
//  PlantKit
//
//  Created by Khuong Pham on 3/6/25.
//

import AVFoundation
import SwiftUI

class CameraManager: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    private var session: AVCaptureSession?
    private var photoOutput: AVCapturePhotoOutput?
    private let sessionQueue = DispatchQueue(label: "cameraSessionQueue")
    
    @Published var isSessionReady = false
    
    private var photoCaptureCompletion: ((UIImage?) -> Void)?

    var captureSession: AVCaptureSession {
        if session == nil {
            session = AVCaptureSession()
        }
        return session!
    }

    func configure() {
        print("CameraManager: Configuring camera session...")
        
        // Stop and clean up existing session if it exists
        if let existingSession = session, existingSession.isRunning {
            print("CameraManager: Stopping existing session")
            sessionQueue.async {
                existingSession.stopRunning()
            }
        }
        
        sessionQueue.async {
            self.setupCaptureSession()
        }
    }
    
    private func setupCaptureSession() {
        print("CameraManager: Setting up capture session...")
        
        // Reset ready state
        DispatchQueue.main.async {
            self.isSessionReady = false
        }
        
        // Create new session
        let newSession = AVCaptureSession()
        newSession.beginConfiguration()
        
        // Add video input (camera)
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              newSession.canAddInput(input) else {
            print("CameraManager: Failed to create camera input")
            newSession.commitConfiguration()
            return
        }
        newSession.addInput(input)
        print("CameraManager: Camera input added successfully")
        
        // Create new photo output for this session
        let newPhotoOutput = AVCapturePhotoOutput()
        if newSession.canAddOutput(newPhotoOutput) {
            newSession.addOutput(newPhotoOutput)
            self.photoOutput = newPhotoOutput
            print("CameraManager: Photo output added successfully")
        } else {
            print("CameraManager: Cannot add photo output")
            newSession.commitConfiguration()
            return
        }
        
        newSession.commitConfiguration()
        
        // Store the new session
        self.session = newSession
        
        // Start the session on background queue
        newSession.startRunning()
        print("CameraManager: Capture session started successfully")
        
        // Mark session as ready immediately after starting
        DispatchQueue.main.async {
            self.isSessionReady = true
            print("CameraManager: Session marked as ready")
        }
    }

    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        guard let session = session, session.isRunning else {
            print("CameraManager: Cannot capture photo - session not running")
            completion(nil)
            return
        }
        
        let settings = AVCapturePhotoSettings()
        self.photoCaptureCompletion = completion
        photoOutput?.capturePhoto(with: settings, delegate: self)
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
    
    func stopSession() {
        sessionQueue.async {
            print("CameraManager: Stopping camera session...")
            self.session?.stopRunning()
            self.session = nil
            self.photoOutput = nil
            print("CameraManager: Camera session stopped")
        }
    }
    
    func reset() {
        print("CameraManager: Resetting camera manager...")
        stopSession()
        session = nil
        
        DispatchQueue.main.async {
            self.isSessionReady = false
        }
    }
}
