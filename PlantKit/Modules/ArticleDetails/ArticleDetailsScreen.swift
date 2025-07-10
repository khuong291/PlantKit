import SwiftUI

struct ArticleDetailsScreen: View {
    let article: ArticleDetails
    @EnvironmentObject var homeRouter: Router<ContentRoute>
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.appScreenBackgroundColor
                .edgesIgnoringSafeArea(.all)
            content
            
            // Fixed close button on top
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15))
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
                .padding(.trailing, 8)
                .padding(.top, 14)
                Spacer()
            }
            .padding(.horizontal)
        }
        .navigationBarBackButtonHidden(true)
    }
    
    private var content: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                headerImageView
                VStack(alignment: .leading, spacing: 20) {
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
                    .padding(.horizontal)
                    .padding(.top, 20)
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
                    .padding(.horizontal)
                    .padding(.bottom, 40)
                }
            }
            .padding(.bottom)
        }
        .scrollIndicators(.hidden)
        .edgesIgnoringSafeArea(.top)
    }

    private var headerImageView: some View {
        ZStack(alignment: .topTrailing) {
            Image(article.imageName)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.width - 100)
                .clipped()
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    ArticleDetailsScreen(article: ArticleDetails.sampleArticles[0])
} 
