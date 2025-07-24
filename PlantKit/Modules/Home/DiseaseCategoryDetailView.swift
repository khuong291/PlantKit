import SwiftUI

struct DiseaseCategoryDetailView: View {
    @EnvironmentObject var homeRouter: Router<ContentRoute>
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
        VStack(alignment: .leading, spacing: 0) {
            tabPickerView
            TabView(selection: $selectedCategory) {
                ForEach(DiseaseCategory.allCases) { category in
                    symptomsListView(for: category)
                        .tag(category)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .animation(.easeInOut, value: selectedCategory)
            Spacer()
        }
        .padding()
        .background(Color.appScreenBackgroundColor)
        .navigationBarBackButtonHidden(false)
        .navigationTitle("Common Plant Diseases")
        .tint(.green)
    }
    
    private var tabPickerView: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 24) {
                    ForEach(DiseaseCategory.allCases) { category in
                        tabButton(for: category)
                            .id(category)
                    }
                }
            }
            .padding(.bottom, 12)
            .onChange(of: selectedCategory) { newCategory in
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo(newCategory, anchor: .center)
                }
            }
        }
    }
    
    private func tabButton(for category: DiseaseCategory) -> some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.3)) {
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
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.clear)
                    .contentShape(Rectangle())
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func symptomsListView(for category: DiseaseCategory) -> some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(symptomsByCategory[category] ?? []) { symptom in
                    Button {
                        homeRouter.navigate(to: .diseaseSymptomArticle(symptom))
                    } label: {
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
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.top, 8)
        }
    }
}

#Preview {
    DiseaseCategoryDetailView(
        category: .wholePlant,
        symptoms: diseaseSymptoms[.wholePlant] ?? []
    )
} 
