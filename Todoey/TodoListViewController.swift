//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Jay Packer on 3/28/18.
//  Copyright © 2018 Jay Packer. All rights reserved.
//

import UIKit

class TodoListViewController: UITableViewController {

    //Holds list of todo items
    var itemArray = ["Pet Bruce", "Love Bruce", "Ask Bruce to stop biting me"]
    
    //User Defaults creates a plist file that holds key/value pairs. Can be used for small amounts of storage.
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Read array from User Defaults
        if let items = defaults.array(forKey: "TodoListArray") as? [String] {
            itemArray = items
        }
        
    }
    
    //MARK: - Tableview Datasource Methods
    
    //What goes in the table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //indexPath is location identifier for each cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        cell.textLabel?.text = itemArray[indexPath.row]
        
        return cell
    }
    
    //Number of Rows in the table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    //MARK: - Tableview Delegate Methods
    
    //Cell is tapped.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //print("You tapped \(itemArray[indexPath.row])")
        
        //Don't leave row selected upon tapping.
        tableView.deselectRow(at: indexPath, animated: false)
        
        //Toggle checkmark value
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
           tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        //Use a locally scoped variable that's available to everything inside this block, i.e. the IBAction. This allows us to get the value of the
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action  = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //When user clicks the Add Item button on our UIAlert

            self.itemArray.append(textField.text!)

            //Save our array of todo items in user defaults. The key is used to retrieve item.
            self.defaults.set(self.itemArray, forKey: "TodoListArray")
            
            self.tableView.reloadData()
        }
        
        //Put a text field inside the
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
}

