//
//  PlantDetailsScreen.swift
//  PlantKit
//
//  Created by Khuong Pham on 14/6/25.
//

import SwiftUI

struct PlantDetailsScreen: View {
    @State private var selectedTab = 0
    private let tabs = ["Overview", "Requirements", "Culture", "FAQ", "Articles"]
    
    var body: some View {
        content
    }
    
    private var content: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                headerImageView
                
                // Main content
                VStack(alignment: .leading, spacing: 0) {
                    // Title & Subtitle
                    Text("Peace Lily")
                        .font(.system(size: 32, weight: .bold))
                        .padding(.top, 14)
                        .padding(.horizontal)
                    Text("Spathiphyllum, including Spathiphyllum wallisii")
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
                    
                    descriptionSection
                    generalSection
                    characteristicsSection
                }
            }
            
            // Save Button
            ShinyBorderButton(systemName: "leaf.fill", title: "Add to My Plants") {
                Haptics.shared.play()
               
            }
            .shadow(color: Color.green.opacity(0.8), radius: 8, x: 0, y: 0)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .edgesIgnoringSafeArea(.top)
        .background(Color(.systemGroupedBackground))
    }
    
    private var headerImageView: some View {
        ZStack(alignment: .topTrailing) {
            Image("peace-lily")
                .resizable()
                .scaledToFill()
                .frame(height: UIScreen.main.bounds.width - 100)
                .clipped()
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
    
    private var descriptionSection: some View {
        // Overview Section
        VStack(alignment: .leading, spacing: 8) {
            Text("Description")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal)
            Text("Peace Lily (Spathiphyllum) is an evergreen perennial flowering plant in the family Araceae. It grows from rhizomes and has large, glossy, dark green leaves. Peace Lilies are popular as houseplants for their attractive foliage and white flowers.")
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

    private var generalSection: some View {
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
                        Text("Tropical forests, Grasslands")
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
                        FlagChip(flag: "🇮🇳", label: "India")
                        FlagChip(flag: "🇵🇭", label: "Philippines")
                        FlagChip(flag: "🇮🇩", label: "Indonesia")
                    }
                }
                .padding(.vertical, 8)
                Divider()
                VStack(alignment: .leading, spacing: 2) {
                    Text("Environmental Benefits")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Oxygen production, Air purification")
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

    private var characteristicsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Characteristics")
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.horizontal)
            physicalCard
            developmentCard
        }
        .padding(.bottom, 20)
    }

    private var physicalCard: some View {
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
                Text("2 to 9 m")
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 6)
            Divider()
            HStack {
                Text("Crown Diameter")
                    .foregroundColor(.secondary)
                Spacer()
                Text("1 to 3 m")
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 6)
            Divider()
            HStack {
                Text("Form")
                    .foregroundColor(.secondary)
                Spacer()
                Text("Herb")
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

    private var developmentCard: some View {
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
                Text("30 years")
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 6)
            Divider()
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("Growth Speed")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("7")
                        .foregroundColor(.primary)
                }
                GrowthBar(value: 7, max: 10)
            }
            .padding(.vertical, 6)
            Divider()
            VStack(alignment: .leading, spacing: 6) {
                Text("Propagation Methods")
                    .foregroundColor(.secondary)
                Text("Seed propagation, Stem cuttings")
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 6)
            Divider()
            HStack {
                Text("Cycle")
                    .foregroundColor(.secondary)
                Spacer()
                Text("Perennial")
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
    PlantDetailsScreen()
}
