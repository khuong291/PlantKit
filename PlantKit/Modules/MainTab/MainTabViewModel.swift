//
//  MainTabViewModel.swift
//  PlantKit
//
//  Created by Khuong Pham on 3/6/25.
//

import SwiftUI
import AVFoundation

final class MainTabViewModel: ObservableObject {
    @Published var isPresentingCamera = false
    @Published var cameraManager = CameraManager()

    func openCamera() {
        Haptics.shared.play()
        isPresentingCamera = true
    }

    func closeCamera() {
        isPresentingCamera = false
    }
}
