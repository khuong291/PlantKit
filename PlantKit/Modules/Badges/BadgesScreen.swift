import SwiftUI

struct Badge: Identifiable, Hashable {
    let id = UUID()
    let imageName: String
    let name: String
    let description: String
}

struct BadgesScreen: View {
    // Example static data
    let badgesEarned = 6
    let totalBadges = 45
    let badgeProgress = 6
    let badgeList: [Badge] = [
        Badge(imageName: "badge1", name: "Rookie", description: "3 day streak"),
        Badge(imageName: "badge2", name: "Getting Serious", description: "10 day streak"),
        Badge(imageName: "badge3", name: "Locked In", description: "50 day streak"),
        Badge(imageName: "badge4", name: "Triple Threat", description: "100 day streak"),
        Badge(imageName: "badge5", name: "No Days Off", description: "365 day streak"),
        Badge(imageName: "badge6", name: "Immortal", description: "1000 day streak"),
        Badge(imageName: "badge7", name: "Forking Around", description: "Log 5 meals"),
        Badge(imageName: "badge8", name: "Mission: Nutrition", description: "Log 50 meals"),
        Badge(imageName: "badge9", name: "The Logfather", description: "Log 500 meals"),
        Badge(imageName: "badge10", name: "The Logfather", description: "Log 500 meals"),
        Badge(imageName: "badge11", name: "The Logfather", description: "Log 500 meals"),
        Badge(imageName: "badge12", name: "The Logfather", description: "Log 500 meals"),
        Badge(imageName: "badge13", name: "The Logfather", description: "Log 500 meals"),
        Badge(imageName: "badge14", name: "The Logfather", description: "Log 500 meals"),
        Badge(imageName: "badge15", name: "The Logfather", description: "Log 500 meals"),
    ]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Badges")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.top, 16)
                    .padding(.horizontal)
                HStack(alignment: .center, spacing: 16) {
                    Image(systemName: "hexagon.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.purple)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(badgesEarned) Badges earned")
                            .font(.system(size: 18, weight: .semibold))
                        Text("\(badgeProgress)/\(totalBadges) badges")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                        ProgressView(value: Double(badgeProgress), total: Double(totalBadges))
                            .frame(width: 120)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                .padding(.bottom, 20)
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(badgeList) { badge in
                        BadgeCard(badge: badge)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

struct BadgeCard: View {
    let badge: Badge
    var body: some View {
        VStack(spacing: 8) {
            Image(badge.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 64, height: 64)
            Text(badge.name)
                .font(.system(size: 15, weight: .semibold))
            Text(badge.description)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(12)
    }
}

#Preview {
    BadgesScreen()
} 
