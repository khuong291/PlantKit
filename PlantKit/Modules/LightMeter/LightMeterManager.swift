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

class LightMeterManager: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var lightLevel: LightLevel = .dark
    @Published var luxValue: Double = 0.0

    private var captureSession: AVCaptureSession?
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")

    override init() {
        super.init()
        setupCaptureSession()
    }

    private func setupCaptureSession() {
        sessionQueue.async {
            self.captureSession = AVCaptureSession()
            guard let session = self.captureSession else { return }

            session.beginConfiguration()

            guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice),
                  session.canAddInput(videoDeviceInput) else {
                print("Failed to get camera device.")
                return
            }

            session.addInput(videoDeviceInput)

            if session.canAddOutput(self.videoOutput) {
                self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
                session.addOutput(self.videoOutput)
            }

            session.commitConfiguration()
        }
    }

    func start() {
        sessionQueue.async {
            if self.captureSession?.isRunning == false {
                self.captureSession?.startRunning()
            }
        }
    }

    func stop() {
        sessionQueue.async {
            if self.captureSession?.isRunning == true {
                self.captureSession?.stopRunning()
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