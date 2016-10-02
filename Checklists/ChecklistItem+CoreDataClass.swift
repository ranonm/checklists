//
//  ChecklistItem+CoreDataClass.swift
//  Checklists
//
//  Created by Ranon Martin on 9/30/16.
//  Copyright © 2016 Ranon Martin. All rights reserved.
//

import Foundation
import CoreData


public class ChecklistItem: NSManagedObject {
    
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        
    }
    
    convenience init(withText text: String, andReminder shouldRemind: Bool, for dueDate: Date, in context: NSManagedObjectContext) {
        self.init(context: context)
        self.shouldRemind = shouldRemind
        self.dueDate = dueDate
        self.text = text
        self.itemID = nextChecklistItemID()
        self.checked = false
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
    
    private func nextChecklistItemID() -> Int {
        let userDefaults = UserDefaults.standard
        let itemID = userDefaults.integer(forKey: "ChecklistItemID")
        userDefaults.set(itemID + 1, forKey: "ChecklistItemID")
        userDefaults.synchronize()
        return itemID
    }
    
    /*
    func scheduleNotification() {
        let existingNotification = notificationForThisItem()
        if let notification = existingNotification {
            UIApplication.shared.cancelLocalNotification(notification)
        }
        
        if shouldRemind && dueDate.compare(Date()) != .orderedAscending {
            let localNotification = scheduleNotification()
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
    */
}
