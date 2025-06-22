//
//  LightMeterManager.swift
//  PlantKit
//
//  Created by Khuong Pham on 14/6/24.
//

import Foundation
import AVFoundation
import UIKit
import Combine

enum LightLevel: String {
    case dark = "Dark"
    case veryLow = "Very Low Light"
    case low = "Low Light"
    case medium = "Medium Light"
    case bright = "Bright Indirect Light"
    case veryBright = "Full Sun"
}

enum CameraSetupState: Equatable {
    case notConfigured
    case configuring
    case configured
    case failed(String)
    
    static func == (lhs: CameraSetupState, rhs: CameraSetupState) -> Bool {
        switch (lhs, rhs) {
        case (.notConfigured, .notConfigured),
             (.configuring, .configuring),
             (.configured, .configured):
            return true
        case (.failed(let lhsError), .failed(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}

class LightMeterManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var lightLevel: LightLevel = .dark
    @Published var luxValue: Double = 0.0
    @Published var setupState: CameraSetupState = .notConfigured

    private var captureSession: AVCaptureSession?
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private var isConfigured = false

    override init() {
        super.init()
        // Don't auto-configure on init, let the view trigger it
        
        // Add notification observers for session interruptions
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sessionWasInterrupted),
            name: .AVCaptureSessionWasInterrupted,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(sessionInterruptionEnded),
            name: .AVCaptureSessionInterruptionEnded,
            object: nil
        )
    }

    @objc private func sessionWasInterrupted(notification: NSNotification) {
        print("LightMeterManager: Session was interrupted")
    }
    
    @objc private func sessionInterruptionEnded(notification: NSNotification) {
        print("LightMeterManager: Session interruption ended")
    }

    func configure() {
        print("LightMeterManager: Configure called with current state: \(setupState)")
        
        // If already configured and session is running, stop it first
        if case .configured = setupState, let session = captureSession, session.isRunning {
            print("LightMeterManager: Stopping existing session before reconfiguring")
            sessionQueue.async {
                session.stopRunning()
            }
        }
        
        // Allow reconfiguration if failed or not configured
        switch setupState {
        case .failed, .notConfigured:
            DispatchQueue.main.async {
                self.setupState = .configuring
            }
            
            sessionQueue.async {
                self.setupCaptureSession()
            }
        case .configuring:
            print("LightMeterManager: Already configuring, ignoring")
        case .configured:
            print("LightMeterManager: Already configured, reconfiguring")
            DispatchQueue.main.async {
                self.setupState = .configuring
            }
            
            sessionQueue.async {
                self.setupCaptureSession()
            }
        }
    }

    private func setupCaptureSession() {
        // Check camera authorization first
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.createCaptureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.createCaptureSession()
                } else {
                    DispatchQueue.main.async {
                        self.setupState = .failed("Camera access denied")
                    }
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.setupState = .failed("Camera access denied")
            }
        @unknown default:
            DispatchQueue.main.async {
                self.setupState = .failed("Unknown camera authorization status")
            }
        }
    }
    
    private func createCaptureSession() {
        print("LightMeterManager: Creating capture session...")
        
        // Clean up existing session if any
        if let existingSession = captureSession {
            print("LightMeterManager: Cleaning up existing session")
            if existingSession.isRunning {
                existingSession.stopRunning()
            }
            captureSession = nil
        }
        
        let session = AVCaptureSession()
        
        // Set session quality
        session.sessionPreset = .high
        
        session.beginConfiguration()

        // Get camera device
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("LightMeterManager: No camera device available")
            DispatchQueue.main.async {
                self.setupState = .failed("No camera device available")
            }
            return
        }
        
        print("LightMeterManager: Camera device found: \(videoDevice.localizedName)")
        
        // Create input
        do {
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            guard session.canAddInput(videoDeviceInput) else {
                print("LightMeterManager: Cannot add camera input")
                DispatchQueue.main.async {
                    self.setupState = .failed("Cannot add camera input")
                }
                return
            }
            session.addInput(videoDeviceInput)
            print("LightMeterManager: Camera input added successfully")
        } catch {
            print("LightMeterManager: Failed to create camera input: \(error)")
            DispatchQueue.main.async {
                self.setupState = .failed("Failed to create camera input: \(error.localizedDescription)")
            }
            return
        }

        // Add video output for light metering
        if session.canAddOutput(self.videoOutput) {
            self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            session.addOutput(self.videoOutput)
            print("LightMeterManager: Video output added successfully")
        } else {
            print("LightMeterManager: Cannot add video output")
            DispatchQueue.main.async {
                self.setupState = .failed("Cannot add video output")
            }
            return
        }

        session.commitConfiguration()
        
        // Store session and update state
        self.captureSession = session
        self.isConfigured = true
        
        print("LightMeterManager: Capture session configured successfully")
        print("LightMeterManager: Session inputs: \(session.inputs.count), outputs: \(session.outputs.count)")
        
        DispatchQueue.main.async {
            self.setupState = .configured
        }
    }

    func start() {
        guard isConfigured, setupState == .configured else { 
            print("LightMeterManager: Cannot start - not configured or setup failed")
            return 
        }
        
        print("LightMeterManager: Starting capture session...")
        sessionQueue.async {
            if let session = self.captureSession {
                if session.isRunning {
                    print("LightMeterManager: Capture session already running")
                } else {
                    session.startRunning()
                    print("LightMeterManager: Capture session started successfully")
                }
            } else {
                print("LightMeterManager: Capture session not available")
            }
        }
    }

    func stop() {
        print("LightMeterManager: Stopping capture session...")
        sessionQueue.async {
            if let session = self.captureSession, session.isRunning {
                session.stopRunning()
                print("LightMeterManager: Capture session stopped")
            } else {
                print("LightMeterManager: Capture session not running")
            }
        }
        
        // Reset state after stopping
        DispatchQueue.main.async {
            self.setupState = .notConfigured
            self.isConfigured = false
        }
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        print("LightMeterManager: Received video frame")
        
        guard let metadata = CMCopyDictionaryOfAttachments(allocator: nil, target: sampleBuffer, attachmentMode: kCMAttachmentMode_ShouldPropagate) as? [String: Any],
              let exifMetadata = metadata[kCGImagePropertyExifDictionary as String] as? [String: Any],
              let brightnessValue = exifMetadata[kCGImagePropertyExifBrightnessValue as String] as? Double else {
            print("LightMeterManager: Could not extract brightness data from frame")
            return
        }

        // The brightness value is not directly lux, but we can use it to estimate light levels.
        // This conversion is a simplified estimation.
        let estimatedLux = exp(brightnessValue) * 100 // Example conversion
        
        DispatchQueue.main.async {
            self.luxValue = estimatedLux
            self.updateLightLevel(basedOn: estimatedLux)
        }
    }
    
    private func updateLightLevel(basedOn lux: Double) {
        if lux < 50 {
            lightLevel = .dark
        } else if lux < 100 {
            lightLevel = .veryLow
        } else if lux < 300 {
            lightLevel = .low
        } else if lux < 1000 {
            lightLevel = .medium
        } else if lux < 5000 {
            lightLevel = .bright
        } else {
            lightLevel = .veryBright
        }
    }

    func reset() {
        print("LightMeterManager: Resetting...")
        sessionQueue.async {
            if let session = self.captureSession, session.isRunning {
                session.stopRunning()
            }
            self.captureSession = nil
            self.isConfigured = false
        }
        
        DispatchQueue.main.async {
            self.setupState = .notConfigured
            self.lightLevel = .dark
            self.luxValue = 0.0
        }
    }
}

extension LightMeterManager {
    func getCaptureSession() -> AVCaptureSession? {
        let session = self.captureSession
        print("LightMeterManager: getCaptureSession called - session available: \(session != nil), isRunning: \(session?.isRunning ?? false)")
        
        if let session = session {
            print("LightMeterManager: Session inputs: \(session.inputs.count), outputs: \(session.outputs.count)")
            print("LightMeterManager: Session preset: \(session.sessionPreset.rawValue)")
            print("LightMeterManager: Session isInterrupted: \(session.isInterrupted)")
        }
        
        return session
    }
    
    func isSessionReady() -> Bool {
        return isConfigured && setupState == .configured && captureSession != nil
    }
} 