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
        case diagnose
        case myPlants
        case settings
        
        var title: String {
            switch self {
            case .home:
                return "Home"
            case .diagnose:
                return "Diagnose"
            case .myPlants:
                return "My Plants"
            case .settings:
                return "Settings"
            }
        }
        
        var image: String {
            switch self {
            case .home:
                return "ic-home"
            case .diagnose:
                return "ic-diagnose"
            case .myPlants:
                return "ic-my-plants"
            case .settings:
                return "ic-settings"
            }
        }
        
        var size: CGFloat {
            switch self {
            case .home:
                return 24
            case .diagnose:
                return 26
            case .myPlants:
                return 24
            case .settings:
                return 26
            }
        }
    }
    
    @EnvironmentObject private var identifierManager: IdentifierManager
    @StateObject private var viewModel = MainTabViewModel()
    @StateObject private var homeRouter = Router<ContentRoute>()
    @StateObject private var diagnoseRouter = Router<ContentRoute>()
    @StateObject private var myPlantsRouter = Router<ContentRoute>()
    @StateObject private var settingsRouter = Router<ContentRoute>()
    
    @State private var selectedTab: Tab = .home
    @State private var hasSelectedHomeScreen = false
    @State private var hasSelectedDiagnoseScreen = false
    @State private var hasSelectedMyPlantsScreen = false
    @State private var hasSelectedSettingsScreen = false
    
    private let homeScreen = HomeScreen()
    private let diagnoseScreen = DiagnoseScreen()
    private let myPlantsScreen = MyPlantsScreen()
    private let settingsScreen = SettingsScreen()
    
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
            hasSelectedHomeScreen = true
            selectedTab = .home
        }
        .fullScreenCover(isPresented: $viewModel.isPresentingCamera) {
            CameraView(dismissAction: viewModel.closeCamera, selectedTab: $selectedTab)
                .environmentObject(viewModel.cameraManager)
                .environmentObject(identifierManager)
        }
    }
    
    private var tabContent: some View {
        ZStack {
            if hasSelectedHomeScreen {
                RoutingView(stack: $homeRouter.stack) {
                    homeScreen
                }
                .opacity(selectedTab == .home ? 1 : 0)
                .environmentObject(homeRouter)
            }
            if hasSelectedDiagnoseScreen {
                RoutingView(stack: $diagnoseRouter.stack) {
                    diagnoseScreen
                }
                .opacity(selectedTab == .diagnose ? 1 : 0)
                .environmentObject(diagnoseRouter)
            }
            if hasSelectedMyPlantsScreen {
                RoutingView(stack: $myPlantsRouter.stack) {
                    myPlantsScreen.id(identifierManager.myPlantsScreenID)
                }
                .opacity(selectedTab == .myPlants ? 1 : 0)
                .environmentObject(myPlantsRouter)
            }
            if hasSelectedSettingsScreen {
                RoutingView(stack: $settingsRouter.stack) {
                    settingsScreen
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
            tabItem(tab: .diagnose)
            Spacer()
                .frame(width: 80)
            tabItem(tab: .myPlants)
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
            cameraButton
                .offset(y: -10)
        }
    }
    
    private var cameraButton: some View {
        Button {
            Haptics.shared.play()
            viewModel.openCamera()
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
            if tab == .home && !hasSelectedHomeScreen {
                hasSelectedHomeScreen = true
            } else if tab == .diagnose && !hasSelectedDiagnoseScreen {
                hasSelectedDiagnoseScreen = true
            } else if tab == .myPlants && !hasSelectedMyPlantsScreen {
                hasSelectedMyPlantsScreen = true
            } else if tab == .settings && !hasSelectedSettingsScreen {
                hasSelectedSettingsScreen = true
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
