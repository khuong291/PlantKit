//
//  Message.swift
//  PlantKit
//
//  Created by Khuong Pham on 25/6/25.
//

import Foundation
import CoreData

@objc(Message)
public class Message: NSManagedObject {
    
}

extension Message {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Message> {
        return NSFetchRequest<Message>(entityName: "Message")
    }
    
    @NSManaged public var id: String
    @NSManaged public var content: String
    @NSManaged public var isUser: Bool
    @NSManaged public var createdAt: Date
    @NSManaged public var imageData: Data?
    @NSManaged public var conversation: Conversation?
}

extension Message: Identifiable {
    
} 