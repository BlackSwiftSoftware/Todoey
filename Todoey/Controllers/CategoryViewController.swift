//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Jay Packer on 4/4/18.
//  Copyright © 2018 Jay Packer. All rights reserved.
//

import UIKit
import RealmSwift

class CategoryViewController: UITableViewController {

    //Persist data across sessions
    let realm = try! Realm()

    //Hold lists of categories
    var categories: Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        //Hard code static values for testing.
//        let newCat = Category()
//        newCat.name = "Groceries"
//        categoryArray.append(newCat)
//
//        let newCat2 = Category()
//        newCat2.name = "Work"
//        categoryArray.append(newCat2)
//
//        let newCat3 = Category()
//        newCat3.name = "Home"
//        categoryArray.append(newCat3)

        //Read existing items
        loadCategories()
        
    }

    //MARK: - Tableview DataSource Methods
    
    //What goes in the table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //indexPath is location identifier for each cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No categories added yet"
        
        return cell
    }
    
    //Number of Rows in the table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1 //nil coalescing operator returns 1 if nil
    }
    
    //MARK: - Tableview Delegate Methods
    
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
        
        self.tableView.reloadData()
        
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
