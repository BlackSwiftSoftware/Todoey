//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Jay Packer on 3/28/18.
//  Copyright © 2018 Jay Packer. All rights reserved.
//

import UIKit
import RealmSwift

class TodoListViewController: UITableViewController {

    var realm: Realm!

    //Holds list of todo items
    var todoItems: Results<Item>?
    
    //Used to filter a list of items by a specific category
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print location where app is saving data
        //print("Realm DB: \(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))")
        
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
        
        //Create Realm instance
        realm = try! Realm()
        
    }
    
    //MARK: - Tableview Datasource Methods
    
    //Number of Rows in the table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        //Set local count variable to 0 if todoItems.count is nil
        let count = todoItems?.count ?? 0
        
        //Return the count if greater than 0. Otherwise, return 1.
        return (count > 0) ? count : 1
        
    }
    
    //What goes in the table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //indexPath is location identifier for each cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        if todoItems?.isEmpty == false {
            let item = (todoItems?[indexPath.row])!
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No items added"
        }
        
        return cell
        
    }

    //MARK: - Tableview Delegate Methods
    
    //Cell is tapped.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //Don't leave row selected upon tapping.
        tableView.deselectRow(at: indexPath, animated: false)

        //If todoItems is not nil, then pick out item that was tapped. Set it's done status to the opposite value and save.
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    item.done = !item.done
                    
                    //To delete, simply:
                    //realm.delete(item)
                    
                }
            } catch {
                print("Error saving done status. \(error)")
            }
        }
        
        tableView.reloadData()
        
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        //Use a locally scoped variable that's available to everything inside this block, i.e. the IBAction. This allows us to get the value of the
        var textField = UITextField()

        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)

        let action  = UIAlertAction(title: "Add Item", style: .default) { (action) in

            //When user clicks the Add Item button on our UIAlert

            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new item. Error message: \(error)")
                }

            }
            
            self.tableView.reloadData()
            
        }

        //Put a text field inside the alert
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }

        alert.addAction(action)

        present(alert, animated: true, completion: nil)
        
    }
    
    //Mark: - Model Manipulation Methods
    
    //request parameter used for searching. Default value shows all items
    func loadItems() {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

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

            todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
            
            tableView.reloadData()
            
        }
    }

}
