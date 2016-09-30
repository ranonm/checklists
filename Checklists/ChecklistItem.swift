//
//  ChecklistItem.swift
//  Checklists
//
//  Created by Ranon Martin on 9/3/16.
//  Copyright © 2016 Ranon Martin. All rights reserved.
//

import Foundation
import UIKit

class ChecklistItem: NSObject, NSCoding {
    var text: String
    fileprivate var checked: Bool
    
    var dueDate = Date()
    var shouldRemind: Bool
    var itemID: Int
    
    init(text: String, checked: Bool){
        self.text = text
        self.checked = checked
        shouldRemind = false
        
        itemID = DataModel.nextChecklistItemID()
        super.init()
    }
    
    convenience init(text: String) {
        self.init(text: text, checked: false)
    }
    
    func isChecked() -> Bool {
        return checked
    }
    
    func isUnchecked() -> Bool {
        return !isChecked()
    }
    
    func toggleChecked() {
        checked = !isChecked()
    }
    
    func scheduleNotification() {
        let existingNotification = notificationForThisItem()
        if let notification = existingNotification {
            UIApplication.shared.cancelLocalNotification(notification)
        }
        
        if shouldRemind && dueDate.compare(Date()) != .orderedAscending {
            let localNotification = UILocalNotification()
            localNotification.fireDate = dueDate
            localNotification.timeZone = TimeZone.current
            localNotification.alertBody = text
            localNotification.soundName = UILocalNotificationDefaultSoundName
            localNotification.userInfo = ["ItemID": itemID]
            
            UIApplication.shared.scheduleLocalNotification(localNotification)
        }
    }
    
    func notificationForThisItem() -> UILocalNotification? {
        let allNotifications = UIApplication.shared.scheduledLocalNotifications!
        
        for notification in allNotifications {
            if let number = notification.userInfo?["ItemID"] as? Int , number == itemID {
                return notification
            }
        }
        return nil
    }
    
    deinit {
        if let notification = notificationForThisItem() {
            UIApplication.shared.cancelLocalNotification(notification)
        }
    }
    
    
    //  - MARK: NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        text = aDecoder.decodeObject(forKey: "Text") as! String
        checked = aDecoder.decodeBool(forKey: "Checked")
        dueDate = aDecoder.decodeObject(forKey: "DueDate") as! Date
        shouldRemind = aDecoder.decodeBool(forKey: "ShouldRemind")
        itemID = aDecoder.decodeInteger(forKey: "ItemID")
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(text, forKey: "Text")
        aCoder.encode(checked, forKey: "Checked")
        aCoder.encode(dueDate, forKey: "DueDate")
        aCoder.encode(shouldRemind, forKey: "ShouldRemind")
        aCoder.encode(itemID, forKey: "ItemID")
    }
}
