import SwiftUI

struct DiseaseCategoryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedCategory: DiseaseCategory
    let symptomsByCategory: [DiseaseCategory: [DiseaseSymptom]]
    
    init(category: DiseaseCategory, symptoms: [DiseaseSymptom]) {
        self._selectedCategory = State(initialValue: category)
        var dict = [DiseaseCategory: [DiseaseSymptom]]()
        for cat in DiseaseCategory.allCases {
            dict[cat] = diseaseSymptoms[cat] ?? []
        }
        self.symptomsByCategory = dict
    }
    
    var body: some View {
        ZStack {
            Color.appScreenBackgroundColor
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading) {
                tabPickerView
                symptomsListView
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Common Diseases")
    }
    
    private var headerView: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.primary)
            }
            Text("Common Plant Diseases")
                .font(.title2)
                .bold()
            Spacer()
        }
        .padding(.bottom)
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
            withAnimation(.easeIn(duration: 0.3)) {
                selectedCategory = category
            }
        }) {
            VStack(spacing: 4) {
                Text(category.rawValue)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(selectedCategory == category ? Color.green : .secondary)
                
                if selectedCategory == category {
                    Capsule()
                        .fill(Color.green)
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
                Spacer()
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
}

#Preview {
    DiseaseCategoryDetailView(
        category: .wholePlant,
        symptoms: diseaseSymptoms[.wholePlant] ?? []
    )
} 
