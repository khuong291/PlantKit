import SwiftUI
import PhotosUI

struct ConversationScreen: View {
    let conversationId: String
    let plantDetails: PlantDetails?
    
    @EnvironmentObject var conversationManager: ConversationManager
    @Environment(\.dismiss) private var dismiss
    @State private var messageText = ""
    @State private var scrollProxy: ScrollViewProxy? = nil
    // Image functionality hidden for future use
    // @State private var selectedImage: PhotosPickerItem?
    // @State private var selectedImageData: Data?
    // @State private var showingImagePicker = false
    
    private var conversation: ChatConversation? {
        conversationManager.conversations.first { $0.id == conversationId }
    }
    
    var body: some View {
        ZStack {
            Color.appScreenBackgroundColor
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            if let conversation = conversation {
                                if conversation.messages.isEmpty {
                                    Spacer()
                                    emptyView
                                        .frame(maxWidth: .infinity)
                                    Spacer()
                                } else {
                                    conversationList
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height - 100)
                    }
                    .frame(maxWidth: .infinity)
                    .onAppear {
                        scrollProxy = proxy
                        scrollToBottom()
                    }
                    .onChange(of: conversation?.messages.count) { _ in
                        scrollToBottom()
                    }
                }
                
                // Message input bar
                HStack(spacing: 12) {
                    TextField("Ask about your plants...", text: $messageText)
                        .font(.system(size: 17))
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(20)
                    
                    Button {
                        if !messageText.isEmpty {
                            conversationManager.sendMessage(messageText, plantDetails: plantDetails)
                            messageText = ""
                            Haptics.shared.play()
                        }
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.green)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.white)
                .overlay(
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.gray.opacity(0.2)),
                    alignment: .top
                )
            }
        }
        .navigationTitle(conversation?.title ?? "Conversation")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            conversationManager.currentConversationId = conversationId
        }
    }
    
    private func scrollToBottom() {
        withAnimation {
            scrollProxy?.scrollTo("bottom", anchor: .bottom)
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 10) {
            Image(systemSymbol: .bubbleLeftAndBubbleRightFill)
                .font(.system(size: 28))
                .foregroundStyle(.green)
            Text("No messages yet. Ask anything about your plants!")
                .font(.system(size: 17))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    private var conversationList: some View {
        VStack(spacing: 16) {
            if let conversation = conversation {
                ForEach(conversation.messages) { message in
                    ChatBubble(
                        message: message.content,
                        isUser: message.isUser,
                        timestamp: message.timestamp
                    )
                }
                
                if conversationManager.isLoading {
                    HStack {
                        TypingIndicator()
                        Spacer()
                    }
                }
                
                Color.clear
                    .frame(height: 1)
                    .id("bottom")
            }
        }
    }
}

struct TypingIndicator: View {
    @State private var animationOffset = 0.0
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image("ic-tool-ask")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .clipShape(Circle())
            
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 8, height: 8)
                        .offset(y: animationOffset)
                        .animation(
                            Animation.easeInOut(duration: 0.5)
                                .repeatForever()
                                .delay(0.2 * Double(index)),
                            value: animationOffset
                        )
                }
            }
            .padding(12)
            .background(Color.white)
            .cornerRadius(16)
            
            Spacer()
        }
        .onAppear {
            animationOffset = -5
        }
    }
}

struct ChatBubble: View {
    let message: String
    let isUser: Bool
    let timestamp: Date
    // Image functionality hidden for future use
    // let imageData: Data?
    
    var body: some View {
        HStack(alignment: .top) {
            if !isUser {
                Image("ic-tool-ask")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    // Image display hidden for future use
                    // if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                    //     Image(uiImage: uiImage)
                    //         .resizable()
                    //         .scaledToFit()
                    //         .frame(maxWidth: 200, maxHeight: 200)
                    //         .cornerRadius(12)
                    // }
                    
                    Text(message)
                        .font(.system(size: 17))
                        .padding(12)
                        .background(Color.white)
                        .foregroundColor(.primary)
                        .cornerRadius(16)
                    
                    Text(timestamp, style: .time)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
                Spacer()
            } else {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    // Image display hidden for future use
                    // if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                    //     Image(uiImage: uiImage)
                    //         .resizable()
                    //         .scaledToFit()
                    //         .frame(maxWidth: 200, maxHeight: 200)
                    //         .cornerRadius(12)
                    // }
                    
                    Text(message)
                        .font(.system(size: 17))
                        .padding(12)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                    
                    Text(timestamp, style: .time)
                        .font(.system(size: 11))
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        ConversationScreen(conversationId: UUID().uuidString, plantDetails: nil)
            .environmentObject(ConversationManager())
    }
} 
