import SwiftUI
import CoreData

// MARK: - Message Model
struct ChatMessage: Identifiable {
    let id: String
    let content: String
    let isUser: Bool
    let timestamp: Date
    
    init(from coreDataMessage: Message) {
        self.id = coreDataMessage.id
        self.content = coreDataMessage.content
        self.isUser = coreDataMessage.isUser
        self.timestamp = coreDataMessage.createdAt
    }
    
    init(content: String, isUser: Bool, timestamp: Date = Date()) {
        self.id = UUID().uuidString
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
    }
}

// MARK: - Conversation Model
struct ChatConversation: Identifiable {
    let id: String
    var title: String
    var plantName: String?
    var messages: [ChatMessage]
    var lastMessageDate: Date
    var createdAt: Date
    
    init(from coreDataConversation: Conversation) {
        self.id = coreDataConversation.id
        self.title = coreDataConversation.title
        self.plantName = coreDataConversation.plantName
        self.lastMessageDate = coreDataConversation.lastMessageDate
        self.createdAt = coreDataConversation.createdAt
        
        // Convert CoreData messages to ChatMessage array
        let coreDataMessages = CoreDataManager.shared.fetchMessages(for: coreDataConversation)
        self.messages = coreDataMessages.map { ChatMessage(from: $0) }
    }
    
    init(title: String = "New Conversation", plantName: String? = nil, messages: [ChatMessage] = []) {
        self.id = UUID().uuidString
        self.title = title
        self.plantName = plantName
        self.messages = messages
        self.lastMessageDate = messages.last?.timestamp ?? Date()
        self.createdAt = Date()
    }
}

class ConversationManager: ObservableObject {
    @Published var conversations: [ChatConversation] = []
    @Published var currentConversationId: String?
    @Published var isLoading = false
    
    private let coreDataManager = CoreDataManager.shared
    
    var currentConversation: ChatConversation? {
        conversations.first { $0.id == currentConversationId }
    }
    
    init() {
        loadConversations()
    }
    
    // MARK: - CoreData Operations
    
    private func loadConversations() {
        let coreDataConversations = coreDataManager.fetchConversations()
        conversations = coreDataConversations.map { ChatConversation(from: $0) }
        
        // Clean up empty conversations
        coreDataManager.deleteEmptyConversations()
    }
    
    private func saveConversation(_ conversation: ChatConversation) -> Conversation? {
        guard let coreDataConversation = coreDataManager.createConversation(
            title: conversation.title,
            plantName: conversation.plantName
        ) else {
            print("Failed to create conversation in CoreData")
            return nil
        }
        
        // Save all messages
        for message in conversation.messages {
            coreDataManager.addMessage(
                to: coreDataConversation,
                content: message.content,
                isUser: message.isUser
            )
        }
        
        return coreDataConversation
    }
    
    private func updateConversationInCoreData(_ conversation: ChatConversation) {
        // Find the CoreData conversation
        let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", conversation.id)
        
        do {
            let coreDataConversations = try coreDataManager.viewContext.fetch(request)
            guard let coreDataConversation = coreDataConversations.first else { return }
            
            // Update title and last message date
            coreDataConversation.title = conversation.title
            coreDataConversation.lastMessageDate = conversation.lastMessageDate
            
            // Add new messages
            let existingMessageIds = Set(coreDataManager.fetchMessages(for: coreDataConversation).map { $0.id })
            let newMessages = conversation.messages.filter { !existingMessageIds.contains($0.id) }
            
            for message in newMessages {
                coreDataManager.addMessage(
                    to: coreDataConversation,
                    content: message.content,
                    isUser: message.isUser
                )
            }
            
            coreDataManager.saveContext()
        } catch {
            print("Error updating conversation in CoreData: \(error)")
        }
    }
    
    // MARK: - Public Methods
    
    func createNewConversation(plantName: String? = nil) -> ChatConversation {
        let newConversation = ChatConversation(title: "AI Botanist", plantName: plantName)
        conversations.insert(newConversation, at: 0)
        currentConversationId = newConversation.id
        return newConversation
    }
    
    func sendMessage(_ content: String, plantDetails: PlantDetails? = nil) {
        guard let conversationId = currentConversationId,
              let index = conversations.firstIndex(where: { $0.id == conversationId }) else {
            return
        }
        
        // Add user message
        let userMessage = ChatMessage(content: content, isUser: true)
        conversations[index].messages.append(userMessage)
        conversations[index].lastMessageDate = userMessage.timestamp
        
        // Set conversation title to "AI Botanist" if it's the first message
        if conversations[index].messages.count == 1 {
            conversations[index].title = "AI Botanist"
        }
        
        // Save to CoreData if this is the first message
        if conversations[index].messages.count == 1 {
            _ = saveConversation(conversations[index])
        } else {
            updateConversationInCoreData(conversations[index])
        }
        
        // Call askBotanist API
        isLoading = true
        askBotanist(message: content, plantDetails: plantDetails) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self,
                      let conversationIndex = self.conversations.firstIndex(where: { $0.id == conversationId }) else {
                    return
                }
                
                switch result {
                case .success(let reply):
                    let botResponse = ChatMessage(content: reply, isUser: false)
                    self.conversations[conversationIndex].messages.append(botResponse)
                    self.conversations[conversationIndex].lastMessageDate = botResponse.timestamp
                    
                    // Update CoreData
                    self.updateConversationInCoreData(self.conversations[conversationIndex])
                    
                case .failure(let error):
                    let errorMessage = ChatMessage(
                        content: "Sorry, something went wrong: \(error.localizedDescription)",
                        isUser: false
                    )
                    self.conversations[conversationIndex].messages.append(errorMessage)
                    self.conversations[conversationIndex].lastMessageDate = errorMessage.timestamp
                    
                    // Update CoreData
                    self.updateConversationInCoreData(self.conversations[conversationIndex])
                }
                self.isLoading = false
            }
        }
    }
    
    private func askBotanist(message: String, plantDetails: PlantDetails? = nil, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://us-central1-plantkit-c6c69.cloudfunctions.net/askBotanist") else {
            completion(.failure(NSError(domain: "URL", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 60
        
        let messageToSend: String
        if let details = plantDetails {
            messageToSend = "Plant: \(details.commonName) (\(details.scientificName))\n\nUser: \(message)"
        } else {
            messageToSend = message
        }
        
        let body: [String: Any] = ["message": messageToSend]
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
    
    func switchConversation(to id: String) {
        currentConversationId = id
    }
    
    func deleteConversation(_ id: String) {
        // Remove from CoreData
        let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            let coreDataConversations = try coreDataManager.viewContext.fetch(request)
            if let conversationToDelete = coreDataConversations.first {
                coreDataManager.deleteConversation(conversationToDelete)
            }
        } catch {
            print("Error deleting conversation from CoreData: \(error)")
        }
        
        // Remove from local array
        conversations.removeAll { $0.id == id }
        if currentConversationId == id {
            currentConversationId = conversations.first?.id
        }
    }
    
    func loadConversationsForPlant(_ plantName: String) {
        let coreDataConversations = coreDataManager.fetchConversations(for: plantName)
        conversations = coreDataConversations.map { ChatConversation(from: $0) }
    }
    
    func refreshConversations() {
        loadConversations()
    }
} 
