import SwiftUI
import CoreData

// MARK: - Message Model
struct ChatMessage: Identifiable {
    let id: String
    let content: String
    let isUser: Bool
    let timestamp: Date
    let imageData: Data?
    
    init(from coreDataMessage: Message) {
        self.id = coreDataMessage.id
        self.content = coreDataMessage.content
        self.isUser = coreDataMessage.isUser
        self.timestamp = coreDataMessage.createdAt
        self.imageData = coreDataMessage.imageData
    }
    
    init(content: String, isUser: Bool, timestamp: Date = Date(), imageData: Data? = nil) {
        self.id = UUID().uuidString
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
        self.imageData = imageData
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
        print("🔄 Fetching messages for conversation: \(coreDataConversation.id)")
        let coreDataMessages = CoreDataManager.shared.fetchMessages(for: coreDataConversation)
        print("📊 Found \(coreDataMessages.count) CoreData messages")
        
        self.messages = coreDataMessages.map { coreDataMessage in
            print("📝 Converting message: \(coreDataMessage.id) - \(coreDataMessage.isUser ? "User" : "Bot") - \(coreDataMessage.content.prefix(30))...")
            return ChatMessage(from: coreDataMessage)
        }
        
        print("✅ Converted \(self.messages.count) messages for conversation: \(self.id)")
    }
    
    init(title: String = "New Conversation", plantName: String? = nil, messages: [ChatMessage] = []) {
        self.id = UUID().uuidString
        self.title = title
        self.plantName = plantName
        self.messages = messages
        self.lastMessageDate = messages.last?.timestamp ?? Date()
        self.createdAt = Date()
    }
    
    init(id: String, title: String, plantName: String?, messages: [ChatMessage], lastMessageDate: Date, createdAt: Date) {
        self.id = id
        self.title = title
        self.plantName = plantName
        self.messages = messages
        self.lastMessageDate = lastMessageDate
        self.createdAt = createdAt
    }
}

class ConversationManager: ObservableObject {
    @Published var conversations: [ChatConversation] = []
    @Published var currentConversationId: String? {
        didSet {
            if let id = currentConversationId {
                UserDefaults.standard.set(id, forKey: "currentConversationId")
            } else {
                UserDefaults.standard.removeObject(forKey: "currentConversationId")
            }
        }
    }
    @Published var isLoading = false
    
    private let coreDataManager = CoreDataManager.shared
    
    var currentConversation: ChatConversation? {
        conversations.first { $0.id == currentConversationId }
    }
    
    init() {
        // Load currentConversationId from UserDefaults
        currentConversationId = UserDefaults.standard.string(forKey: "currentConversationId")
        
        loadConversations()
        
        // Listen for app becoming active to refresh conversations
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.refreshConversations()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - CoreData Operations
    
    private func loadConversations() {
        print("🔄 Loading conversations from CoreData...")
        let coreDataConversations = coreDataManager.fetchConversations()
        print("📊 Found \(coreDataConversations.count) conversations in CoreData")
        
        conversations = coreDataConversations.map { coreDataConversation in
            print("📝 Converting conversation: \(coreDataConversation.id) - \(coreDataConversation.title)")
            let chatConversation = ChatConversation(from: coreDataConversation)
            print("📝 Conversation has \(chatConversation.messages.count) messages")
            for (index, message) in chatConversation.messages.enumerated() {
                print("📝 Message \(index + 1): \(message.isUser ? "User" : "Bot") - \(message.content.prefix(50))...")
            }
            return chatConversation
        }
        
        print("✅ Loaded \(conversations.count) conversations with total \(conversations.reduce(0) { $0 + $1.messages.count }) messages")
        
        // Clean up empty conversations and duplicate messages
        cleanupEmptyConversations()
        cleanupDuplicateMessages()
    }
    
    private func cleanupEmptyConversations() {
        let emptyConversations = conversations.filter { $0.messages.isEmpty }
        for emptyConversation in emptyConversations {
            deleteConversation(emptyConversation.id)
        }
    }
    
    private func cleanupDuplicateMessages() {
        print("🧹 Cleaning up duplicate messages...")
        
        for conversation in conversations {
            let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", conversation.id)
            
            do {
                let coreDataConversations = try coreDataManager.viewContext.fetch(request)
                guard let coreDataConversation = coreDataConversations.first else { continue }
                
                let messages = coreDataManager.fetchMessages(for: coreDataConversation)
                var seenContents: Set<String> = []
                var messagesToDelete: [Message] = []
                
                for message in messages {
                    let contentKey = "\(message.isUser)_\(message.content.trimmingCharacters(in: .whitespacesAndNewlines))"
                    if seenContents.contains(contentKey) {
                        messagesToDelete.append(message)
                        print("🗑️ Found duplicate message: \(message.id) - \(message.content.prefix(30))...")
                    } else {
                        seenContents.insert(contentKey)
                    }
                }
                
                // Delete duplicate messages
                for message in messagesToDelete {
                    coreDataManager.viewContext.delete(message)
                }
                
                if !messagesToDelete.isEmpty {
                    coreDataManager.saveContext()
                    print("✅ Deleted \(messagesToDelete.count) duplicate messages from conversation: \(conversation.id)")
                }
                
            } catch {
                print("❌ Error cleaning up duplicate messages: \(error)")
            }
        }
    }
    
    private func saveConversation(_ conversation: ChatConversation) -> Conversation? {
        print("💾 Saving new conversation to CoreData: \(conversation.id)")
        
        guard let coreDataConversation = coreDataManager.createConversation(
            title: conversation.title,
            plantName: conversation.plantName,
            id: conversation.id
        ) else {
            print("❌ Failed to create conversation in CoreData")
            return nil
        }
        
        print("✅ Created CoreData conversation with ID: \(coreDataConversation.id)")
        
        // Save all messages
        for message in conversation.messages {
            coreDataManager.addMessage(
                to: coreDataConversation,
                content: message.content,
                isUser: message.isUser,
                imageData: message.imageData
            )
        }
        
        return coreDataConversation
    }
    
    private func updateConversationInCoreData(_ conversation: ChatConversation) {
        print("🔄 Starting updateConversationInCoreData for conversation: \(conversation.id)")
        
        // Find the CoreData conversation
        let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", conversation.id)
        
        do {
            let coreDataConversations = try coreDataManager.viewContext.fetch(request)
            print("🔍 Found \(coreDataConversations.count) CoreData conversations with ID: \(conversation.id)")
            
            guard let coreDataConversation = coreDataConversations.first else { 
                print("❌ Could not find CoreData conversation with ID: \(conversation.id)")
                return 
            }
            
            print("✅ Found CoreData conversation: \(coreDataConversation.id)")
            
            // Update title and last message date
            coreDataConversation.title = conversation.title
            coreDataConversation.lastMessageDate = conversation.lastMessageDate
            
            // Get existing message IDs from CoreData
            let existingMessages = coreDataManager.fetchMessages(for: coreDataConversation)
            let existingMessageIds = Set(existingMessages.map { $0.id })
            
            print("📊 Existing message IDs in CoreData: \(existingMessageIds)")
            
            // Find new messages that don't exist in CoreData
            let newMessages = conversation.messages.filter { !existingMessageIds.contains($0.id) }
            
            print("📝 Updating conversation: \(conversation.id)")
            print("📝 Total messages in conversation: \(conversation.messages.count)")
            print("📝 Existing messages in CoreData: \(existingMessages.count)")
            print("📝 New messages to save: \(newMessages.count)")
            
            // Add new messages to CoreData
            for message in newMessages {
                print("📝 Saving message: \(message.id) - \(message.isUser ? "User" : "Bot") - \(message.content.prefix(50))...")
                coreDataManager.addMessage(
                    to: coreDataConversation,
                    content: message.content,
                    isUser: message.isUser,
                    imageData: message.imageData
                )
            }
            
            coreDataManager.saveContext()
            print("✅ Successfully updated conversation in CoreData")
            
            // Verify the save worked by fetching again
            let verifyMessages = coreDataManager.fetchMessages(for: coreDataConversation)
            print("🔍 Verification: CoreData now has \(verifyMessages.count) messages")
            
        } catch {
            print("❌ Error updating conversation in CoreData: \(error)")
        }
    }
    
    // MARK: - Public Methods
    
    func createNewConversation(plantName: String? = nil) -> ChatConversation {
        let newConversation = ChatConversation(title: "AI Botanist", plantName: plantName)
        conversations.insert(newConversation, at: 0)
        currentConversationId = newConversation.id
        return newConversation
    }
    
    func sendMessage(_ content: String, plantDetails: PlantDetails? = nil, imageData: Data? = nil) {
        guard let conversationId = currentConversationId else {
            print("❌ No current conversation ID")
            return
        }
        
        // Check if conversation exists in local array
        var conversationIndex = conversations.firstIndex(where: { $0.id == conversationId })
        
        // If conversation doesn't exist locally, try to load it from CoreData
        if conversationIndex == nil {
            print("🔄 Conversation not found locally, loading from CoreData: \(conversationId)")
            let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", conversationId)
            
            do {
                let coreDataConversations = try coreDataManager.viewContext.fetch(request)
                if let coreDataConversation = coreDataConversations.first {
                    let chatConversation = ChatConversation(from: coreDataConversation)
                    conversations.insert(chatConversation, at: 0)
                    conversationIndex = 0
                    print("✅ Loaded conversation from CoreData: \(conversationId)")
                } else {
                    print("❌ Conversation not found in CoreData: \(conversationId)")
                    return
                }
            } catch {
                print("❌ Error loading conversation from CoreData: \(error)")
                return
            }
        }
        
        guard let index = conversationIndex else {
            print("❌ Could not find or load conversation: \(conversationId)")
            return
        }
        
        // Add user message
        let userMessage = ChatMessage(content: content, isUser: true, imageData: imageData)
        conversations[index].messages.append(userMessage)
        conversations[index].lastMessageDate = userMessage.timestamp
        
        // Set conversation title to "AI Botanist" if it's the first message
        if conversations[index].messages.count == 1 {
            conversations[index].title = "AI Botanist"
        }
        
        // Save to CoreData if this is the first message
        if conversations[index].messages.count == 1 {
            print("💾 First message - saving conversation to CoreData")
            _ = saveConversation(conversations[index])
        }
        // Note: We don't call updateConversationInCoreData here because the user message is already saved
        
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
                    print("🤖 Bot response received: \(reply.prefix(50))...")
                    let botResponse = ChatMessage(content: reply, isUser: false)
                    print("🤖 Created bot message with ID: \(botResponse.id)")
                    
                    self.conversations[conversationIndex].messages.append(botResponse)
                    self.conversations[conversationIndex].lastMessageDate = botResponse.timestamp
                    
                    print("🤖 Added bot message to conversation. Total messages: \(self.conversations[conversationIndex].messages.count)")
                    print("🤖 Conversation ID: \(self.conversations[conversationIndex].id)")
                    
                    // Update CoreData with the new bot response
                    self.updateConversationInCoreData(self.conversations[conversationIndex])
                    
                case .failure(let error):
                    print("❌ API error: \(error.localizedDescription)")
                    let errorMessage = ChatMessage(
                        content: "Sorry, something went wrong: \(error.localizedDescription)",
                        isUser: false
                    )
                    self.conversations[conversationIndex].messages.append(errorMessage)
                    self.conversations[conversationIndex].lastMessageDate = errorMessage.timestamp
                    
                    // Update CoreData with the error message
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
        print("🔄 Refreshing conversations...")
        loadConversations()
    }
} 
