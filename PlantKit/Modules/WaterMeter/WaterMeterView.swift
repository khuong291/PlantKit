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
    
    private var steps: [WaterMeterViewModel.Step] = [.location, .humidity, .temperature, .potSize, .result]
    @State private var transition: AnyTransition = .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))

    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
    }
    
    private func handleSwipe(forward: Bool) {
        if forward {
            guard viewModel.currentStep != .result else { return }
            transition = .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
            withAnimation { viewModel.nextStep() }
        } else {
            guard viewModel.currentStep != .location else { return }
            transition = .asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .trailing))
            withAnimation { viewModel.previousStep() }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Custom Navigation Bar
            HStack {
                if viewModel.currentStep != .location {
                    Button(action: {
                        handleSwipe(forward: false)
                    }) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.accentColor)
                }
                Spacer()
                Button(action: {
                    isPresented = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray.opacity(0.4))
                }
            }
            .padding()
            .frame(height: 50)

            // Step Content
            VStack {
                switch viewModel.currentStep {
                case .location:
                    LocationStepView(viewModel: viewModel, handleSwipe: handleSwipe)
                case .humidity:
                    HumidityStepView(viewModel: viewModel, handleSwipe: handleSwipe)
                case .temperature:
                    TemperatureStepView(viewModel: viewModel, handleSwipe: handleSwipe)
                case .potSize:
                    PotDiameterStepView(viewModel: viewModel, handleSwipe: handleSwipe)
                case .result:
                    ResultStepView(viewModel: viewModel)
                }
            }
            .transition(transition)
            .id(viewModel.currentStep)
            .gesture(
                DragGesture(minimumDistance: 25, coordinateSpace: .local)
                    .onEnded { value in
                        if value.translation.width < 0 {
                            handleSwipe(forward: true)
                        }

                        if value.translation.width > 0 {
                            handleSwipe(forward: false)
                        }
                    }
            )

            // Step Indicator
            if viewModel.currentStep != .result {
                HStack(spacing: 8) {
                    ForEach(0..<4) { index in
                        Circle()
                            .fill(steps.firstIndex(of: viewModel.currentStep) == index ? Color.accentColor : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.vertical, 30)
            }
        }
        .background(Color.white)
    }
}

class WaterMeterViewModel: ObservableObject {
    enum Step: Hashable {
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
    var handleSwipe: (Bool) -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 32) {
            Spacer()
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 48, weight: .thin))
                .foregroundColor(.accentColor)
            
            Text("Choose where your plant is located")
                .font(.title2).bold()
                .padding(.horizontal)

            LocationCard(
                title: "Outdoor area",
                subtitle: "Only Garden",
                systemImageName: "sun.max.fill",
                isSelected: viewModel.plantLocation == .outdoor
            ) {
                viewModel.plantLocation = .outdoor
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    handleSwipe(true)
                }
            }

            LocationCard(
                title: "Indoor Area",
                subtitle: "Living room, kitchen, bedroom, etc...",
                systemImageName: "house.fill",
                isSelected: viewModel.plantLocation == .indoor
            ) {
                viewModel.plantLocation = .indoor
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    handleSwipe(true)
                }
            }
            Spacer()
        }
        .padding()
    }
}

struct LocationCard: View {
    let title: String
    let subtitle: String
    let systemImageName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: systemImageName)
                    .font(.title)
                    .foregroundColor(.accentColor)
                    .frame(width: 80, height: 80)

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
