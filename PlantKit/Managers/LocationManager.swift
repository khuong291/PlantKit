//
//  LocationManager.swift
//  PlantKit
//
//  Created by Khuong Pham on 6/6/25.
//

import Foundation
import CoreLocation
import WeatherKit
import Combine
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let weatherService = WeatherService.shared
    private var cancellables = Set<AnyCancellable>()

    @Published var city: String?
    @Published var temperature: Double?
    @Published var weatherIcon: String = "cloud"
    @Published var isLoadingWeather = false

    private var hasRequestedLocation = false
    private var lastKnownLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        // Observe scene lifecycle
        setupSceneLifecycleObserver()
    }
    
    private func setupSceneLifecycleObserver() {
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.refreshWeatherIfNeeded()
            }
            .store(in: &cancellables)
    }
    
    private func refreshWeatherIfNeeded() {
        // If we have a location, refresh weather
        if let location = lastKnownLocation {
            fetchWeather(for: location)
        } else if hasRequestedLocation {
            // If we've already requested location but don't have it yet, request again
            requestLocation()
        }
    }

    func requestLocation() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
        default:
            print("Location permission denied.")
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if [.authorizedAlways, .authorizedWhenInUse].contains(manager.authorizationStatus) && !hasRequestedLocation {
            hasRequestedLocation = true
            locationManager.requestLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        lastKnownLocation = location
        fetchCity(from: location)
        fetchWeather(for: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error:", error.localizedDescription)
    }

    private func fetchCity(from location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
            self.city = placemarks?.first?.locality
        }
    }

    private func fetchWeather(for location: CLLocation) {
        isLoadingWeather = true
        
        Task {
            do {
                let weather = try await weatherService.weather(for: location)
                await MainActor.run {
                    temperature = weather.currentWeather.temperature.value
                    weatherIcon = weather.currentWeather.symbolName
                    isLoadingWeather = false
                }
            } catch {
                await MainActor.run {
                    isLoadingWeather = false
                }
                print("WeatherKit error:", error.localizedDescription)
            }
        }
    }
}
