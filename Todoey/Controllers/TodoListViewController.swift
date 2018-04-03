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
    var itemArray = [Item]()
    
    //Create file path to the documents folder
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let newItem = Item()
//        newItem.title = "Pet Bruce"
//        itemArray.append(newItem)
//
//        let newItem2 = Item()
//        newItem2.title = "Love Bruce"
//        itemArray.append(newItem2)
//
//        let newItem3 = Item()
//        newItem3.title = "Ask Bruce to stop biting me"
//        itemArray.append(newItem3)
        
        //Read existing items
        loadItems()
        
    }
    
    //MARK: - Tableview Datasource Methods
    
    //What goes in the table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //indexPath is location identifier for each cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    //Number of Rows in the table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    //MARK: - Tableview Delegate Methods
    
    //Cell is tapped.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Don't leave row selected upon tapping.
        tableView.deselectRow(at: indexPath, animated: false)

        itemArray[indexPath.row].done = itemArray[indexPath.row].done ? false : true
        //Even shorter way of setting it...
        //itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        saveItems()
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        //Use a locally scoped variable that's available to everything inside this block, i.e. the IBAction. This allows us to get the value of the
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action  = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //When user clicks the Add Item button on our UIAlert

            //Update array with new item
            let newItem = Item()
            newItem.title = textField.text!
            self.itemArray.append(newItem)
            
            //Save changes
            self.saveItems()

        }
        
        //Put a text field inside the
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    //Mark: - Model Manipulation Methods
    
    func saveItems() {

        let encoder = PropertyListEncoder()
        
        do {
            let data = try encoder.encode(itemArray)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error encoding itemArray, \(error)")
        }
        
        self.tableView.reloadData()

    }
    
    func loadItems() {
        if let data = try? Data(contentsOf: dataFilePath!) {
            let decoder = PropertyListDecoder()
            
            do {
                itemArray = try decoder.decode([Item].self, from: data)
            } catch {
                print("Error decoding itemArray, \(error)")
            }
        }
    }
    
}

