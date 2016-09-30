//
//  ViewController.swift
//  Checklists
//
//  Created by Ranon Martin on 9/3/16.
//  Copyright © 2016 Ranon Martin. All rights reserved.
//

import UIKit

class ChecklistViewController: UITableViewController {
    
    var items = [ChecklistItem]()
    var checklist: Checklist!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = checklist.name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


extension ChecklistViewController {
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checklist.items.count
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItem", for: indexPath) as! ChecklistItemViewCell
        let checklistItem = checklist.items[(indexPath as NSIndexPath).row]
        
        cell.titleLabel.text = checklistItem.text
        
        configureCheckmarkForCell(cell, withCheckListItem: checklistItem)
        
        return cell
    }
    
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

    
    //    - MARK : UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let checklistItem = checklist.items[(indexPath as NSIndexPath).row]
            checklistItem.toggleChecked()
            configureCheckmarkForCell(cell, withCheckListItem: checklistItem)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        checklist.items.remove(at: (indexPath as NSIndexPath).row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}


extension ChecklistViewController: ItemDetailViewControllerDelegate {
    
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
                controller.itemToEdit = checklist.items[(indexPath as NSIndexPath).row]
            }
        }
    }
    
    
    func itemDetailViewControllerDidCancel(_ controller: ItemDetailViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinishAddingItem item: ChecklistItem) {
        
        let newRowIndex = checklist.items.count
        
        checklist.items.append(item)
        
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
        
        dismiss(animated: true, completion: nil)
    }
    
    func itemDetailViewController(_ controller: ItemDetailViewController, didFinidhEditingItem item: ChecklistItem) {
        let index = (checklist.items as NSArray).index(of: item)
        if index != NSNotFound {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) as? ChecklistItemViewCell {
                cell.textLabel!.text = checklist.items[(indexPath as NSIndexPath).row].text
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
}



