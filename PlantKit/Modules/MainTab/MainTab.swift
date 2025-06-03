//
//  MainTab.swift
//  PlantKit
//
//  Created by Khuong Pham on 3/6/25.
//

import SwiftUI
import ReuseAcross

struct MainTab: View {
    enum Tab: Int {
        case home
        case overview
        case journal
        case settings
        
        var title: String {
            switch self {
            case .home:
                return "Home"
            case .overview:
                return "Diagnose"
            case .journal:
                return "My Plants"
            case .settings:
                return "Settings"
            }
        }
        
        var image: String {
            switch self {
            case .home:
                return "ic-home"
            case .overview:
                return "ic-diagnose"
            case .journal:
                return "ic-my-plants"
            case .settings:
                return "ic-settings"
            }
        }
        
        var size: CGFloat {
            switch self {
            case .home:
                return 24
            case .overview:
                return 26
            case .journal:
                return 24
            case .settings:
                return 26
            }
        }
    }
    
    @StateObject private var homeRouter = Router<ContentRoute>()
    @StateObject private var overviewRouter = Router<ContentRoute>()
    @StateObject private var journalRouter = Router<ContentRoute>()
    @StateObject private var settingsRouter = Router<ContentRoute>()
    
    @State private var selectedTab: Tab = .home
    @State private var hasSelectedHomeView = false
    @State private var hasSelectedOverviewView = false
    @State private var hasSelectedJournalView = false
    @State private var hasSelectedSettingsView = false
    
    private let homeScreen =  HomeScreen()
    
    private var paddingBottom: Double {
        #if targetEnvironment(macCatalyst)
        return 12
        #else
        return 0
        #endif
    }
    
    var body: some View {
        ZStack {
            tabContent
            VStack(spacing: 0) {
                Spacer()
                tabItems
            }
        }
        .onAppear {
            hasSelectedHomeView = true
            selectedTab = .home
        }
    }
    
    private var tabContent: some View {
        ZStack {
            if hasSelectedHomeView {
                RoutingView(stack: $homeRouter.stack) {
                    homeScreen
                }
                .opacity(selectedTab == .home ? 1 : 0)
                .environmentObject(homeRouter)
            }
            if hasSelectedOverviewView {
                RoutingView(stack: $overviewRouter.stack) {
                    homeScreen
                }
                .opacity(selectedTab == .overview ? 1 : 0)
                .environmentObject(overviewRouter)
            }
            if hasSelectedJournalView {
                RoutingView(stack: $journalRouter.stack) {
                    homeScreen
                }
                .opacity(selectedTab == .journal ? 1 : 0)
                .environmentObject(journalRouter)
            }
            if hasSelectedSettingsView {
                RoutingView(stack: $settingsRouter.stack) {
                    homeScreen
                }
                .opacity(selectedTab == .settings ? 1 : 0)
                .environmentObject(settingsRouter)
            }
        }
    }
    
    private var tabItems: some View {
        HStack(spacing: 0) {
            Spacer()
                .frame(width: 10)
            tabItem(tab: .home)
            tabItem(tab: .overview)
            Spacer()
                .frame(width: 100)
            tabItem(tab: .journal)
            tabItem(tab: .settings)
            Spacer()
                .frame(width: 10)
        }
        .font(.system(size: 11))
        .background(Color.white)
//        .overlay(alignment: .top) {
//            Rectangle()
//                .fill(Color.gray.opacity(0.2))
//                .frame(height: 0.5)
//        }
        .overlay(alignment: .top) {
            alarmButton
                .offset(y: -10)
        }
    }
    
    private var alarmButton: some View {
        Button {
            Haptics.shared.play()
            // Perform your alarm action here
        } label: {
            ZStack {
                Circle()
                    .fill(Color.green)
                    .frame(width: 64, height: 64)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 7)
                    )

                Image("ic-camera")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundColor(Color.white)
            }
        }
        .buttonStyle(CardButtonStyle())
    }
    
    private func tabItem(tab: Tab) -> some View {
        Button {
            selectedTab = tab
            if tab == .home && !hasSelectedHomeView {
                hasSelectedHomeView = true
            } else if tab == .overview && !hasSelectedOverviewView {
                hasSelectedOverviewView = true
            } else if tab == .journal && !hasSelectedJournalView {
                hasSelectedJournalView = true
            } else if tab == .settings && !hasSelectedSettingsView {
                hasSelectedSettingsView = true
            }
            Haptics.shared.play()
        } label: {
            HStack {
                Spacer()
                VStack(spacing: 4) {
                    Image(tab.image)
                        .resizable()
                        .scaledToFit()
                        .frame(square: tab.size)
                        .frame(square: 24)
                        .foregroundColor(selectedTab == tab ? .green : .systemGray2)
                    Text(tab.title)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(selectedTab == tab ? .green : .systemGray2)
                        .lineLimit(1)
                }
                Spacer()
            }
            .padding(.top, 12)
            .padding(.bottom, paddingBottom)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(CardButtonStyle())
    }
}
