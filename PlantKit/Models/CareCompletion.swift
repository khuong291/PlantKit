import Foundation
import CoreData

@objc(CareCompletion)
public class CareCompletion: NSManagedObject {
    @NSManaged public var id: String?
    @NSManaged public var completionDate: Date?
    @NSManaged public var reminder: CareReminder?
    @NSManaged public var plant: Plant?
    @NSManaged public var reminderType: String?
    @NSManaged public var createdAt: Date?
}

extension CareCompletion {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CareCompletion> {
        return NSFetchRequest<CareCompletion>(entityName: "CareCompletion")
    }
}

extension CareCompletion: Identifiable {} 