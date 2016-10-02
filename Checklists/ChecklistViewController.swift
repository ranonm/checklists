//
//  ViewController.swift
//  Checklists
//
//  Created by Ranon Martin on 9/3/16.
//  Copyright © 2016 Ranon Martin. All rights reserved.
//

import UIKit
import CoreData

class ChecklistViewController: UITableViewController {
    
    var coreDataStack: CoreDataStack {
        return CoreDataStack.shared
    }
    
    var managedObjectContext: NSManagedObjectContext {
        return coreDataStack.managedObjectContext
    }
    
    
    lazy var fetchedResultsController: NSFetchedResultsController<ChecklistItem> = {
        let sortByText = NSSortDescriptor(key: "text", ascending: true)
        let sortByCompletion = NSSortDescriptor(key: "checked", ascending: true)
        
        let fetchRequest = ChecklistItem.createFetchRequest()
        fetchRequest.sortDescriptors = [sortByCompletion, sortByText]
        fetchRequest.fetchBatchSize = 20
        fetchRequest.predicate = NSPredicate(format: "checklist == %@", self.checklist)
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: "checked", cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    var checklist: Checklist!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = checklist.name
        
        fetchChecklistItems()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddItem" {
            
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! ItemDetailViewController
            
            controller.delegate = self
            
        } else if segue.identifier == "EditItem" {
            
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! ItemDetailViewController
            
            controller.delegate = self
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                controller.itemToEdit = fetchedResultsController.object(at: indexPath)
            }
        }
    }

    
    // MARK: - Helper Methods
    
    func configureCheckmarkForCell(_ cell: UITableViewCell, withCheckListItem item: ChecklistItem) {
        if let cell = cell as? ChecklistItemViewCell {
            if item.isChecked() {
                cell.checkmarkLabel.text = "✓"
                cell.checkmarkLabel.textColor = view.tintColor
            } else {
                cell.checkmarkLabel.text = ""
            }
        }
    }
    
    func fetchChecklistItems() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error occurred during fetching: \(error)")
        }
    }
}


// MARK: - UITableViewDataSource

extension ChecklistViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItem", for: indexPath) as! ChecklistItemViewCell
        
        let checklistItem = fetchedResultsController.object(at: indexPath)
        cell.titleLabel.text = checklistItem.text
        configureCheckmarkForCell(cell, withCheckListItem: checklistItem)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Completed items"
        }
        return nil
    }
    
    
}


// MARK: - UITableViewDelegate

extension ChecklistViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let checklistItem = fetchedResultsController.object(at: indexPath)
            checklistItem.toggleChecked()
            coreDataStack.saveContext()
            
            configureCheckmarkForCell(cell, withCheckListItem: checklistItem)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let checklistItem = fetchedResultsController.object(at: indexPath)
            managedObjectContext.delete(checklistItem)
            
            coreDataStack.saveContext()
        }
    }
}


// MARK: - ItemDetailViewControllerDelegate

extension ChecklistViewController: ItemDetailViewControllerDelegate {
    
    func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishAddingItem item: ChecklistItem) {
        item.checklist = checklist
        coreDataStack.saveContext()
        
        dismiss(animated: true, completion: nil)
    }

    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishEditingItem item: ChecklistItem) {
        coreDataStack.saveContext()
        
        dismiss(animated: true, completion: nil)
    }
 
}


// MARK: - NSFetchedResultsControllerDelegate

extension ChecklistViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    @objc(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:) func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update, .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                
                var rowAnimation: UITableViewRowAnimation = .automatic
                
                if indexPath.compare(newIndexPath) == .orderedSame {
                    rowAnimation = .none
                }
                    
                tableView.deleteRows(at: [indexPath], with: rowAnimation)
                tableView.insertRows(at: [newIndexPath], with: rowAnimation)
            }
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    
}


