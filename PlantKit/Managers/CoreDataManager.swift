import CoreData
import SwiftUI

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {
        // Load persistent stores
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        
        // Configure the view context
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "PlantKit")
        return container
    }()
    
    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }
    
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }
    
    // MARK: - Plant Operations
    
    func savePlant(details: PlantDetails) {
        let plant = Plant(context: viewContext)
        plant.id = details.id.uuidString
        plant.commonName = details.commonName
        plant.scientificName = details.scientificName
        plant.plantDescription = details.plantDescription
        plant.plantImage = details.plantImageData
        plant.createdAt = details.createdAt
        plant.updatedAt = details.updatedAt
        plant.scannedAt = details.createdAt // or Date() if you want now
        // General
        plant.generalHabitat = details.general.habitat
        plant.generalOriginCountries = details.general.originCountries.joined(separator: ", ")
        plant.generalEnvironmentalBenefits = details.general.environmentalBenefits.joined(separator: ", ")
        // Physical
        plant.physicalHeight = details.physical.height
        plant.physicalCrownDiameter = details.physical.crownDiameter
        plant.physicalForm = details.physical.form
        // Development
        plant.developmentMatureHeightTime = details.development.matureHeightTime
        plant.developmentGrowthSpeed = Int16(details.development.growthSpeed)
        plant.developmentPropagationMethods = details.development.propagationMethods.joined(separator: ", ")
        plant.developmentCycle = details.development.cycle
        // Conditions
        if let climatic = details.conditions?.climatic {
            plant.climaticHardinessZone = climatic.hardinessZone.map { String($0) }.joined(separator: ", ")
            plant.climaticMinTemperature = climatic.minTemperature
            plant.climaticTemperatureLower = climatic.temperatureRange.lower
            plant.climaticTemperatureUpper = climatic.temperatureRange.upper
            plant.climaticIdealTemperatureLower = climatic.idealTemperatureRange.lower
            plant.climaticIdealTemperatureUpper = climatic.idealTemperatureRange.upper
            plant.climaticHumidityLower = Int16(climatic.humidityRange.lower)
            plant.climaticHumidityUpper = Int16(climatic.humidityRange.upper)
            plant.climaticWindResistance = climatic.windResistance ?? ""
        }
        if let soil = details.conditions?.soil {
            plant.soilPhRange = soil.phRange.map { String($0) }.joined(separator: ", ")
            plant.soilPhLabel = soil.phLabel
            plant.soilTypes = soil.types.joined(separator: ", ")
        }
        if let light = details.conditions?.light {
            plant.lightAmount = light.amount
            plant.lightType = light.type
        }
        // Care Guide Properties
        plant.toxicity = details.toxicity
        plant.careGuideWatering = details.careGuideWatering
        plant.careGuideFertilizing = details.careGuideFertilizing
        plant.careGuidePruning = details.careGuidePruning
        plant.careGuideRepotting = details.careGuideRepotting
        saveContext()
    }
    
    func fetchPlants() -> [Plant] {
        let request: NSFetchRequest<Plant> = Plant.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Plant.scannedAt, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching plants: \(error)")
            return []
        }
    }
    
    func deletePlant(_ plant: Plant) {
        viewContext.delete(plant)
        saveContext()
    }
    
    // MARK: - Conversation Operations
    
    func createConversation(title: String, plantName: String? = nil, id: String? = nil) -> Conversation? {
        let conversation = Conversation(context: viewContext)
        conversation.id = id ?? UUID().uuidString
        conversation.title = title
        conversation.plantName = plantName
        conversation.createdAt = Date()
        conversation.lastMessageDate = Date()
        
        do {
            try viewContext.save()
            return conversation
        } catch {
            print("Error creating conversation: \(error)")
            viewContext.delete(conversation)
            return nil
        }
    }
    
    func fetchConversations() -> [Conversation] {
        let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Conversation.lastMessageDate, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching conversations: \(error)")
            return []
        }
    }
    
    func fetchConversations(for plantName: String) -> [Conversation] {
        let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        request.predicate = NSPredicate(format: "plantName == %@", plantName)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Conversation.lastMessageDate, ascending: false)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching conversations for plant: \(error)")
            return []
        }
    }
    
    func addMessage(to conversation: Conversation, content: String, isUser: Bool, imageData: Data? = nil) {
        let message = Message(context: viewContext)
        message.id = UUID().uuidString
        message.content = content
        message.isUser = isUser
        message.createdAt = Date()
        message.imageData = imageData
        message.conversation = conversation
        
        conversation.addToMessages(message)
        conversation.lastMessageDate = message.createdAt
        
        saveContext()
    }
    
    func fetchMessages(for conversation: Conversation) -> [Message] {
        let request: NSFetchRequest<Message> = Message.fetchRequest()
        request.predicate = NSPredicate(format: "conversation == %@", conversation)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Message.createdAt, ascending: true)]
        
        do {
            return try viewContext.fetch(request)
        } catch {
            print("Error fetching messages: \(error)")
            return []
        }
    }
    
    func deleteConversation(_ conversation: Conversation) {
        viewContext.delete(conversation)
        saveContext()
    }
    
    func deleteEmptyConversations() {
        let request: NSFetchRequest<Conversation> = Conversation.fetchRequest()
        request.predicate = NSPredicate(format: "messages.@count == 0")
        
        do {
            let emptyConversations = try viewContext.fetch(request)
            for conversation in emptyConversations {
                viewContext.delete(conversation)
            }
            saveContext()
        } catch {
            print("Error deleting empty conversations: \(error)")
        }
    }
} 
