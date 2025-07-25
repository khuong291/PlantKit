import Foundation
import CoreData

@objc(Plant)
public class Plant: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var commonName: String?
    @NSManaged public var scientificName: String?
    @NSManaged public var plantDescription: String?
    @NSManaged public var plantImage: Data?
    @NSManaged public var climaticHardinessZone: String?
    @NSManaged public var climaticHumidityLower: Int16
    @NSManaged public var climaticHumidityUpper: Int16
    @NSManaged public var climaticIdealTemperatureLower: Double
    @NSManaged public var climaticIdealTemperatureUpper: Double
    @NSManaged public var climaticMinTemperature: Double
    @NSManaged public var climaticTemperatureLower: Double
    @NSManaged public var climaticTemperatureUpper: Double
    @NSManaged public var climaticWindResistance: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var scannedAt: Date?
    @NSManaged public var developmentCycle: String?
    @NSManaged public var developmentGrowthSpeed: Int16
    @NSManaged public var developmentMatureHeightTime: String?
    @NSManaged public var developmentPropagationMethods: String?
    @NSManaged public var generalEnvironmentalBenefits: String?
    @NSManaged public var generalHabitat: String?
    @NSManaged public var generalOriginCountries: String?
    @NSManaged public var lightAmount: String?
    @NSManaged public var lightType: String?
    @NSManaged public var physicalCrownDiameter: String?
    @NSManaged public var physicalForm: String?
    @NSManaged public var physicalHeight: String?
    @NSManaged public var soilPhLabel: String?
    @NSManaged public var soilPhRange: String?
    @NSManaged public var soilTypes: String?
    @NSManaged public var toxicity: String?
    @NSManaged public var careGuideWatering: String?
    @NSManaged public var careGuideFertilizing: String?
    @NSManaged public var careGuidePruning: String?
    @NSManaged public var careGuideRepotting: String?
    @NSManaged public var careReminders: NSSet?
    @NSManaged public var careCompletions: NSSet?
}

extension Plant {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Plant> {
        return NSFetchRequest<Plant>(entityName: "Plant")
    }
}

extension Plant: Identifiable {
    @objc(addCareRemindersObject:)
    @NSManaged public func addToCareReminders(_ value: CareReminder)

    @objc(removeCareRemindersObject:)
    @NSManaged public func removeFromCareReminders(_ value: CareReminder)

    @objc(addCareReminders:)
    @NSManaged public func addToCareReminders(_ values: NSSet)

    @objc(removeCareReminders:)
    @NSManaged public func removeFromCareReminders(_ values: NSSet)
    
    @objc(addCareCompletionsObject:)
    @NSManaged public func addToCareCompletions(_ value: CareCompletion)

    @objc(removeCareCompletionsObject:)
    @NSManaged public func removeFromCareCompletions(_ value: CareCompletion)

    @objc(addCareCompletions:)
    @NSManaged public func addToCareCompletions(_ values: NSSet)

    @objc(removeCareCompletions:)
    @NSManaged public func removeFromCareCompletions(_ values: NSSet)
} 
