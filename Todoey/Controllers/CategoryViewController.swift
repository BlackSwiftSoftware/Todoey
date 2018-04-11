//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Jay Packer on 4/4/18.
//  Copyright © 2018 Jay Packer. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

    var realm: Realm!
    
    //Hold lists of categories
    var categories: Results<Category>?
    
    //Set the color of the carrier, clock, battery...
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Create realm instance
        realm = try! Realm()
        
        //Read existing items
        loadCategories()
        
        //Set tableView Properties
        //This is a hack. And it's ugly. One can set the deleteAction title to 'nil' in the Swipe Cell Delegate Methods, which reduces the height needed by showing only the icon... I'm leaving this code since that's what the tutorial did.
        tableView.rowHeight = 80
        
        //Chameleon framework allows styling the status bar (carrier, clock, battery) based on underlying background.
        //This call seemed to work, but when going back and forth between categories and todo items, the status bar would occasionally revert to black.
        //Commenting out this line that uses the Chamelon Framework and inside using the preferredStatusBarStyle above seem to work reliably.
        //self.setStatusBarStyle(UIStatusBarStyleContrast)
        
    }
    
    //MARK: - Tableview DataSource Methods
    
    //Number of Rows in the table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //Set local count variable to 0 if todoItems.count is nil
        let count = categories?.count ?? 0

        //Return the count if greater than 0. Otherwise, return 1.
        return (count > 0) ? count : 1
        
    }
    
    //What goes in the table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //get cell from the super class that's handling this table
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if categories?.isEmpty == false {
            cell.textLabel?.text = categories?[indexPath.row].name
            
            if let bgColor = UIColor(hexString: (categories?[indexPath.row].categoryBGColor)!) {
                cell.backgroundColor = bgColor
                cell.textLabel?.textColor = ContrastColorOf(bgColor, returnFlat: true)
            }
            
        } else {
            
            cell.textLabel?.text = "No categories added yet"
            
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC  = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    //MARK: - Data Manipulation Methods
    
    func save(category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error saving category. Error message: \(error)")
        }
        
        tableView.reloadData()
        
    }
    
    override func deleteFromModel(at indexPath: IndexPath) {

        if let categoryToDelete = self.categories?[indexPath.row] {
            do {
                try realm.write {
                    //Delete items associated with category. Order matters! (Must delete items first.)
                    realm.delete(categoryToDelete.items)
                    //Now delete category.
                    realm.delete(categoryToDelete)
                }
            } catch {
                print("Error deleting category. \(error)")
            }
        }

        //We don't call tableView.reloadData because the editActionsOptionsForRowAt method in SwipeCellKit does this for us.
        //tableView.reloadData()

    }
    
    //request parameter used for searching. Default value shows all items
    func loadCategories() {
        
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
        
    }
    
    //MARK: - Add New Categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        //Use a locally scoped variable that's available to everything inside this block, i.e. the IBAction.
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
        
        let action  = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            //When user clicks the Add Category button on our UIAlert
            
            //Update array with new item
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.categoryBGColor = UIColor.randomFlat.hexValue()
            
            //Save changes
            self.save(category: newCategory)
        
        }
        
        //Put a text field inside the alert
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new  category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
}

