//
//  PopupManager.swift
//  PlantKit
//
//  Created by Khuong Pham on 19/6/25.
//

import SwiftUI

enum PopupMessage {
    case warning(String, String)
    case success(String, String)
    case error(String, String)
    case custom(String, String, String, Bool)
    
    var color: Color {
        switch self {
        case .warning:
            return .systemOrange
        case .success:
            return .systemGreen
        case .error:
            return .systemRed
        case .custom:
            return .clear
        }
    }
    
    var title: String {
        switch self {
        case .warning(let message, _):
            return message
        case .success(let message, _):
            return message
        case .error(let message, _):
            return message
        case .custom(let message, _, _, _):
            return message
        }
    }
    
    var message: String {
        switch self {
        case .warning(_, let message):
            return message
        case .success(_, let message):
            return message
        case .error(_, let message):
            return message
        case .custom(_, let message, _, _):
            return message
        }
    }
    
    var icon: String {
        switch self {
        case .warning:
            return "ic-warning"
        case .success:
            return "ic-success"
        case .error:
            return "ic-error"
        case .custom(_, _, let icon, _):
            return icon
        }
    }
    
    var showShare: Bool {
        switch self {
        case .custom(_, _, _, let showShare):
            return showShare
        default:
            return false
        }
    }
}

class PopupManager: ObservableObject {
    static let shared = PopupManager()
    
    @AppStorage("inAppNotification") var inAppNotification = true
    
    @Published var showNewHabitScreen = false
    @Published var showMessagePopup = false
    @Published var popupMessage: PopupMessage = .warning("", "")
    @Published var showCalendarPopup = false
    @Published var showTrackHabitTimeFromMainScreenPopup = false
    @Published var showTrackHabitCountFromMainScreenPopup = false
    @Published var showTrackHabitTimeFromCalendarPopup = false
    @Published var showTrackHabitCountFromCalendarPopup = false
    @Published var showQuoteSettings = false
    @Published var showWidgetSettings = false
    @Published var showMailView = false
    @Published var showAppleHealthView = false
    @Published var showDiscountView = false
    @Published var showWhatsNewPopupLocal = false
    @Published var showPaywall = false
    @Published var showAskForRatingAlert = false
    @Published var showAddJournalPopup = false
    @Published var showRewardPieceFoundPopup = false
    @Published var showRewardGuidelinePopup = false
    @Published var showAchievementPopup = false
    @Published var showUnlockAchievementPopup = false
    
    func showPopup(message: PopupMessage) {
        if inAppNotification {
            popupMessage = message
            showMessagePopup = true
        }
    }
}

