//
//  OnboardingLocationPermissionStepView.swift
//  PlantKit
//
//  Created by Khuong Pham on 27/6/25.
//

import SwiftUI
import CoreLocation

struct OnboardingLocationPermissionStepView: View {
    @State private var locationAuthorized = false
    @State private var showPermissionAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(alignment: .center, spacing: 8) {
                    Text("Help us personalize your experience")
                        .font(.system(size: 34)).bold()
                        .padding(.top, 20)
                        .multilineTextAlignment(.center)
                    Text("Location helps us provide better plant care recommendations based on your climate and growing conditions.")
                        .font(.system(size: 17))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 24)
                
                Spacer()
                
                VStack(spacing: 32) {
                    // Location benefits
                    VStack(spacing: 20) {
                        locationBenefitRow(
                            icon: "thermometer",
                            title: "Climate-based care",
                            description: "Get watering and care tips tailored to your local weather"
                        )
                        
                        locationBenefitRow(
                            icon: "sun.max",
                            title: "Seasonal guidance",
                            description: "Receive recommendations based on your growing season"
                        )
                        
                        locationBenefitRow(
                            icon: "leaf",
                            title: "Local plant suggestions",
                            description: "Discover plants that thrive in your area"
                        )
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea(edges: .top)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 32)
        }
        .onAppear {
            checkLocationPermission()
        }
        .alert(isPresented: $showPermissionAlert) {
            Alert(
                title: Text("Location Access Needed"),
                message: Text("Location helps us provide better plant care recommendations. You can change this later in Settings."),
                primaryButton: .default(Text("Open Settings")) {
                    openSettings()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func locationBenefitRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(.green)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17))
                    .foregroundColor(.primary)
                
                Text(description)
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func checkLocationPermission() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse, .authorizedAlways:
            locationAuthorized = true
        case .notDetermined:
            requestLocationPermission()
        default:
            locationAuthorized = false
        }
    }
    
    private func requestLocationPermission() {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
    }
    
    private func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl)
        }
    }
}

#Preview {
    OnboardingLocationPermissionStepView()
        .preferredColorScheme(.dark)
} 
