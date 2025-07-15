import Foundation
import CoreData

@objc(CareReminder)
public class CareReminder: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var reminderType: String?
    @NSManaged public var frequency: Int16
    @NSManaged public var notes: String?
    @NSManaged public var isEnabled: Bool
    @NSManaged public var createdAt: Date?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var lastCompleted: Date?
    @NSManaged public var nextDueDate: Date?
    @NSManaged public var reminderTime: Date?
    @NSManaged public var repeatType: String?
    @NSManaged public var plant: Plant?
    @NSManaged public var completions: NSSet?
}

extension CareReminder {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CareReminder> {
        return NSFetchRequest<CareReminder>(entityName: "CareReminder")
    }
}

extension CareReminder: Identifiable {
    @objc(addCompletionsObject:)
    @NSManaged public func addToCompletions(_ value: CareCompletion)

    @objc(removeCompletionsObject:)
    @NSManaged public func removeFromCompletions(_ value: CareCompletion)

    @objc(addCompletions:)
    @NSManaged public func addToCompletions(_ values: NSSet)

    @objc(removeCompletions:)
    @NSManaged public func removeFromCompletions(_ values: NSSet)
} 