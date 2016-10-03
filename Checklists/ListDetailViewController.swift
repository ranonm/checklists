//
//  ListDetailViewController.swift
//  Checklists
//
//  Created by Ranon Martin on 9/5/16.
//  Copyright © 2016 Ranon Martin. All rights reserved.
//

import UIKit
import CoreData

protocol ListDetailViewControllerDelegate: class {
    func listDetailViewControllerDidCancel(_ controller: ListDetailViewController)
    
    func listDetailViewController(_ controller: ListDetailViewController, didFinishAddingChecklist checklist: Checklist)
    
    func listDetailViewController(_ controller: ListDetailViewController, didFinishEditingChecklist checklist: Checklist)
}

class ListDetailViewController: UITableViewController {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    weak var delegate: ListDetailViewControllerDelegate?
    
    var managedObjectContext: NSManagedObjectContext {
        return CoreDataStack.shared.managedObjectContext
    }
    
    var checklistToEdit: Checklist?
    var iconName = "Folder"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let checklist = checklistToEdit {
            title = "Edit Checklist"
            textField.text = checklist.name
            iconName = checklist.iconName
            doneBarButton.isEnabled = true
        }
        iconImageView.image = UIImage(named: iconName)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        textField.resignFirstResponder()
    }
    
    
    // MARK: - Action Methods
    
    @IBAction func cancel() {
        delegate?.listDetailViewControllerDidCancel(self)
    }
    
    @IBAction func done() {
        if let checklist = checklistToEdit {
            
            checklist.name = textField.text!
            checklist.iconName = iconName
            
            delegate?.listDetailViewController(self, didFinishEditingChecklist: checklist)
            
        } else {
            
            let checklist = Checklist(context: managedObjectContext)
            checklist.name = textField.text!
            checklist.iconName = iconName
            
            delegate?.listDetailViewController(self, didFinishAddingChecklist: checklist)
        }
    }
}


// MARK: - UITableViewDelegate

extension ListDetailViewController {
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if (indexPath as NSIndexPath).section == 1 {
            return indexPath
        }
        return nil
    }
}


// MARK: - UITextFieldDelegate

extension ListDetailViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText: NSString = textField.text! as NSString
        let newText: NSString = oldText.replacingCharacters(in: range, with: string) as NSString
        
        doneBarButton.isEnabled = (newText.length > 0)
        return true
    }
}


// MARK: - IconPickerViewControllerDelegate

extension ListDetailViewController: IconPickerViewControllerDelegate {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickIcon" {
            let controller = segue.destination as! IconPickerViewController
            controller.delegate = self
        }
    }
    
    func iconPicker(_ picker: IconPickerViewController, didPickIcon iconName: String) {
        self.iconName = iconName
        iconImageView.image = UIImage(named: iconName)
        _ = navigationController?.popViewController(animated: true)
    }
}
