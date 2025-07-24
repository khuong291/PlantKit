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
                        let content = articleContent(for: symptom)
                        VStack(alignment: .leading, spacing: 20) {
                            Capsule()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 40, height: 5)
                                .frame(maxWidth: .infinity)
                                .offset(y: -10)

                            Text(symptom.description)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)

                            if let content = content {
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
                subtitle: "Your plant appears a classic sign of etiolation, a condition caused by plants growing in inadequate levels of light.",
                orangeHeading: "Check if your plant has the following symptoms:",
                symptomDetails: "Your plant has pale, elongated leaves that reach upward or spindly stems that are pale yellow in color. You will often notice fewer leaves in mature plants and lifeless, fleshy leaves in succulents. Newly germinated seedlings will look tall, thin, and spindly. This is a classic sign of etiolation, a condition caused by plants growing in inadequate levels of light.",
                body: "In low-level light conditions, etiolation occurs as a result of etioplasts developing in the plant tissue instead of chlorophyll, the compound which converts the sun’s energy into plant food. Etiolation naturally occurs in plants in normal conditions to help plants reach sunlight. However, without adequate light, there are low levels of chlorophyll, and the plant becomes weakened and malnourished."
            )
        }
        if symptom.imageName == "dried-herb" {
            return SymptomArticleContent(
                subtitle: "Your plant is showing signs of complete desiccation above the soil, a condition frequently seen in herbs.",
                orangeHeading: "Check if your plant has the following symptoms:",
                symptomDetails: "All visible parts of the plant above the soil—leaves, stems, and flowers—are dry, brittle, and lifeless. The plant may appear brown or tan, with no green tissue remaining. This is especially common in potted herbs like basil, parsley, or mint, which are sensitive to water stress and environmental changes.",
                body: "When every part of a plant above the soil line has dried out, it usually indicates either prolonged underwatering, exposure to excessive heat or sunlight, or the natural end of the plant’s life cycle (especially for annual herbs). Inadequate watering is the most common cause, as herbs have shallow roots and can dry out quickly if the soil is left dry for too long. Other contributing factors may include poor soil drainage, root rot (if the roots were previously waterlogged), or pests and diseases that have damaged the plant’s ability to take up water.\n\nWhat to do:\n- Check the soil moisture. If it’s bone dry, try watering, but if the plant does not recover after a day or two, it may be too late.\n- Inspect the roots. If they are brown and mushy, root rot may be the cause.\n- For annual herbs, remember that they naturally die back after flowering and seeding.\n- To prevent this in the future, water herbs regularly, ensure pots have good drainage, and avoid placing them in intense, direct sunlight for prolonged periods.\n\nTip:\nIf you want to reuse the pot or soil, remove all dried plant material and refresh the soil before planting new herbs."
            )
        }
        if symptom.imageName == "black-rotting" {
            return SymptomArticleContent(
                subtitle: "Your plant is exhibiting severe blackening and rot, often starting from the center or base and spreading outward.",
                orangeHeading: "Check if your plant has the following symptoms:",
                symptomDetails: "The plant’s stems, leaves, and base have turned black, mushy, or slimy. The rot often begins at the center or crown of the plant and quickly spreads, causing the entire plant to collapse. You may notice a foul odor, and the plant tissue may feel soft or water-soaked. This condition can affect many types of plants, especially those kept in overly wet or poorly drained soil.",
                body: "Black rot starting from the center of the plant is usually caused by a combination of fungal or bacterial pathogens and environmental stress, most commonly overwatering or poor drainage. When the soil remains wet for extended periods, it creates ideal conditions for pathogens like Pythium, Phytophthora, or Erwinia to infect the plant’s crown and roots. Once the infection takes hold, it rapidly destroys plant tissue, turning it black and mushy.\n\nWhat to do:\n- Remove the affected plant immediately to prevent the spread of disease to nearby plants.\n- Discard the soil and thoroughly clean the pot with hot, soapy water or a diluted bleach solution.\n- Avoid reusing contaminated soil.\n- If you catch the rot early and some healthy tissue remains, you may try to cut away all blackened parts with sterile scissors, but recovery is unlikely if the rot has reached the center.\n- To prevent future cases, always use well-draining soil, avoid overwatering, and ensure pots have drainage holes.\n\nTip:\nSterilize any tools used on infected plants to avoid spreading pathogens to healthy plants."
            )
        }
        return nil
    }
}

#Preview {
    SymptomArticleView(symptom: DiseaseSymptom(imageName: "pale-plant", description: "The entire plant is getting pale, and the stems are lengthening."))
} 
