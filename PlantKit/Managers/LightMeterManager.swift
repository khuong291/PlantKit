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
    }

    func configure() {
        guard setupState == .notConfigured else { return }
        
        DispatchQueue.main.async {
            self.setupState = .configuring
        }
        
        sessionQueue.async {
            self.setupCaptureSession()
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

        // Add video output
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
            if self.captureSession?.isRunning == false {
                self.captureSession?.startRunning()
                print("LightMeterManager: Capture session started")
            } else {
                print("LightMeterManager: Capture session already running")
            }
        }
    }

    func stop() {
        print("LightMeterManager: Stopping capture session...")
        sessionQueue.async {
            if self.captureSession?.isRunning == true {
                self.captureSession?.stopRunning()
                print("LightMeterManager: Capture session stopped")
            } else {
                print("LightMeterManager: Capture session not running")
            }
        }
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let metadata = CMCopyDictionaryOfAttachments(allocator: nil, target: sampleBuffer, attachmentMode: kCMAttachmentMode_ShouldPropagate) as? [String: Any],
              let exifMetadata = metadata[kCGImagePropertyExifDictionary as String] as? [String: Any],
              let brightnessValue = exifMetadata[kCGImagePropertyExifBrightnessValue as String] as? Double else {
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
}

extension LightMeterManager {
    func getCaptureSession() -> AVCaptureSession? {
        return self.captureSession
    }
} 