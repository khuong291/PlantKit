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
        
        return true
    }
}

@main
struct PlantKitApp: App {
    let persistenceController = PersistenceController.shared
    
    @StateObject var cameraManager = CameraManager()
    @StateObject var identifierManager = IdentifierManager()
    @StateObject var conversationManager = ConversationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(cameraManager)
                .environmentObject(identifierManager)
                .environmentObject(conversationManager)
        }
    }
}
