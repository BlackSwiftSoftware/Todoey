//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Jay Packer on 3/28/18.
//  Copyright © 2018 Jay Packer. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
    
    //Holds list of todo items
    var itemArray = [Item]()
    
    //The context for use with CoreData
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print location where app is saving data
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
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

        
        //******************************
        //Mark the row with a checkmark
        //******************************
        itemArray[indexPath.row].done = itemArray[indexPath.row].done ? false : true
        
        //Even shorter way of setting it...
        //itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        //******************************
        //Update the data
        //******************************
        //The following line would change the title of the task.
        //This could be coded up for use in an AlertAction, so that when the user long-pressed, an alert let them change the title.
        //itemArray[indexPath.row].setValue("Task completed", forKey: "title")
        
        //***************************************
        //Delete the row altogether when clicked.
        //***************************************
        
        //Remove the item from the database.
            //context.delete(itemArray[indexPath.row])
        //Remove the item from the array. (Updates screen.)
            //itemArray.remove(at: indexPath.row)

        
        saveItems()
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        //Use a locally scoped variable that's available to everything inside this block, i.e. the IBAction. This allows us to get the value of the
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action  = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //When user clicks the Add Item button on our UIAlert

            //Update array with new item
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
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

        do {
            try context.save()
        } catch {
            print("Error saving context. Error message: \(error)")
        }
        
        self.tableView.reloadData()

    }
    
    //request parameter used for searching. Default value shows all items
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context. Error message: \(error)")
        }

        tableView.reloadData()
        
    }
    
    
}

//MARK: - Search Bar Methods
extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //Dismiss keyboard
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        //Dismiss keyboard and show all items when the searchbar returns to empty
        if searchBar.text?.count == 0 {
            loadItems()
            
            //Run on the main thread so that searchbar loses focus and keyboard is dimissed, even if background threads are running. Otherwise, app might assign this code to another thread...
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        //Perform the search as the user types
        } else if searchBar.text!.count > 0 {
            
            let request: NSFetchRequest<Item> = Item.fetchRequest()
            //print(searchBar.text!)
            
            //Query data to filter by search
            //[cd] makes query case and diacritic (letters with accent symbols) insensitive
            request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
            
            //Sort data using array of one element.
            request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
            
            loadItems(with: request)
            
        }
    }


}
