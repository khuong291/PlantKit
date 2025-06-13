import SwiftUI

struct ScanResultScreen: View {
    let plantName: String
    
    var body: some View {
        VStack(spacing: 20) {
            // Plant Image (you can add this later)
            Image(systemName: "leaf.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 120, height: 120)
                .foregroundColor(.green)
            
            // Plant Name
            Text(plantName)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // Action Buttons
            VStack(spacing: 12) {
                Button(action: {
                    // Add to My Plants action
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
    ScanResultScreen(plantName: "Monstera Deliciosa")
} 