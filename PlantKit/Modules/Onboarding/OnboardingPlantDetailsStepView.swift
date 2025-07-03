import SwiftUI

struct OnboardingPlantDetailsStepView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                VStack(alignment: .center, spacing: 8) {
                    Text("Identify your Plant")
                        .font(.system(size: 34)).bold()
                        .padding(.top, 20)
                        .multilineTextAlignment(.center)
                    Text("Get all the details you need in seconds")
                        .font(.system(size: 17))
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 24)
                
                Spacer()
                
                ZStack(alignment: .topLeading) {
                    Image("photo-identified-img")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 500)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                    Image(systemSymbol: .leafFill)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.green)
                        .clipShape(.circle)
                }
                .padding(.bottom, 32)
                
                Spacer()
            }
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea(edges: .top)
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 32)
        }
    }
}

#Preview {
    OnboardingPlantDetailsStepView()
} 
