//
//  WaterMeterView.swift
//  PlantKit
//
//  Created by Khuong Pham on 14/6/24.
//

import SwiftUI

enum PlantLocation {
    case outdoor, indoor
}

enum TemperatureUnit: String {
    case celsius = "C"
    case fahrenheit = "F"
}

enum PotDiameterUnit: String {
    case cm, inch
}

enum ResultUnit: String {
    case ml, oz
}

struct WaterMeterView: View {
    @StateObject private var viewModel = WaterMeterViewModel()
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            Capsule()
                .fill(Color.secondary)
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            // Step content
            VStack {
                switch viewModel.currentStep {
                case .location:
                    LocationStepView(viewModel: viewModel)
                case .humidity:
                    HumidityStepView(viewModel: viewModel)
                case .temperature:
                    TemperatureStepView(viewModel: viewModel)
                case .potSize:
                    PotDiameterStepView(viewModel: viewModel)
                case .result:
                    ResultStepView(viewModel: viewModel)
                }

                Spacer()

                // Navigation
                HStack {
                    if viewModel.currentStep != .location {
                        Button("Back") {
                            withAnimation {
                                viewModel.previousStep()
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }

                    Button(viewModel.currentStep == .result ? "OK" : "Continue") {
                        if viewModel.currentStep == .result {
                            isPresented = false
                        } else {
                            withAnimation {
                                viewModel.nextStep()
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled(!viewModel.isCurrentStepValid())
                }
                .padding()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
        .presentationDetents([.medium, .large])
    }
}

class WaterMeterViewModel: ObservableObject {
    enum Step {
        case location, humidity, temperature, potSize, result
    }

    @Published var currentStep: Step = .location
    @Published var plantLocation: PlantLocation?
    @Published var humidity: Double = 50
    @Published var humidityDontKnow: Bool = false
    @Published var temperature: Double = 20
    @Published var temperatureUnit: TemperatureUnit = .celsius
    @Published var temperatureDontKnow: Bool = false
    @Published var potDiameter: Double = 20
    @Published var potDiameterUnit: PotDiameterUnit = .cm
    @Published var potDiameterDontKnow: Bool = false
    @Published var resultUnit: ResultUnit = .ml

    func nextStep() {
        switch currentStep {
        case .location:
            currentStep = .humidity
        case .humidity:
            currentStep = .temperature
        case .temperature:
            currentStep = .potSize
        case .potSize:
            currentStep = .result
        case .result:
            break
        }
    }

    func previousStep() {
        switch currentStep {
        case .location:
            break
        case .humidity:
            currentStep = .location
        case .temperature:
            currentStep = .humidity
        case .potSize:
            currentStep = .temperature
        case .result:
            currentStep = .potSize
        }
    }

    func isCurrentStepValid() -> Bool {
        switch currentStep {
        case .location:
            return plantLocation != nil
        case .humidity:
            return humidityDontKnow || (humidity >= 0 && humidity <= 100)
        case .temperature:
            return temperatureDontKnow || (temperature >= (temperatureUnit == .celsius ? 0 : 32) && temperature <= (temperatureUnit == .celsius ? 40 : 104))
        case .potSize:
            return potDiameterDontKnow || (potDiameter >= (potDiameterUnit == .cm ? 5 : 2) && potDiameter <= (potDiameterUnit == .cm ? 100 : 40))
        default:
            return true
        }
    }
    
    func calculatedWaterAmount() -> String {
        // This is a placeholder calculation.
        // You should replace this with a real calculation based on the user's input.
        var waterAmount: Double = 250 // base amount in ml
        
        // Adjust based on pot size
        let diameterInCm = potDiameterUnit == .cm ? potDiameter : potDiameter * 2.54
        waterAmount *= (diameterInCm / 20) // Adjust based on a 20cm pot
        
        if resultUnit == .oz {
            return String(format: "%.1f", waterAmount * 0.033814)
        } else {
            return String(format: "%.0f", waterAmount)
        }
    }
}

struct LocationStepView: View {
    @ObservedObject var viewModel: WaterMeterViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose where your plant is located")
                .font(.title2).bold()
                .padding(.horizontal)

            LocationCard(
                title: "Outdoor area",
                subtitle: "Only Garden",
                imageName: "outdoor-plant", // Use your asset
                isSelected: viewModel.plantLocation == .outdoor
            ) {
                viewModel.plantLocation = .outdoor
            }

            LocationCard(
                title: "Indoor Area",
                subtitle: "Living room, kitchen, bedroom, etc...",
                imageName: "indoor-plant", // Use your asset
                isSelected: viewModel.plantLocation == .indoor
            ) {
                viewModel.plantLocation = .indoor
            }
        }
        .padding()
    }
}

struct LocationCard: View {
    let title: String
    let subtitle: String
    let imageName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipped()
                    .cornerRadius(12)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title).font(.headline)
                    Text(subtitle).font(.subheadline).foregroundColor(.secondary)
                }
                .foregroundColor(.primary)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                        .font(.title2)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
    }
}

//struct HumidityStepView: View {
//    @ObservedObject var viewModel: WaterMeterViewModel
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            Text("What is the humidity in your area?")
//                .font(.title2).bold()
//                .padding(.horizontal)
//
//            HumidityCard(
//                title: "Yes, I know the humidity",
//                isSelected: !viewModel.humidityDontKnow,
//                action: {
//                    viewModel.humidityDontKnow = false
//                }
//            )
//
//            HumidityCard(
//                title: "I don't know the humidity",
//                isSelected: viewModel.humidityDontKnow,
//                action: {
//                    viewModel.humidityDontKnow = true
//                }
//            )
//        }
//        .padding()
//    }
//}

//struct HumidityCard: View {
//    let title: String
//    let isSelected: Bool
//    let action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            HStack {
//                Text(title)
//                    .font(.headline)
//                    .foregroundColor(.primary)
//
//                Spacer()
//
//                if isSelected {
//                    Image(systemName: "checkmark.circle.fill")
//                        .foregroundColor(.accentColor)
//                        .font(.title2)
//                }
//            }
//            .padding()
//            .background(Color.white)
//            .cornerRadius(16)
//            .overlay(
//                RoundedRectangle(cornerRadius: 16)
//                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
//            )
//        }
//    }
//}
//
//struct TemperatureStepView: View {
//    @ObservedObject var viewModel: WaterMeterViewModel
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            Text("What is the temperature in your area?")
//                .font(.title2).bold()
//                .padding(.horizontal)
//
//            TemperatureCard(
//                title: "Yes, I know the temperature",
//                isSelected: !viewModel.temperatureDontKnow,
//                action: {
//                    viewModel.temperatureDontKnow = false
//                }
//            )
//
//            TemperatureCard(
//                title: "I don't know the temperature",
//                isSelected: viewModel.temperatureDontKnow,
//                action: {
//                    viewModel.temperatureDontKnow = true
//                }
//            )
//        }
//        .padding()
//    }
//}
//
//struct TemperatureCard: View {
//    let title: String
//    let isSelected: Bool
//    let action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            HStack {
//                Text(title)
//                    .font(.headline)
//                    .foregroundColor(.primary)
//
//                Spacer()
//
//                if isSelected {
//                    Image(systemName: "checkmark.circle.fill")
//                        .foregroundColor(.accentColor)
//                        .font(.title2)
//                }
//            }
//            .padding()
//            .background(Color.white)
//            .cornerRadius(16)
//            .overlay(
//                RoundedRectangle(cornerRadius: 16)
//                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
//            )
//        }
//    }
//}
//
//struct PotDiameterStepView: View {
//    @ObservedObject var viewModel: WaterMeterViewModel
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            Text("What is the pot diameter?")
//                .font(.title2).bold()
//                .padding(.horizontal)
//
//            PotDiameterCard(
//                title: "Yes, I know the diameter",
//                isSelected: !viewModel.potDiameterDontKnow,
//                action: {
//                    viewModel.potDiameterDontKnow = false
//                }
//            )
//
//            PotDiameterCard(
//                title: "I don't know the diameter",
//                isSelected: viewModel.potDiameterDontKnow,
//                action: {
//                    viewModel.potDiameterDontKnow = true
//                }
//            )
//        }
//        .padding()
//    }
//}
//
//struct PotDiameterCard: View {
//    let title: String
//    let isSelected: Bool
//    let action: () -> Void
//
//    var body: some View {
//        Button(action: action) {
//            HStack {
//                Text(title)
//                    .font(.headline)
//                    .foregroundColor(.primary)
//
//                Spacer()
//
//                if isSelected {
//                    Image(systemName: "checkmark.circle.fill")
//                        .foregroundColor(.accentColor)
//                        .font(.title2)
//                }
//            }
//            .padding()
//            .background(Color.white)
//            .cornerRadius(16)
//            .overlay(
//                RoundedRectangle(cornerRadius: 16)
//                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
//            )
//        }
//    }
//}
//
//struct ResultStepView: View {
//    @ObservedObject var viewModel: WaterMeterViewModel
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 16) {
//            Text("Result")
//                .font(.title2).bold()
//                .padding(.horizontal)
//
//            Text("Calculated water amount: \(viewModel.calculatedWaterAmount())")
//                .font(.headline)
//                .foregroundColor(.primary)
//        }
//        .padding()
//    }
//} 
