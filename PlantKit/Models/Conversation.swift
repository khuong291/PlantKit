//
//  Conversation.swift
//  PlantKit
//
//  Created by Khuong Pham on 25/6/25.
//

import Foundation
import CoreData

@objc(Conversation)
public class Conversation: NSManagedObject {
    
}

extension Conversation {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Conversation> {
        return NSFetchRequest<Conversation>(entityName: "Conversation")
    }
    
    @NSManaged public var id: String
    @NSManaged public var title: String
    @NSManaged public var plantName: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var lastMessageDate: Date
    @NSManaged public var messages: NSSet?
}

extension Conversation: Identifiable {
    
}

// MARK: Generated accessors for messages
extension Conversation {
    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: Message)
    
    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: Message)
    
    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)
    
    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)
} 