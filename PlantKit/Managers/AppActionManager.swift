//
//  AppActionManager.swift
//  PlantKit
//
//  Created by Khuong Pham on 19/6/25.
//

import Foundation

#if os(OSX)
import AppKit
#endif

@MainActor
final class AppActionManager {
    public static let shared = AppActionManager()

    #if os(OSX)
    var window: NSWindow?
    #endif

    func openAbout() {
        if let url = URL(string: App.websiteUrl) {
            open(url: url)
        }
    }

    func showShareWebsite() {
        guard let url = URL(string: App.websiteUrl) else { return }
        showShare(item: url)
    }

    func openMacWebsite() {
        if let url = URL(string: App.macUrl) {
            open(url: url)
        }
    }

    func openTwitter() {
        if let url = URL(string: App.twitterUrl) {
            open(url: url)
        }
    }

    func openReviewOnAppstore() {
        let string: String
        #if canImport(AppKit)
        string = "macappstore://apps.apple.com/app/\(App.id)?action=write-review"
        #else
        string = "itms-apps://itunes.apple.com/app/\(App.id)?action=write-review"
        #endif

        guard let url = URL(string: string) else { return }
        open(url: url)
    }
}

private struct App {
    static var name = "PlantKit - Plant Identifier"
    static var id = "id6746693209"
    static var websiteUrl = "https://www.plantkit.app/"
    static var twitterUrl = "https://x.com/PlantKitApp"
    static var macUrl = "https://www.plantkit.app/"
    static var termsUrl = "https://www.plantkit.app/terms"
    static var privacyPolicyUrl = "https://www.plantkit.app/privacy"
    static var appIcon = "ProIcon"
}

#if os(iOS)

import UIKit

extension AppActionManager {
    func open(url: URL) {
        UIApplication.shared.open(url)
    }

    func showShare(item: Any) {
        guard
            let rootVC = UIApplication.shared.windows
                .first(where: { $0.isKeyWindow })?
                .rootViewController
        else { return }

        let vc = UIActivityViewController(
            activityItems: [item],
            applicationActivities: nil
        )
        vc.title = App.name

        // Fix for iPad
        if UIDevice.current.userInterfaceIdiom == .pad {
            vc.modalPresentationStyle = .formSheet
            vc.popoverPresentationController?.sourceView = rootVC.view
            vc.popoverPresentationController?.sourceRect = CGRect(
                x: rootVC.view.frame.maxX,
                y: rootVC.view.frame.maxY,
                width: 0,
                height: 0
            )
        }

        rootVC.present(vc, animated: true)
    }

    func toggleSidebar() {
        
    }
}

#endif

#if os(OSX)

import AppKit
import SwiftUI

public extension AppActionManager {
    func quit() {
        NSApp.terminate(self)
    }

    func open(url: URL) {
        NSWorkspace.shared.open(url)
    }

    func showShare(item: Any) {
        // No op
    }

    func showWindow<V: View>(view: V) {
        if window != nil {
            window?.close()
            self.window = nil
        }

        let window = NSWindow(
            contentViewController: NSHostingController(
                rootView: view
                    .frame(minWidth: 500, minHeight: 700)
            )
        )
        window.level = .floating
        window.title = Config.app.name
        window.titlebarAppearsTransparent = true
        window.makeKeyAndOrderFront(nil)
        window.orderFrontRegardless()
        self.window = window
    }

    func close() {
        window?.close()
        self.window = nil
    }

    func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?
            .tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}

#endif

