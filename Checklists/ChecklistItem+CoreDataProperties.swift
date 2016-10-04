//
//  ChecklistItem+CoreDataProperties.swift
//  Checklists
//
//  Created by Ranon Martin on 9/30/16.
//  Copyright © 2016 Ranon Martin. All rights reserved.
//

import Foundation
import CoreData

extension ChecklistItem {

    @nonobjc public class func createFetchRequest() -> NSFetchRequest<ChecklistItem> {
        return NSFetchRequest<ChecklistItem>(entityName: "ChecklistItem");
    }

    @NSManaged public var text: String
    @NSManaged public var checked: Bool
    @NSManaged public var dueDate: Date
    @NSManaged public var shouldRemind: Bool
    @NSManaged public var itemID: Int
    @NSManaged public var checklist: Checklist

}
