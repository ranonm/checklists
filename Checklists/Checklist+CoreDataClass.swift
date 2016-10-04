//
//  Checklist+CoreDataClass.swift
//  Checklists
//
//  Created by Ranon Martin on 9/30/16.
//  Copyright © 2016 Ranon Martin. All rights reserved.
//

import Foundation
import CoreData


public class Checklist: NSManagedObject {
    
    var numberOfItems: Int {
        if let items = items {
            return items.count
        }
        return 0
    }
    
    var numberOfUncheckedItems: Int {
        var count = 0
        if let items = items {
            for item in items where item.isUnchecked() {
                count += 1
            }
        }
        return count
    }
    
}
