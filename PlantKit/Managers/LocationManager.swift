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

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let weatherService = WeatherService.shared

    @Published var city: String?
    @Published var temperature: Double?
    @Published var weatherIcon: String = "cloud"

    private var hasRequestedLocation = false

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
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
        Task {
            do {
                let weather = try await weatherService.weather(for: location)
                await MainActor.run {
                    temperature = weather.currentWeather.temperature.value
                    weatherIcon = weather.currentWeather.symbolName
                }
            } catch {
                print("WeatherKit error:", error.localizedDescription)
            }
        }
    }
}
