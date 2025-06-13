import SwiftUI

struct ScanResultScreen: View {
    let plantName: String
    let dismissAction: () -> Void
    let onSwitchTab: (MainTab.Tab) -> Void
    @EnvironmentObject var identifierManager: IdentifierManager
    @Environment(\.dismiss) private var dismiss
    
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
            
            Spacer()
            
            // Action Buttons
            ShinyBorderButton(systemName: "leaf.fill", title: "Add to My Plants") {
                Haptics.shared.play()
                onSwitchTab(.myPlants)
                dismiss()
                dismissAction()
            }
            .shadow(color: Color.green.opacity(0.8), radius: 8, x: 0, y: 0)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .padding()
        .navigationBarTitle("Scan Result", displayMode: .inline)
    }
}
