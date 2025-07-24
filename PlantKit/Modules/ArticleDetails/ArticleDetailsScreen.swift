import SwiftUI

struct ArticleDetailsScreen: View {
    let article: ArticleDetails
    @EnvironmentObject var homeRouter: Router<ContentRoute>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.appScreenBackgroundColor
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                ZStack(alignment: .top) {
                    // Header image
                    Image(article.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: UIScreen.main.bounds.width)
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

                            // Article Metadata
                            VStack(alignment: .leading, spacing: 8) {
                                Text(article.category)
                                    .font(.system(size: 14))
                                    .foregroundColor(.blue)
                                    .bold()
                                Text(article.title)
                                    .font(.system(size: 24))
                                    .bold()
                                    .foregroundColor(.primary)
                                HStack {
                                    Text(article.author)
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(article.readingMinutes) min read")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondary)
                                }
                                Text(article.publishDate)
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                            
                            // Article Content
                            VStack(alignment: .leading, spacing: 18) {
                                ForEach(article.content, id: \.self) { paragraph in
                                    VStack(alignment: .leading, spacing: 4) {
                                        if let title = paragraph.title {
                                            Text(title)
                                                .font(.system(size: 20, weight: .bold))
                                                .padding(.vertical, 6)
                                        }
                                        Text(paragraph.body)
                                            .font(.system(size: 15))
                                    }
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
            .padding(.leading, 16)
            .padding(.top, 44) // For safe area
        }
        .background(EnableSwipeBack())
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ArticleDetailsScreen(article: ArticleDetails.sampleArticles[0])
} 
