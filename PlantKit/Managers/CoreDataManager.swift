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
    
    func savePlant(details: PlantDetails, image: UIImage) {
        let plant = Plant(context: viewContext)
        plant.id = details.id
        plant.commonName = details.commonName
        plant.scientificName = details.scientificName
        plant.createdAt = details.createdAt
        plant.scannedAt = Date()
        if let imageData = image.jpegData(compressionQuality: 0.6) {
            plant.imageData = imageData
        }
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
} 