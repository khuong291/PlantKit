//
//  PlantKitApp.swift
//  PlantKit
//
//  Created by Khuong Pham on 30/5/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Setup ProManager
        ProManager.shared.setup()
        
        return true
    }
}

@main
struct PlantKitApp: App {
    let persistenceController = CoreDataManager.shared
    
    @StateObject var cameraManager = CameraManager()
    @StateObject var identifierManager = IdentifierManager()
    @StateObject var conversationManager = ConversationManager()
    @StateObject var proManager = ProManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.viewContext)
                .environmentObject(cameraManager)
                .environmentObject(identifierManager)
                .environmentObject(conversationManager)
                .environmentObject(proManager)
        }
    }
}
