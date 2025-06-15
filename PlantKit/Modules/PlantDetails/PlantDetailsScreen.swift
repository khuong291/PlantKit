//
//  PlantDetailsScreen.swift
//  PlantKit
//
//  Created by Khuong Pham on 14/6/25.
//

import SwiftUI

struct PlantDetailsScreen: View {
    let plantDetails: PlantDetails?
    let capturedImage: UIImage?
    let onSwitchTab: (MainTab.Tab) -> Void
    @State private var selectedTab = 0
    private let tabs = ["Overview", "Requirements", "Culture", "FAQ", "Articles"]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.appScreenBackgroundColor
                .edgesIgnoringSafeArea(.all)
            content
        }
    }
    
    private var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                headerImageView
                if let details = plantDetails {
                    VStack(alignment: .leading, spacing: 0) {
                        // Title & Subtitle
                        Text(details.commonName)
                            .font(.system(size: 32, weight: .bold))
                            .padding(.top, 14)
                            .padding(.horizontal)
                        Text(details.scientificName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                            .padding(.bottom, 12)
                        // Tabs
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(tabs.indices, id: \.self) { idx in
                                    Button(action: { selectedTab = idx }) {
                                        Text(tabs[idx])
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(selectedTab == idx ? .white : .primary)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 18)
                                            .background(selectedTab == idx ? Color.black : Color.secondary.opacity(0.1))
                                            .cornerRadius(16)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 12)
                        }
                        descriptionSection(details: details)
                        generalSection(details: details)
                        characteristicsSection(details: details)
                        conditionsSection(details: details)
                    }
                } else {
                    VStack {
                        Text("No plant details available")
                            .foregroundColor(.red)
                            .font(.title)
                        Text("plantDetails is nil: \(plantDetails == nil)")
                        Text("capturedImage is nil: \(capturedImage == nil)")
                    }
                    .frame(maxWidth: .infinity, minHeight: 300)
                    .background(Color.yellow.opacity(0.3))
                }
            }
            ShinyBorderButton(systemName: "leaf.fill", title: "Add to My Plants") {
                Haptics.shared.play()
                dismiss()
                onSwitchTab(.myPlants)
            }
            .shadow(color: Color.green.opacity(0.8), radius: 8, x: 0, y: 0)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .edgesIgnoringSafeArea(.top)
    }
    
    private var headerImageView: some View {
        ZStack(alignment: .topTrailing) {
            if let uiImage = capturedImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: UIScreen.main.bounds.width - 100)
                    .clipped()
            } else {
                ZStack {
                    Color.secondary.opacity(0.2)
                    Image("peace-lily")
                        .resizable()
                        .scaledToFill()
                }
                .frame(height: UIScreen.main.bounds.width - 100)
                .clipped()
            }
            Button(action: {
                dismiss()
                onSwitchTab(.myPlants)
            }) {
                Image(systemName: "xmark")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black)
                    .padding(12)
                    .background(Color.white)
                    .clipShape(Circle())
                    .padding(.trailing)
                    .padding(.top, 30)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    private func descriptionSection(details: PlantDetails) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal)
            Text(details.description)
                .font(.subheadline)
                .foregroundColor(.primary)
                .padding(.top, 2)
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                .padding(.horizontal)
        }
        .padding(.bottom, 20)
    }
    
    private func generalSection(details: PlantDetails) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("General")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal)
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "globe")
                        .font(.title2)
                        .foregroundColor(.primary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Habitat")
                            .font(.headline)
                        Text("Natural Habitats")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(details.general.habitat)
                            .font(.subheadline)
                    }
                }
                .padding(.bottom, 14)
                Divider()
                VStack(alignment: .leading, spacing: 6) {
                    Text("Countries of Origin")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    HStack(spacing: 8) {
                        ForEach(details.general.originCountries, id: \.self) { country in
                            FlagChip(label: country)
                        }
                    }
                }
                .padding(.vertical, 14)
                Divider()
                VStack(alignment: .leading, spacing: 2) {
                    Text("Environmental Benefits")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(details.general.environmentalBenefits.joined(separator: ", "))
                        .font(.subheadline)
                }
                .padding(.top, 14)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
            .padding(.horizontal)
        }
        .padding(.bottom, 20)
    }
    
    private func characteristicsSection(details: PlantDetails) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Characteristics")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal)
            physicalCard(details: details)
            developmentCard(details: details)
        }
        .padding(.bottom, 20)
    }
    
    private func physicalCard(details: PlantDetails) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 6) {
                Image(systemName: "atom")
                    .font(.title2)
                    .foregroundColor(.primary)
                Text("Physical")
                    .font(.headline)
            }
            .padding(.bottom, 14)
            Divider()
            HStack {
                Text("Height")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(details.physical.height)
                    .font(.subheadline)
            }
            .padding(.vertical, 14)
            Divider()
            HStack {
                Text("Crown Diameter")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(details.physical.crownDiameter)
                    .font(.subheadline)
            }
            .padding(.vertical, 14)
            Divider()
            HStack {
                Text("Form")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(details.physical.form)
                    .font(.subheadline)
            }
            .padding(.top, 14)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
    
    private func developmentCard(details: PlantDetails) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 6) {
                Image(systemName: "leaf")
                    .font(.title2)
                    .foregroundColor(.primary)
                Text("Development")
                    .font(.headline)
            }
            .padding(.bottom, 14)
            Divider()
            HStack {
                Text("Mature Height Time")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(details.development.matureHeightTime)
                .font(.subheadline)
            }
            .padding(.vertical, 14)
            Divider()
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Growth Speed")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(details.development.growthSpeed)")
                        .font(.subheadline)
                }
                GrowthBar(value: details.development.growthSpeed, max: 10)
            }
            .padding(.vertical, 14)
            Divider()
            VStack(alignment: .leading, spacing: 6) {
                Text("Propagation Methods")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(details.development.propagationMethods.joined(separator: ", "))
                    .font(.subheadline)
            }
            .padding(.vertical, 14)
            Divider()
            HStack {
                Text("Cycle")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(details.development.cycle)
                    .font(.subheadline)
            }
            .padding(.top, 14)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
    
    private func conditionsSection(details: PlantDetails) -> some View {
        guard let conditions = details.conditions else { return AnyView(EmptyView()) }
        return AnyView(
            VStack(alignment: .leading, spacing: 16) {
                Text("CONDITIONS")
                    .font(.headline)
                    .foregroundColor(.primary)
                    .padding(.horizontal)
                if let climatic = conditions.climatic {
                    climaticCard(climatic)
                }
                if let soil = conditions.soil {
                    soilCard(soil)
                }
                if let light = conditions.light {
                    lightCard(light)
                }
            }
            .padding(.bottom, 20)
        )
    }
    
    private func climaticCard(_ climatic: PlantDetails.Conditions.Climatic) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "thermometer.sun")
                    .font(.title2)
                    .foregroundColor(.primary)
                Text("Climatic")
                    .font(.headline)
                Spacer()
                Text(String(format: "%.1f°C", climatic.minTemperature))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            // Hardiness Zone
            HStack(spacing: 4) {
                ForEach(1...13, id: \.self) { zone in
                    let isActive = climatic.hardinessZone.contains(zone)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isActive ? Color(hue: Double(zone)/13.0, saturation: 0.5, brightness: 1) : Color(.systemGray6))
                        .frame(width: 22, height: 22)
                        .overlay(
                            Text("\(zone)")
                                .font(.caption2)
                                .foregroundColor(isActive ? .white : .gray)
                        )
                }
            }
            // Temperature
            VStack(alignment: .leading) {
                Text("Temperature")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                VStack(spacing: 0) {
                    RangeBar(
                        range: 0...50,
                        highlight: climatic.temperatureRange.lower...climatic.temperatureRange.upper,
                        ideal: climatic.idealTemperatureRange.lower...climatic.idealTemperatureRange.upper
                    )
                    GeometryReader { geo in
                        let width = geo.size.width
                        let range = 50.0 - 0.0
                        let tStart = CGFloat((climatic.temperatureRange.lower - 0.0) / range) * width
                        let tEnd = CGFloat((climatic.temperatureRange.upper - 0.0) / range) * width
                        let iStart = CGFloat((climatic.idealTemperatureRange.lower - 0.0) / range) * width
                        let iEnd = CGFloat((climatic.idealTemperatureRange.upper - 0.0) / range) * width
                        ZStack(alignment: .topLeading) {
                            HStack {
                                Text("0")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("50")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            // Tolerated range labels
                            Text("\(Int(climatic.temperatureRange.lower))")
                                .font(.caption2)
                                .offset(x: tStart - 0)
                            Text("\(Int(climatic.temperatureRange.upper))")
                                .font(.caption2)
                                .offset(x: tEnd - 10)
                            // Ideal range labels
                            Text("\(Int(climatic.idealTemperatureRange.lower))")
                                .font(.caption2)
                                .offset(x: iStart - 0)
                            Text("\(Int(climatic.idealTemperatureRange.upper))")
                                .font(.caption2)
                                .offset(x: iEnd - 10)
                        }
                    }
                    .frame(height: 20)
                }
                // Legend
                HStack(spacing: 12) {
                    Spacer()
                    HStack(spacing: 4) {
                        Circle().fill(Color.green.opacity(0.4)).frame(width: 10, height: 10)
                        Text("Tolerated").font(.caption2)
                    }
                    HStack(spacing: 4) {
                        Circle().fill(Color.green).frame(width: 10, height: 10)
                        Text("Ideal").font(.caption2)
                    }
                    Spacer()
                }
                .padding(.top, 2)
            }
            .padding(.top, 14)
            // Humidity
            VStack(alignment: .leading) {
                Text("Humidity")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                VStack(spacing: 0) {
                    RangeBar(
                        range: 0...100,
                        highlight: Double(climatic.humidityRange.lower)...Double(climatic.humidityRange.upper),
                        ideal: Double(climatic.humidityRange.lower)...Double(climatic.humidityRange.upper),
                        isPercent: true
                    )
                    GeometryReader { geo in
                        let width = geo.size.width
                        let range = 100.0
                        let hStart = CGFloat(Double(climatic.humidityRange.lower) / range) * width
                        let hEnd = CGFloat(Double(climatic.humidityRange.upper) / range) * width
                        ZStack(alignment: .topLeading) {
                            HStack {
                                Text("0%")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text("100%")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Text("\(climatic.humidityRange.lower)")
                                .font(.caption2)
                                .offset(x: hStart - 0)
                            Text("\(climatic.humidityRange.upper)")
                                .font(.caption2)
                                .offset(x: hEnd - 10)
                        }
                    }
                    .frame(height: 28)
                }
            }
            // Wind Resistance
            if let wind = climatic.windResistance {
                HStack {
                    Text("Wind Resistance")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(wind)
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
    
    private func soilCard(_ soil: PlantDetails.Conditions.Soil) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "mountain.2")
                    .font(.title2)
                    .foregroundColor(.primary)
                Text("Soil")
                    .font(.headline)
                Spacer()
                Text(soil.phLabel)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            VStack(alignment: .leading) {
                // pH
                Text("Potential of Hydrogen (pH)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                GeometryReader { geometry in
                    let spacing: CGFloat = 4
                    let totalSpacing = spacing * CGFloat(14) // 15 numbers (0-14) need 14 spaces
                    let availableWidth = geometry.size.width - totalSpacing
                    let barWidth = availableWidth / 15 // Divide by 15 for 0-14
                    
                    HStack(spacing: spacing) {
                        ForEach(0...14, id: \.self) { ph in
                            let isActive = soil.phRange.contains(Double(ph))
                            RoundedRectangle(cornerRadius: 4)
                                .fill(isActive ? Color.green : Color(.systemGray6))
                                .frame(width: barWidth, height: 22)
                                .overlay(
                                    Text("\(ph)")
                                        .font(.caption2)
                                        .foregroundColor(isActive ? .white : .gray)
                                )
                        }
                    }
                }
                .frame(height: 22)
            }
            .padding(.top, 14)
            // Types
            VStack(alignment: .leading, spacing: 2) {
                Text("Types")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(soil.types.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            .padding(.top, 14)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
    
    private func lightCard(_ light: PlantDetails.Conditions.Light) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb")
                    .font(.title2)
                    .foregroundColor(.primary)
                Text("Light")
                    .font(.headline)
            }
            HStack {
                Text("Amount")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(light.amount)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            HStack {
                Text("Type")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(light.type)
                    .font(.subheadline)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
}

struct FlagChip: View {
    let label: String
    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 10)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
}

struct GrowthBar: View {
    let value: Int
    let max: Int
    
    var body: some View {
        GeometryReader { geometry in
            let totalSpacing = CGFloat(max - 1) * 4
            let barWidth = (geometry.size.width - totalSpacing) / CGFloat(max)
            HStack(spacing: 4) {
                ForEach(0..<max, id: \.self) { idx in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(idx < value ? Color.green : Color(.systemGray5))
                        .frame(width: barWidth, height: 16)
                }
            }
        }
        .frame(height: 16)
    }
}

private struct RangeBar: View {
    let range: ClosedRange<Double>
    let highlight: ClosedRange<Double>
    let ideal: ClosedRange<Double>?
    var isPercent: Bool = false
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color(.systemGray6))
                    .frame(height: 14)
                Capsule()
                    .fill(Color.green.opacity(0.4))
                    .frame(
                        width: width * CGFloat((highlight.upperBound - highlight.lowerBound) / (range.upperBound - range.lowerBound)),
                        height: 14
                    )
                    .offset(x: width * CGFloat((highlight.lowerBound - range.lowerBound) / (range.upperBound - range.lowerBound)))
                if let ideal = ideal {
                    Capsule()
                        .fill(Color.green)
                        .frame(
                            width: width * CGFloat((ideal.upperBound - ideal.lowerBound) / (range.upperBound - range.lowerBound)),
                            height: 14
                        )
                        .offset(x: width * CGFloat((ideal.lowerBound - range.lowerBound) / (range.upperBound - range.lowerBound)))
                }
            }
        }
        .frame(height: 14)
    }
}

#if DEBUG
private let mockPlantDetails = PlantDetails(
    commonName: "Aloe Vera",
    scientificName: "Aloe barbadensis miller",
    description: "Aloe Vera is a succulent plant species known for its medicinal properties and thick, fleshy leaves filled with a gel-like substance.",
    general: .init(
        habitat: "Arid and semi-arid climates",
        originCountries: ["Sudan", "Arabian Peninsula"],
        environmentalBenefits: ["Air purification", "Soil erosion control"]
    ),
    physical: .init(
        height: "24-39 inches",
        crownDiameter: "Up to 20 inches",
        form: "Rosette"
    ),
    development: .init(
        matureHeightTime: "3-4 years",
        growthSpeed: 5,
        propagationMethods: ["Offsets", "Cuttings"],
        cycle: "Perennial"
    ),
    conditions: .init(
        climatic: .init(
            hardinessZone: [1,2,3,4,5,6,7,8,9,10,11,12,13],
            minTemperature: -1.1,
            temperatureRange: .init(lower: 5, upper: 40),
            idealTemperatureRange: .init(lower: 20, upper: 30),
            humidityRange: .init(lower: 60, upper: 85),
            windResistance: "50km/h"
        ),
        soil: .init(
            phRange: [6.0, 7.0, 8.0],
            phLabel: "Neutral",
            types: ["Universal soil", "Tropical plant soil", "Vegetable garden soil"]
        ),
        light: .init(
            amount: "8 to 12 hrs/day",
            type: "Full sun"
        )
    )
)

private let mockImage: UIImage? = {
    return UIImage(named: "peace-lily")
}()
#endif

#Preview {
    PlantDetailsScreen(
        plantDetails: mockPlantDetails,
        capturedImage: mockImage,
        onSwitchTab: { _ in }
    )
}
