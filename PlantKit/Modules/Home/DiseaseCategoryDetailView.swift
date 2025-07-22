import SwiftUI

struct DiseaseCategoryDetailView: View {
    @State private var selectedCategory: DiseaseCategory
    let symptomsByCategory: [DiseaseCategory: [DiseaseSymptom]]
    let onBack: () -> Void
    
    init(category: DiseaseCategory, symptoms: [DiseaseSymptom], onBack: @escaping () -> Void) {
        self._selectedCategory = State(initialValue: category)
        var dict = [DiseaseCategory: [DiseaseSymptom]]()
        for cat in DiseaseCategory.allCases {
            dict[cat] = diseaseSymptoms[cat] ?? []
        }
        self.symptomsByCategory = dict
        self.onBack = onBack
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            headerView
            tabPickerView
            symptomsListView
            Spacer()
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
    
    private var headerView: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            Text("Common Plant Diseases")
                .font(.title2)
                .bold()
            Spacer()
        }
        .padding(.vertical)
    }
    
    private var tabPickerView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                ForEach(DiseaseCategory.allCases) { category in
                    tabButton(for: category)
                }
            }
            .padding(.horizontal, 8)
        }
        .padding(.bottom, 12)
    }
    
    private func tabButton(for category: DiseaseCategory) -> some View {
        Button(action: {
            withAnimation(.spring()) {
                selectedCategory = category
            }
        }) {
            VStack(spacing: 4) {
                Text(category.rawValue)
                    .font(.system(size: 17, weight: selectedCategory == category ? .bold : .regular))
                    .foregroundColor(selectedCategory == category ? Color("AppPrimaryColor") : .primary)
                
                if selectedCategory == category {
                    Capsule()
                        .fill(Color("AppPrimaryColor"))
                        .frame(height: 3)
                } else {
                    Color.clear.frame(height: 3)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var symptomsListView: some View {
        ForEach(symptomsByCategory[selectedCategory] ?? []) { symptom in
            HStack(alignment: .top, spacing: 12) {
                Image(symptom.imageName)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                Text(symptom.description)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.top, 8)
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    DiseaseCategoryDetailView(
        category: .wholePlant,
        symptoms: diseaseSymptoms[.wholePlant] ?? [],
        onBack: {}
    )
} 