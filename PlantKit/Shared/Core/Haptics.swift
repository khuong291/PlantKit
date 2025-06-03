//
//  Haptics.swift
//  PlantKit
//
//  Created by Khuong Pham on 3/6/25.
//

import UIKit

class Haptics {
    static let shared = Haptics()
    
    private init() { }

    func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle = .soft) {
//        let hapticFeedbackEnable = UserDefaults.standard.bool(forKey: "hapticFeedbackEnable")
//        if hapticFeedbackEnable {
            UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
//        }
    }
    
    func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
//        let hapticFeedbackEnable = UserDefaults.standard.bool(forKey: "hapticFeedbackEnable")
//        if hapticFeedbackEnable {
            UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
//        }
    }
}
