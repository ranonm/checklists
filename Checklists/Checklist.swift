//
//  Checklist.swift
//  Checklists
//
//  Created by Ranon Martin on 9/4/16.
//  Copyright © 2016 Ranon Martin. All rights reserved.
//

import UIKit

class Checklist: NSObject, NSCoding {
    var name: String
    var iconName: String
    var items = [ChecklistItem]()
    
    init(name: String, iconName: String) {
        self.name = name
        self.iconName = iconName
        super.init()
    }
    
    convenience init(name: String) {
        self.init(name: name, iconName: "No Icon")
    }
    
    required init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "Name") as! String
        items = aDecoder.decodeObject(forKey: "Items") as! [ChecklistItem]
        iconName = aDecoder.decodeObject(forKey: "IconName") as! String
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "Name")
        aCoder.encode(items, forKey: "Items")
        aCoder.encode(iconName, forKey: "IconName")
    }
    
    func countUncheckedItems() -> Int {
        var count = 0
        for item in items where item.isUnchecked() {
            count += 1
        }
        return count
    }
    
    
}
