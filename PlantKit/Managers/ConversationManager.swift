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
    
    func createNewConversation() -> Conversation {
        let newConversation = Conversation()
        conversations.insert(newConversation, at: 0)
        currentConversationId = newConversation.id
        return newConversation
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
        
        // Call askBotanist API
        isLoading = true
        askBotanist(message: content) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self,
                      let conversationIndex = self.conversations.firstIndex(where: { $0.id == conversationId }) else {
                    return
                }
                switch result {
                case .success(let reply):
                    let botResponse = Message(
                        content: reply,
                        isUser: false,
                        timestamp: Date()
                    )
                    self.conversations[conversationIndex].messages.append(botResponse)
                    self.conversations[conversationIndex].lastMessageDate = botResponse.timestamp
                case .failure(let error):
                    let errorMessage = Message(
                        content: "Sorry, something went wrong: \(error.localizedDescription)",
                        isUser: false,
                        timestamp: Date()
                    )
                    self.conversations[conversationIndex].messages.append(errorMessage)
                    self.conversations[conversationIndex].lastMessageDate = errorMessage.timestamp
                }
                self.isLoading = false
            }
        }
    }
    
    private func askBotanist(message: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://us-central1-plantkit-c6c69.cloudfunctions.net/askBotanist") else {
            completion(.failure(NSError(domain: "URL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60
        let body: [String: Any] = ["message": message]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            completion(.failure(error))
            return
        }
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "NoData", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received."])))
                return
            }
            do {
                if let errorResponse = try? JSONDecoder().decode([String: String].self, from: data),
                   let errorMessage = errorResponse["error"] {
                    completion(.failure(NSError(domain: "APIError", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMessage])))
                    return
                }
                let result = try JSONDecoder().decode([String: String].self, from: data)
                if let reply = result["reply"] {
                    completion(.success(reply))
                } else {
                    completion(.failure(NSError(domain: "InvalidResponse", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid response format."])))
                }
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
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
