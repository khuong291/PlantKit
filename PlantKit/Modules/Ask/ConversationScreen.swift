import SwiftUI

struct ConversationScreen: View {
    let conversationId: UUID
    @EnvironmentObject var conversationManager: ConversationManager
    @Environment(\.dismiss) private var dismiss
    @State private var messageText = ""
    
    private var conversation: Conversation? {
        conversationManager.conversations.first { $0.id == conversationId }
    }
    
    var body: some View {
        ZStack {
            Color.appScreenBackgroundColor
                .edgesIgnoringSafeArea(.all)
            VStack(spacing: 0) {
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
                
                // Message input bar
                HStack(spacing: 12) {
                    TextField("Ask about your plants...", text: $messageText)
                        .padding(12)
                        .background(Color.white)
                        .cornerRadius(20)
                    
                    Button {
                        if !messageText.isEmpty {
                            conversationManager.sendMessage(messageText)
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
    }
    
    private var emptyView: some View {
        VStack(spacing: 10) {
            Image(systemSymbol: .bubbleLeftAndBubbleRightFill)
                .font(.title)
                .foregroundStyle(.green)
            Text("No messages yet. Ask anything about your plants!")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
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
                        Spacer()
                        ProgressView()
                            .padding()
                        Spacer()
                    }
                }
            }
        }
    }
}

struct ChatBubble: View {
    let message: String
    let isUser: Bool
    let timestamp: Date
    
    var body: some View {
        HStack {
            if isUser { Spacer() }
            
            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(message)
                    .padding(12)
                    .background(isUser ? Color.green : Color.white)
                    .foregroundColor(isUser ? .white : .primary)
                    .cornerRadius(16)
                
                Text(timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            if !isUser { Spacer() }
        }
    }
}

#Preview {
    NavigationView {
        ConversationScreen(conversationId: UUID())
            .environmentObject(ConversationManager())
    }
} 