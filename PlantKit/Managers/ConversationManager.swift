import SwiftUI

struct Message: Identifiable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
}

struct Conversation: Identifiable {
    let id = UUID()
    var title: String
    var messages: [Message]
    var lastMessageDate: Date
    
    init(title: String = "New Conversation", messages: [Message] = []) {
        self.title = title
        self.messages = messages
        self.lastMessageDate = messages.last?.timestamp ?? Date()
    }
}

class ConversationManager: ObservableObject {
    @Published var conversations: [Conversation] = []
    @Published var currentConversationId: UUID?
    @Published var isLoading = false
    
    var currentConversation: Conversation? {
        conversations.first { $0.id == currentConversationId }
    }
    
    init() {
        // Add a default conversation
        let newConversation = Conversation()
        conversations.append(newConversation)
        currentConversationId = newConversation.id
    }
    
    func createNewConversation() {
        let newConversation = Conversation()
        conversations.insert(newConversation, at: 0)
        currentConversationId = newConversation.id
    }
    
    func sendMessage(_ content: String) {
        guard let conversationId = currentConversationId,
              let index = conversations.firstIndex(where: { $0.id == conversationId }) else {
            return
        }
        
        // Add user message
        let userMessage = Message(content: content, isUser: true, timestamp: Date())
        conversations[index].messages.append(userMessage)
        conversations[index].lastMessageDate = userMessage.timestamp
        
        // Update conversation title if it's the first message
        if conversations[index].messages.count == 1 {
            conversations[index].title = content
        }
        
        // Simulate bot response (in a real app, this would call an API)
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self,
                  let conversationIndex = self.conversations.firstIndex(where: { $0.id == conversationId }) else {
                return
            }
            
            let botResponse = Message(
                content: "I'm a plant expert bot. I can help you with your plant-related questions!",
                isUser: false,
                timestamp: Date()
            )
            self.conversations[conversationIndex].messages.append(botResponse)
            self.conversations[conversationIndex].lastMessageDate = botResponse.timestamp
            self.isLoading = false
        }
    }
    
    func switchConversation(to id: UUID) {
        currentConversationId = id
    }
    
    func deleteConversation(_ id: UUID) {
        conversations.removeAll { $0.id == id }
        if currentConversationId == id {
            currentConversationId = conversations.first?.id
        }
    }
} 