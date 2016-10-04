//
//  ChecklistItem+CoreDataClass.swift
//  Checklists
//
//  Created by Ranon Martin on 9/30/16.
//  Copyright © 2016 Ranon Martin. All rights reserved.
//

import Foundation
import CoreData
import UserNotifications


public class ChecklistItem: NSManagedObject {
    
    private lazy var notificationCenter: UNUserNotificationCenter = {
        return UNUserNotificationCenter.current()
    }()
    
    convenience init(withText text: String, andReminder shouldRemind: Bool, for dueDate: Date, in context: NSManagedObjectContext) {
        self.init(context: context)
        self.shouldRemind = shouldRemind
        self.dueDate = dueDate
        self.text = text
        self.itemID = nextChecklistItemID()
        self.checked = false
    }
    
    func modifyWithText(_ text: String, andReminder shouldRemind: Bool, for dueDate: Date) {
        self.shouldRemind = shouldRemind
        self.dueDate = dueDate
        self.text = text
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
    
    func scheduleNotification() {
        unscheduleNotification()
        
        if shouldRemind && dueDate.compare(Date()) != .orderedAscending {
 
            var reminderDate = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: dueDate)
            reminderDate.timeZone = TimeZone.current
            
            let calendarTrigger = UNCalendarNotificationTrigger(dateMatching: reminderDate, repeats: false)
            
            let content = UNMutableNotificationContent()
            content.title = String.localizedStringWithFormat("Checklist Reminder")
            content.body = text
            content.sound = UNNotificationSound.default()
            
            let request = UNNotificationRequest(identifier: String(itemID), content: content, trigger: calendarTrigger)
            notificationCenter.add(request, withCompletionHandler: { (error) in
                if let error = error {
                    print("failed with error: \(error)")
                } else {
                    print("notification scheduled")
                }
            })
        }
    }
    
    func unscheduleNotification() {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [String(itemID)])
    }
    
    deinit {
        unscheduleNotification()
    }
}
