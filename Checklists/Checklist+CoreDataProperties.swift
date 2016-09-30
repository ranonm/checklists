//
//  Checklist+CoreDataProperties.swift
//  Checklists
//
//  Created by Ranon Martin on 9/30/16.
//  Copyright © 2016 Ranon Martin. All rights reserved.
//

import Foundation
import CoreData

extension Checklist {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<Checklist> {
        return NSFetchRequest<Checklist>(entityName: "Checklist");
    }

    @NSManaged public var name: String
    @NSManaged public var iconName: String
    @NSManaged public var items: NSSet?

}

// MARK: Generated accessors for items
extension Checklist {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: ChecklistItem)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: ChecklistItem)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}
