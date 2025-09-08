//
//  PlantKitApp.swift
//  PlantKit
//
//  Created by Khuong Pham on 30/5/25.
//

import SwiftUI
import FirebaseCore
import UserNotifications
import Mixpanel

// Global flag to track Mixpanel initialization
class MixpanelManager {
    static let shared = MixpanelManager()
    private var isInitialized = false
    
    private init() {}
    
    func initialize(token: String, trackAutomaticEvents: Bool) {
        Mixpanel.initialize(token: token, trackAutomaticEvents: trackAutomaticEvents)
        isInitialized = true
    }
    
    func track(event: String, properties: [String: Any] = [:]) {
        guard isInitialized else {
            print("Mixpanel not initialized, skipping event: \(event)")
            return
        }
        Mixpanel.mainInstance().track(event: event, properties: [:])
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Setup ProManager
        ProManager.shared.setup()
        
        // Setup notification delegate
        UNUserNotificationCenter.current().delegate = self
        
        MixpanelManager.shared.initialize(token: "c524cc1d2aec80e590e53342dd080151", trackAutomaticEvents: false)
        
        // Track app installation event
        let didInstall = UserDefaults.standard.bool(forKey: "didInstall")
        if !didInstall {
            UserDefaults.standard.set(true, forKey: "didInstall")
            let countryCode = Locale.current.region?.identifier ?? "Unknown"
            MixpanelManager.shared.track(event:"Installed", properties: [
                "country": countryCode,
            ])
        }
        
        // Setup CareReminderManager and request notification permissions
        // Note: We'll request permissions when user actually uses reminder features
        // to avoid asking too early in the app lifecycle
        
        return true
    }
    
    // Handle notification actions when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                               willPresent notification: UNNotification, 
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle notification actions when user taps on notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                               didReceive response: UNNotificationResponse, 
                               withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.actionIdentifier
        let notificationId = response.notification.request.identifier
        
        // Handle custom actions
        if identifier == "MARK_COMPLETED" || identifier == "SNOOZE_1_HOUR" || identifier == "SNOOZE_TOMORROW" {
            CareReminderManager.shared.handleNotificationAction(identifier: identifier, for: notificationId)
        }
        
        completionHandler()
    }
}

@main
struct PlantKitApp: App {
    let persistenceController = CoreDataManager.shared
    
    @StateObject var cameraManager = CameraManager()
    @StateObject var identifierManager = IdentifierManager()
    @StateObject var conversationManager = ConversationManager()
    @StateObject var proManager = ProManager.shared
    @StateObject var locationManager = LocationManager()
    @StateObject var careReminderManager = CareReminderManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
                .environmentObject(cameraManager)
                .environmentObject(identifierManager)
                .environmentObject(conversationManager)
                .environmentObject(proManager)
                .environmentObject(locationManager)
                .environmentObject(careReminderManager)
        }
    }
}
