//
//  AllListsViewController.swift
//  Checklists
//
//  Created by Ranon Martin on 9/4/16.
//  Copyright © 2016 Ranon Martin. All rights reserved.
//

import UIKit
import CoreData

class AllListsViewController: UITableViewController {
    
    fileprivate var coreDataStack: CoreDataStack {
        return CoreDataStack.shared
    }
    
    fileprivate var stateManager: StateManager {
        return StateManager.shared
    }
    
    fileprivate var managedObjectContext: NSManagedObjectContext {
        return coreDataStack.managedObjectContext
    }
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<Checklist> = {
        let fetchRequest = Checklist.createFetchRequest()
        let sort = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        fetchRequest.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()
    
    private var numberOfLists: Int {
        return self.fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    fileprivate var selectedIndexPath: IndexPath?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        loadChecklists()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Restore checklist state
        navigationController?.delegate = self
        
        let index = stateManager.indexOfSelectedChecklist
        if index >= 0 && index < numberOfLists {
            if let fetchedObjects = fetchedResultsController.fetchedObjects {
                let checklist = fetchedObjects[index]
                performSegue(withIdentifier: "ShowChecklist", sender: checklist)
            }
        }
    }

    
    // MARK: - Helper Methods
    
    private func loadChecklists() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Failed while fetching checklists: \(error)")
        }
    }
    
    func cellForTableView(_ tableView: UITableView) -> UITableViewCell {
        let cellIdentifier = "Cell"
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            return cell
        } else {
            return UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
    }
}


// MARK: - UITableViewDataSource

extension AllListsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = cellForTableView(tableView)
        let list = fetchedResultsController.object(at: indexPath)
        
        cell.textLabel!.text = list.name
        cell.imageView?.image = UIImage(named: list.iconName)
        cell.accessoryType = .detailDisclosureButton
        
        if list.numberOfItems == 0 {
            cell.detailTextLabel!.text = "(No Items)"
        }else if list.numberOfUncheckedItems == 0 {
            cell.detailTextLabel!.text = "All Done!"
        } else {
            cell.detailTextLabel!.text = "\(list.numberOfUncheckedItems) Remaining"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let list = fetchedResultsController.object(at: indexPath)
            managedObjectContext.delete(list)
            coreDataStack.saveContext()
        }
    }
}


// MARK: - UITableViewDelegate

extension AllListsViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        stateManager.indexOfSelectedChecklist =  indexPath.row
        selectedIndexPath = indexPath
        
        let checklist = fetchedResultsController.object(at: indexPath)
        performSegue(withIdentifier: "ShowChecklist", sender: checklist)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowChecklist" {
            let controller = segue.destination as! ChecklistViewController
            controller.checklist = sender as! Checklist
            
        } else if segue.identifier == "AddChecklist" {
            let navigation = segue.destination as! UINavigationController
            let controller = navigation.topViewController as! ListDetailViewController
            
            controller.delegate = self
            controller.checklistToEdit = nil
        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let navigationController = storyboard!.instantiateViewController(withIdentifier: "ListDetailNavigationController") as! UINavigationController
        
        let controller = navigationController.topViewController as! ListDetailViewController
        controller.delegate = self
        
        let checklist = fetchedResultsController.object(at: indexPath)
        controller.checklistToEdit = checklist
        
        present(navigationController, animated: true, completion: nil)
    }

}


// MARK: - ListDetailViewControllerDelegate

extension AllListsViewController: ListDetailViewControllerDelegate {
    func listDetailViewControllerDidCancel(_ controller: ListDetailViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func listDetailViewController(_ controller: ListDetailViewController, didFinishAddingChecklist checklist: Checklist) {
        coreDataStack.saveContext()
        dismiss(animated: true, completion: nil)
    }
    
    func listDetailViewController(_ controller: ListDetailViewController, didFinishEditingChecklist checklist: Checklist) {
        coreDataStack.saveContext()
        dismiss(animated: true, completion: nil)
    }
}



extension AllListsViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController === self {
            // Reload the previously selected row
            if let indexPath = selectedIndexPath {
                tableView.reloadRows(at: [indexPath], with: .none)
            }
            
            stateManager.resetSelectedChecklistIndex()
        }
    }
}


// MARK: - NSFetchedResultsControllerDelegate

extension AllListsViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    @objc(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:) func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            break
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            break
        case .update, .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
