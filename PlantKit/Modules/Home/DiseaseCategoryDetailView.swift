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
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 0) {
                tabPickerView
                    .padding(.top, 32)
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
            
            // Custom navigation bar
            VStack(spacing: 0) {
                HStack {
                    // Custom back button
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
                    
                    Spacer()
                    
                    // Custom title
                    Text("Common Plant Diseases")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Invisible spacer to center the title
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 36, height: 36)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                Spacer()
            }
        }
        .background(EnableSwipeBack())
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            // Auto-scroll to the selected category when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    selectedCategory = selectedCategory
                }
            }
        }
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
            .onAppear {
                // Scroll to the initial selected category
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(selectedCategory, anchor: .center)
                    }
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
                                .font(.system(size: 17))
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
