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
    @State private var selectedTab = 0
    private let tabs = ["Overview", "Requirements", "Culture", "FAQ", "Articles"]
    
    var body: some View {
        print("PlantDetailsScreen loaded, plantDetails:", plantDetails != nil, "capturedImage:", capturedImage != nil)
        return content
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
            }
            .shadow(color: Color.green.opacity(0.8), radius: 8, x: 0, y: 0)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .edgesIgnoringSafeArea(.top)
        .background(Color.red.opacity(0.2))
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
                // Dismiss or close action
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
                .font(.body)
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
        VStack(alignment: .leading, spacing: 12) {
            Text("General")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal)
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "globe")
                        .font(.title2)
                        .foregroundColor(.primary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Habitat")
                            .font(.headline)
                        Text("Natural Habitats")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(details.general.habitat)
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.bottom, 8)
                Divider()
                VStack(alignment: .leading, spacing: 6) {
                    Text("Countries of Origin")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack(spacing: 8) {
                        ForEach(details.general.originCountries, id: \.self) { country in
                            FlagChip(flag: countryFlag(for: country), label: country)
                        }
                    }
                }
                .padding(.vertical, 8)
                Divider()
                VStack(alignment: .leading, spacing: 2) {
                    Text("Environmental Benefits")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(details.general.environmentalBenefits.joined(separator: ", "))
                        .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                .padding(.top, 8)
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
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "atom")
                    .font(.title2)
                    .foregroundColor(.primary)
                Text("Physical")
                    .font(.headline)
            }
            .padding(.bottom, 8)
            Divider()
            HStack {
                Text("Height")
                    .foregroundColor(.secondary)
                Spacer()
                Text(details.physical.height)
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 6)
            Divider()
            HStack {
                Text("Crown Diameter")
                    .foregroundColor(.secondary)
                Spacer()
                Text(details.physical.crownDiameter)
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 6)
            Divider()
            HStack {
                Text("Form")
                    .foregroundColor(.secondary)
                Spacer()
                Text(details.physical.form)
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 6)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
    
    private func developmentCard(details: PlantDetails) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "leaf")
                    .font(.title2)
                    .foregroundColor(.primary)
                Text("Development")
                    .font(.headline)
            }
            .padding(.bottom, 8)
            Divider()
            HStack {
                Text("Mature Height Time")
                    .foregroundColor(.secondary)
                Spacer()
                Text(details.development.matureHeightTime)
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 6)
            Divider()
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Growth Speed")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(details.development.growthSpeed)")
                        .foregroundColor(.primary)
                }
                GrowthBar(value: details.development.growthSpeed, max: 10)
            }
            .padding(.vertical, 6)
            Divider()
            VStack(alignment: .leading, spacing: 6) {
                Text("Propagation Methods")
                    .foregroundColor(.secondary)
                Text(details.development.propagationMethods.joined(separator: ", "))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 6)
            Divider()
            HStack {
                Text("Cycle")
                    .foregroundColor(.secondary)
                Spacer()
                Text(details.development.cycle)
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 6)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
    
    // Helper to get flag emoji from country name (simple mapping, can be improved)
    private func countryFlag(for country: String) -> String {
        switch country.lowercased() {
        case "india": return "🇮🇳"
        case "philippines": return "🇵🇭"
        case "indonesia": return "🇮🇩"
        case "vietnam": return "🇻🇳"
        case "china": return "🇨🇳"
        case "japan": return "🇯🇵"
        case "thailand": return "🇹🇭"
        case "usa", "united states": return "🇺🇸"
        default: return "🌱"
        }
    }
}

struct FlagChip: View {
    let flag: String
    let label: String
    var body: some View {
        HStack(spacing: 4) {
            Text(flag)
            Text(label)
                .font(.caption)
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

#Preview {
    PlantDetailsScreen(plantDetails: nil, capturedImage: nil)
}
