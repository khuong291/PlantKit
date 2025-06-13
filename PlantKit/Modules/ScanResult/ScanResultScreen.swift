import SwiftUI

struct ScanResultScreen: View {
    let plantName: String
    @EnvironmentObject var identifierManager: IdentifierManager
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTab: MainTab.Tab
    
    var body: some View {
        VStack(spacing: 20) {
            // Captured Image
            if let lastScan = identifierManager.recentScans.first {
                Image(uiImage: lastScan.image ?? UIImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.width * 0.9)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white, lineWidth: 2)
                    )
            }
            
            // Plant Name
            Text(plantName)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // Action Buttons
            VStack(spacing: 12) {
                Button(action: {
                    // Add to My Plants action
                    Haptics.shared.play()
                    selectedTab = .myPlants
                    dismiss()
                }) {
                    Text("Add to My Plants")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                }
                
                Button(action: {
                    // Learn More action
                }) {
                    Text("Learn More")
                        .font(.headline)
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .navigationBarTitle("Scan Result", displayMode: .inline)
    }
}

#Preview {
    ScanResultScreen(plantName: "Monstera Deliciosa", selectedTab: .constant(.home))
        .environmentObject(IdentifierManager())
} 