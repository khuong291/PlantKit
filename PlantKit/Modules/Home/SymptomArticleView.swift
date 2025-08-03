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
    let whatToDo: String?
    let tip: String?
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
                        .frame(maxWidth: UIScreen.main.bounds.width)
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
                                    .font(.system(size: 17))
                                    .foregroundColor(.primary)
                                Text(content.body)
                                    .font(.system(size: 17))
                                    .foregroundColor(.primary)
                                
                                if let whatToDo = content.whatToDo {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("What to do:")
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundColor(.blue)
                                        Text(whatToDo)
                                            .font(.system(size: 17))
                                            .foregroundColor(.primary)
                                    }
                                    .padding(.top, 8)
                                }
                                
                                if let tip = content.tip {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Tip:")
                                            .font(.system(size: 17, weight: .semibold))
                                            .foregroundColor(.green)
                                        Text(tip)
                                            .font(.system(size: 17))
                                            .foregroundColor(.primary)
                                    }
                                    .padding(.top, 8)
                                }
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
                    Button(action: { 
                        Haptics.shared.play()
                        dismiss() 
                    }) {
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
                body: "In low-level light conditions, etiolation occurs as a result of etioplasts developing in the plant tissue instead of chlorophyll, the compound which converts the sun's energy into plant food. Etiolation naturally occurs in plants in normal conditions to help plants reach sunlight. However, without adequate light, there are low levels of chlorophyll, and the plant becomes weakened and malnourished.",
                whatToDo: nil,
                tip: nil
            )
        }
        if symptom.imageName == "dried-herb" {
            return SymptomArticleContent(
                subtitle: "Your plant is showing signs of complete desiccation above the soil, a condition frequently seen in herbs.",
                orangeHeading: "Check if your plant has the following symptoms:",
                symptomDetails: "All visible parts of the plant above the soil—leaves, stems, and flowers—are dry, brittle, and lifeless. The plant may appear brown or tan, with no green tissue remaining. This is especially common in potted herbs like basil, parsley, or mint, which are sensitive to water stress and environmental changes.",
                body: "When every part of a plant above the soil line has dried out, it usually indicates either prolonged underwatering, exposure to excessive heat or sunlight, or the natural end of the plant's life cycle (especially for annual herbs). Inadequate watering is the most common cause, as herbs have shallow roots and can dry out quickly if the soil is left dry for too long. Other contributing factors may include poor soil drainage, root rot (if the roots were previously waterlogged), or pests and diseases that have damaged the plant's ability to take up water.",
                whatToDo: "Check the soil moisture. If it's bone dry, try watering, but if the plant does not recover after a day or two, it may be too late.\n- Inspect the roots. If they are brown and mushy, root rot may be the cause.\n- For annual herbs, remember that they naturally die back after flowering and seeding.\n- To prevent this in the future, water herbs regularly, ensure pots have good drainage, and avoid placing them in intense, direct sunlight for prolonged periods.",
                tip: "If you want to reuse the pot or soil, remove all dried plant material and refresh the soil before planting new herbs."
            )
        }
        if symptom.imageName == "black-rotting" {
            return SymptomArticleContent(
                subtitle: "Your plant is exhibiting severe blackening and rot, often starting from the center or base and spreading outward.",
                orangeHeading: "Check if your plant has the following symptoms:",
                symptomDetails: "The plant's stems, leaves, and base have turned black, mushy, or slimy. The rot often begins at the center or crown of the plant and quickly spreads, causing the entire plant to collapse. You may notice a foul odor, and the plant tissue may feel soft or water-soaked. This condition can affect many types of plants, especially those kept in overly wet or poorly drained soil.",
                body: "Black rot starting from the center of the plant is usually caused by a combination of fungal or bacterial pathogens and environmental stress, most commonly overwatering or poor drainage. When the soil remains wet for extended periods, it creates ideal conditions for pathogens like Pythium, Phytophthora, or Erwinia to infect the plant's crown and roots. Once the infection takes hold, it rapidly destroys plant tissue, turning it black and mushy.",
                whatToDo: "Remove the affected plant immediately to prevent the spread of disease to nearby plants.\n- Discard the soil and thoroughly clean the pot with hot, soapy water or a diluted bleach solution.\n- Avoid reusing contaminated soil.\n- If you catch the rot early and some healthy tissue remains, you may try to cut away all blackened parts with sterile scissors, but recovery is unlikely if the rot has reached the center.\n- To prevent future cases, always use well-draining soil, avoid overwatering, and ensure pots have drainage holes.",
                tip: "Sterilize any tools used on infected plants to avoid spreading pathogens to healthy plants."
            )
        }
        if symptom.imageName == "dried-out" {
            return SymptomArticleContent(
                subtitle: "Your plant is completely dry, with no green tissue remaining, indicating severe dehydration or the end of its life cycle.",
                orangeHeading: "Check if your plant has the following symptoms:",
                symptomDetails: "All parts of the plant—leaves, stems, and sometimes even flowers—are brown, brittle, and dry to the touch. The plant may appear shriveled, and leaves may easily crumble or fall off. There is no sign of moisture or life in any part above the soil.",
                body: "When a plant has completely dried out, it is usually the result of prolonged underwatering, excessive heat, or natural aging (especially for annuals). Without enough water, the plant cannot maintain its cellular structure, leading to wilting, browning, and eventually total desiccation. Sometimes, a plant may also dry out after it has completed its natural life cycle or if it has suffered from root damage, pests, or disease.",
                whatToDo: "Check the soil. If it is extremely dry and hard, the plant likely died from lack of water.\n- Inspect the roots. If they are also dry and brittle, the plant cannot be revived.\n- Remove the dried plant and dispose of it.\n- Clean the pot thoroughly before reusing it for a new plant.\n- To prevent this in the future, water your plants regularly, especially during hot or dry weather, and ensure the soil retains some moisture but is not waterlogged.",
                tip: "If you want to reuse the soil, mix in fresh potting mix and check for pests or diseases before planting again."
            )
        }
        if symptom.imageName == "leaves-yellow" {
            return SymptomArticleContent(
                subtitle: "Your plant's leaves are yellowing and falling, a common sign of stress, improper care, or disease.",
                orangeHeading: "Check if your plant has the following symptoms:",
                symptomDetails: "Leaves start to turn yellow, often beginning at the tips or edges, and may develop brown spots or patches. As the yellowing progresses, leaves become limp or dry and eventually fall off the plant. This can affect older, lower leaves first, but may spread to new growth if the underlying issue is not addressed.",
                body: "Yellowing and dropping leaves can be caused by a variety of factors, including overwatering, underwatering, poor drainage, sudden changes in temperature or light, nutrient deficiencies (especially nitrogen), or pest and disease problems. Overwatering is one of the most common causes, as it leads to root rot and prevents the plant from absorbing nutrients. Underwatering, on the other hand, causes the plant to shed leaves to conserve moisture. Environmental stress, such as drafts, low humidity, or moving the plant, can also trigger leaf drop.",
                whatToDo: "Check the soil moisture. Only water when the top inch of soil feels dry.\n- Ensure the pot has drainage holes and that excess water can escape.\n- Inspect for pests such as spider mites, aphids, or scale insects.\n- Avoid sudden changes in temperature or light.\n- Fertilize regularly during the growing season, but avoid over-fertilizing.\n- Remove yellow or fallen leaves to prevent the spread of disease.",
                tip: "Observe which leaves are affected first—older leaves dropping usually indicates a natural process or minor stress, while new growth yellowing may signal a more serious problem."
            )
        }
        if symptom.imageName == "leaves-spots" {
            return SymptomArticleContent(
                subtitle: "Your plant's leaves are developing spots or patches, which may indicate disease, pests, or environmental stress.",
                orangeHeading: "Check if your plant has the following symptoms:",
                symptomDetails: "Leaves show visible spots or patches that can be brown, black, yellow, or even white. These spots may have defined edges or appear as irregular patches. Sometimes, the affected areas are surrounded by a yellow halo, and the spots may grow larger or merge over time. Severely affected leaves may wilt, curl, or fall off.",
                body: "Spots or patches on leaves are commonly caused by fungal or bacterial infections (such as leaf spot disease, anthracnose, or powdery mildew), pest damage, or environmental factors like sunburn or chemical exposure. Fungal leaf spots often thrive in warm, humid conditions and can spread quickly if not treated. Bacterial spots may ooze or feel wet. Pests such as spider mites or thrips can also cause stippling or patchy damage. Over-fertilization or exposure to harsh chemicals can result in chemical burns that look like spots.",
                whatToDo: "Remove and dispose of affected leaves to prevent the spread of disease.\n- Avoid overhead watering and water the soil directly to keep leaves dry.\n- Improve air circulation around the plant.\n- Inspect for pests and treat with appropriate insecticides or natural remedies if needed.\n- Use a fungicide or bactericide if a disease is suspected, following label instructions.\n- Avoid using harsh chemicals or over-fertilizing.",
                tip: "Always clean your tools after pruning diseased plants to prevent spreading pathogens to healthy ones."
            )
        }
        if symptom.imageName == "leaves-curl" {
            return SymptomArticleContent(
                subtitle: "Your plant's leaves are curling, twisting, or becoming misshapen, which can be a sign of stress, pests, or disease.",
                orangeHeading: "Check if your plant has the following symptoms:",
                symptomDetails: "Leaves may curl upward or downward, twist, or develop wavy or puckered edges. The affected leaves might also appear smaller, thicker, or distorted compared to healthy leaves. In some cases, the curling is accompanied by discoloration, spots, or stunted growth.",
                body: "Leaf curling can be caused by a variety of factors. Common causes include pest infestations (such as aphids, thrips, or whiteflies), viral or fungal diseases, environmental stress (like low humidity, excessive heat, or cold drafts), or improper watering (overwatering or underwatering). Nutrient imbalances, especially calcium or magnesium deficiency, can also lead to leaf deformation. Sometimes, exposure to herbicides or other chemicals can cause similar symptoms.",
                whatToDo: "Inspect the undersides of leaves and stems for pests and treat with insecticidal soap or natural remedies if found.\n- Ensure your plant is receiving the right amount of water—keep the soil consistently moist but not soggy.\n- Increase humidity around the plant if the air is very dry.\n- Avoid exposing the plant to cold drafts or sudden temperature changes.\n- Fertilize appropriately, but avoid over-fertilizing.\n- Remove and dispose of severely affected leaves to prevent the spread of disease.",
                tip: "If only new growth is affected, check for pests or nutrient deficiencies first. If the problem persists, consider repotting the plant in fresh soil."
            )
        }
        if symptom.imageName == "stem-black" {
            return SymptomArticleContent(
                subtitle: "Your plant's stems are developing black or mushy areas, which often indicates a serious fungal or bacterial infection.",
                orangeHeading: "Check if your plant has the following symptoms:",
                symptomDetails: "Stems may show black, brown, or dark discolored areas that feel soft, mushy, or slimy to the touch. The affected areas may ooze or have a foul odor. The infection often starts at the base of the stem or at a wound site and can quickly spread upward, causing the stem to collapse or the plant to wilt.",
                body: "Black or mushy stems are typically caused by fungal or bacterial pathogens such as Pythium, Phytophthora, or Erwinia. These pathogens thrive in wet, poorly drained soil and can enter the plant through wounds, overwatering, or contaminated soil. Once the infection takes hold, it rapidly destroys the plant tissue, turning it black and mushy. Overwatering is the most common cause, as it creates ideal conditions for these pathogens to grow and spread.",
                whatToDo: "Remove the affected plant immediately to prevent the spread of disease to nearby plants.\n- Cut away any healthy parts of the plant that are not yet infected, using sterile scissors.\n- Discard the contaminated soil and thoroughly clean the pot with hot, soapy water or a diluted bleach solution.\n- Avoid reusing the soil or pot without proper sterilization.\n- To prevent future cases, always use well-draining soil, avoid overwatering, and ensure pots have drainage holes.",
                tip: "If you catch the infection early and only a small portion of the stem is affected, you may be able to save the plant by cutting away the infected area and treating the remaining healthy tissue."
            )
        }
        if symptom.imageName == "stem-lesion" {
            return SymptomArticleContent(
                subtitle: "Your plant's stems are developing lesions or cankers, which are often signs of fungal or bacterial infections.",
                orangeHeading: "Check if your plant has the following symptoms:",
                symptomDetails: "Stems show sunken, discolored areas (lesions) or raised, rough patches (cankers). These areas may be brown, black, or reddish and often have defined edges. The lesions may ooze sap or appear cracked. As the infection progresses, the stem may become weak and break easily.",
                body: "Stem lesions and cankers are typically caused by fungal pathogens like Botryosphaeria, Cytospora, or bacterial infections such as Pseudomonas. These pathogens often enter the plant through wounds, pruning cuts, or natural openings. Environmental stress, such as drought, frost damage, or poor growing conditions, can make plants more susceptible to these infections.",
                whatToDo: "Prune away infected stems, cutting well below the lesion into healthy tissue.\n- Sterilize pruning tools between cuts to prevent spreading the disease.\n- Improve air circulation around the plant.\n- Avoid overhead watering and keep the plant dry.\n- Apply a fungicide if the infection is severe, following label instructions.\n- Remove and destroy severely infected plants to prevent spread.",
                tip: "Always make clean, angled cuts when pruning and avoid leaving stubs that can become infection sites."
            )
        }
        if symptom.imageName == "stem-crack" {
            return SymptomArticleContent(
                subtitle: "Your plant's stems are cracking or splitting, which can be caused by rapid growth, environmental stress, or disease.",
                orangeHeading: "Check if your plant has the following symptoms:",
                symptomDetails: "Stems develop vertical or horizontal cracks, splits, or fissures. The cracks may be shallow or deep, and sometimes ooze sap. The affected areas may become discolored or develop callus tissue as the plant attempts to heal. In severe cases, the stem may break completely.",
                body: "Stem cracking can occur due to rapid growth spurts, especially when plants receive inconsistent watering or fertilization. Environmental factors like frost damage, wind stress, or sudden temperature changes can also cause stems to crack. Some fungal diseases can weaken stem tissue, making it more prone to cracking. Physical damage from handling or pests can also create entry points for infections.",
                whatToDo: "Provide consistent watering to prevent rapid growth spurts.\n- Protect plants from extreme temperature changes and frost.\n- Stake tall or heavy plants to reduce wind stress.\n- Apply a thin layer of grafting wax or tree wound dressing to small cracks.\n- Monitor for signs of infection at crack sites.\n- Prune away severely damaged stems if necessary.",
                tip: "Gradual hardening off of plants helps prevent stem cracking caused by sudden environmental changes."
            )
        }
        if symptom.imageName == "flower-blight" {
            return SymptomArticleContent(
                subtitle: "Your plant's flowers are wilting or developing spots, which may indicate disease or environmental stress.",
                orangeHeading: "Check if your plant has the following symptoms:",
                symptomDetails: "Flowers may appear wilted, discolored, or develop brown or black spots. The petals may become mushy or slimy, and the flowers may fail to open properly or drop prematurely. Sometimes, a gray or white fuzzy growth may appear on the affected flowers.",
                body: "Flower blight is commonly caused by fungal pathogens like Botrytis (gray mold), which thrives in cool, humid conditions. Bacterial infections can also cause similar symptoms. Environmental factors such as overhead watering, poor air circulation, or high humidity can create ideal conditions for these diseases. Overcrowding of plants can also contribute to the spread of flower blight.",
                whatToDo: "Remove and dispose of affected flowers immediately.\n- Improve air circulation around the plant.\n- Avoid overhead watering and water the soil directly.\n- Apply a fungicide if the infection is severe, following label instructions.\n- Space plants properly to reduce humidity and improve air flow.\n- Clean up fallen flowers and debris regularly.",
                tip: "Water in the morning so flowers have time to dry before evening, reducing the risk of fungal infections."
            )
        }
        if symptom.imageName == "flower-drop" {
            return SymptomArticleContent(
                subtitle: "Your plant's flowers are dropping prematurely, which can be caused by stress, disease, or environmental factors.",
                orangeHeading: "Check if your plant has the following symptoms:",
                symptomDetails: "Flowers fall off the plant before they should naturally drop. This may happen at the bud stage or after flowers have opened. The remaining flowers may appear healthy, but the plant may show other signs of stress such as yellowing leaves or stunted growth.",
                body: "Premature flower drop can be caused by various factors including environmental stress (sudden temperature changes, drafts, or low humidity), improper watering (overwatering or underwatering), nutrient deficiencies, pest infestations, or disease. Some plants are naturally sensitive to changes in their environment and will drop flowers as a stress response. Pollination issues can also cause flowers to drop if they're not properly pollinated.",
                whatToDo: "Maintain consistent temperature and humidity levels.\n- Ensure proper watering—keep soil consistently moist but not soggy.\n- Fertilize regularly with a balanced fertilizer during the growing season.\n- Check for pests and treat if necessary.\n- Avoid moving the plant during flowering.\n- Provide adequate light for the specific plant type.",
                tip: "Some plants naturally drop flowers as part of their growth cycle, so research your specific plant's normal behavior."
            )
        }
        if symptom.imageName == "fruit-rot" {
            return SymptomArticleContent(
                subtitle: "Your plant's fruits are rotting or developing mold, which indicates fungal or bacterial infection.",
                orangeHeading: "Check if your plant has the following symptoms:",
                symptomDetails: "Fruits develop soft, mushy areas that may be brown, black, or covered in mold. The affected areas may ooze or have a foul odor. The rot often starts at the blossom end or where the fruit was damaged and can quickly spread to the entire fruit.",
                body: "Fruit rot is typically caused by fungal pathogens like Botrytis, Rhizopus, or bacterial infections. These pathogens can enter through wounds, insect damage, or natural openings in the fruit. Overwatering, poor air circulation, and high humidity create ideal conditions for these diseases. Fruits that touch the soil or are overcrowded are more susceptible to rot.",
                whatToDo: "Remove and dispose of affected fruits immediately.\n- Improve air circulation around the plant.\n- Avoid overhead watering and water the soil directly.\n- Mulch around plants to prevent fruits from touching the soil.\n- Apply appropriate fungicides if the infection is severe.\n- Harvest fruits promptly when they're ripe.",
                tip: "Regular inspection and prompt removal of affected fruits can prevent the spread of rot to healthy fruits."
            )
        }
        if symptom.imageName == "fruit-spot" {
            return SymptomArticleContent(
                subtitle: "Your plant's fruits are developing spots or blemishes, which may indicate disease or pest damage.",
                orangeHeading: "Check if your plant has the following symptoms:",
                symptomDetails: "Fruits show small to large spots that may be brown, black, yellow, or white. The spots may have defined edges or appear as irregular patches. Sometimes, the spots are sunken or raised, and may be surrounded by a halo of different color.",
                body: "Fruit spots can be caused by fungal diseases like anthracnose or bacterial infections. Environmental factors such as sunscald, chemical burns, or physical damage can also cause spotting. Some spots may be purely cosmetic, while others can affect the fruit's quality and storage life. Insect feeding can also create entry points for disease organisms.",
                whatToDo: "Remove and dispose of severely affected fruits.\n- Apply appropriate fungicides or bactericides if disease is suspected.\n- Protect fruits from direct sun exposure if sunscald is the cause.\n- Avoid using harsh chemicals near fruiting plants.\n- Maintain good air circulation around the plant.\n- Harvest fruits carefully to avoid damage.",
                tip: "Some fruit spots are cosmetic and don't affect the fruit's edibility, but always inspect thoroughly before consumption."
            )
        }
        if symptom.imageName == "pest-aphid" {
            return SymptomArticleContent(
                subtitle: "Your plant is infested with small green or black insects, which are likely aphids feeding on your plant.",
                orangeHeading: "Check if your plant has the following symptoms:",
                symptomDetails: "Small, soft-bodied insects (usually green, black, or brown) cluster on new growth, stems, or the undersides of leaves. They may be winged or wingless. Aphids secrete a sticky substance called honeydew, which can attract ants and promote the growth of sooty mold. Affected leaves may curl, yellow, or become distorted.",
                body: "Aphids are common garden pests that feed by sucking sap from plants. They reproduce rapidly and can quickly infest a plant. While a few aphids may not cause significant damage, large populations can weaken plants and spread viral diseases. Aphids are often found on new growth where the plant tissue is tender and easier to penetrate.",
                whatToDo: "Spray plants with a strong stream of water to dislodge aphids.\n- Apply insecticidal soap or neem oil, following label instructions.\n- Introduce beneficial insects like ladybugs or lacewings.\n- Remove heavily infested plant parts.\n- Monitor plants regularly for early detection.\n- Use reflective mulch to deter aphids from landing.",
                tip: "Aphids often indicate that your plant is stressed or over-fertilized, so address underlying plant health issues."
            )
        }
        if symptom.imageName == "pest-mite" {
            return SymptomArticleContent(
                subtitle: "Your plant shows signs of spider mite infestation, with fine webbing and tiny moving dots on leaves.",
                orangeHeading: "Check if your plant has the following symptoms:",
                symptomDetails: "Fine, silky webbing appears on leaves, stems, or between leaves. Tiny, moving dots (mites) may be visible, especially on the undersides of leaves. Affected leaves may develop stippling (tiny yellow or white dots), turn yellow, or become bronzed. Severe infestations can cause leaves to drop.",
                body: "Spider mites are tiny arachnids that feed by piercing plant cells and sucking out the contents. They thrive in hot, dry conditions and can reproduce rapidly. Mites are often introduced on new plants or spread by wind. They prefer the undersides of leaves where they're protected from direct sunlight and predators. Heavy infestations can severely weaken plants and even kill them.",
                whatToDo: "Increase humidity around the plant, as mites prefer dry conditions.\n- Spray plants with water to dislodge mites and wash away webbing.\n- Apply miticides or insecticidal soap, following label instructions.\n- Introduce predatory mites or other beneficial insects.\n- Isolate infested plants to prevent spread.\n- Monitor plants regularly, especially during hot, dry weather.",
                tip: "Spider mites are often resistant to many pesticides, so rotating different control methods is important."
            )
        }
        if symptom.imageName == "pest-scale" {
            return SymptomArticleContent(
                subtitle: "Your plant has brown or white bumps on stems and leaves, which are scale insects feeding on your plant.",
                orangeHeading: "Check if your plant has the following symptoms:",
                symptomDetails: "Small, immobile bumps appear on stems, leaves, or leaf undersides. These bumps may be brown, white, or tan and can be flat or slightly raised. Scale insects secrete honeydew, which can attract ants and promote sooty mold growth. Affected plant parts may yellow, wilt, or die back.",
                body: "Scale insects are small, immobile pests that feed by sucking sap from plants. They have a protective covering that makes them difficult to control. Scale can be either armored (hard covering) or soft scale (waxy covering). They often cluster on stems and leaf undersides where they're protected. Heavy infestations can weaken plants and cause dieback.",
                whatToDo: "Scrape off scale insects with a soft brush or your fingernail.\n- Apply horticultural oil or insecticidal soap, following label instructions.\n- Use systemic insecticides for severe infestations.\n- Prune away heavily infested branches.\n- Monitor plants regularly for early detection.\n- Introduce beneficial insects like ladybugs.",
                tip: "Scale insects are often introduced on new plants, so inspect new additions carefully before bringing them home."
            )
        }
        return nil
    }
}

#Preview {
    SymptomArticleView(symptom: DiseaseSymptom(imageName: "pale-plant", description: "The entire plant is getting pale, and the stems are lengthening."))
} 
