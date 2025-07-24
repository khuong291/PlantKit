import SwiftUI

struct EnableSwipeBack: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        DispatchQueue.main.async {
            controller.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            controller.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        }
        return controller
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct SymptomArticleContent {
    let title: String
    let subtitle: String
    let orangeHeading: String
    let symptomDetails: String
    let body: String
}

struct SymptomArticleView: View {
    let symptom: DiseaseSymptom
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack(alignment: .topLeading) {
            ScrollView(showsIndicators: false) {
                ZStack(alignment: .top) {
                    // Header image
                    Image(symptom.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 260)
                        .clipped()
                        .ignoresSafeArea(edges: .top)

                    VStack(spacing: 0) {
                        Spacer().frame(height: 220)
                        VStack(alignment: .leading, spacing: 20) {
                            Capsule()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 40, height: 5)
                                .frame(maxWidth: .infinity)
                                .offset(y: -10)

                            if let content = articleContent(for: symptom) {
                                Text(content.title)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.primary)

                                Text(content.subtitle)
                                    .font(.system(size: 17))
                                    .foregroundColor(.secondary)

                                Text(content.orangeHeading)
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.orange)
                                    .padding(.top, 8)

                                Text(content.symptomDetails)
                                    .font(.body)
                                    .foregroundColor(.primary)

                                Text(content.body)
                                    .font(.body)
                                    .foregroundColor(.primary)
                            } else {
                                Text(symptom.description)
                                    .font(.title2)
                                    .bold()
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 32)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: -2)
                        )
                    }
                }
            }
            .overlay(
                HStack {
                    Button(action: { dismiss() }) {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.6))
                                .frame(width: 36, height: 36)
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.system(size: 15, weight: .semibold))
                                .frame(width: 36, height: 36)
                        }
                    }
                    .padding(.leading, 16)
                    .padding(.top, 44) // For safe area
                    Spacer()
                }, alignment: .topLeading
            )
        }
        .background(EnableSwipeBack())
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }

    private func articleContent(for symptom: DiseaseSymptom) -> SymptomArticleContent? {
        if symptom.imageName == "pale-plant" {
            return SymptomArticleContent(
                title: "Insufficient light",
                subtitle: "Your plant appears a classic sign of etiolation, a condition caused by plants growing in inadequate levels of light.",
                orangeHeading: "Check if your plant has the following symptoms:",
                symptomDetails: "Your plant has pale, elongated leaves that reach upward or spindly stems that are pale yellow in color. You will often notice fewer leaves in mature plants and lifeless, fleshy leaves in succulents. Newly germinated seedlings will look tall, thin, and spindly. This is a classic sign of etiolation, a condition caused by plants growing in inadequate levels of light.",
                body: "In low-level light conditions, etiolation occurs as a result of etioplasts developing in the plant tissue instead of chlorophyll, the compound which converts the sun’s energy into plant food. Etiolation naturally occurs in plants in normal conditions to help plants reach sunlight. However, without adequate light, there are low levels of chlorophyll, and the plant becomes weakened and malnourished."
            )
        }
        return nil
    }
}

#Preview {
    SymptomArticleView(symptom: DiseaseSymptom(imageName: "pale-plant", description: "The entire plant is getting pale, and the stems are lengthening."))
} 
