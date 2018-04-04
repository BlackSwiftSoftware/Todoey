//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Jay Packer on 4/4/18.
//  Copyright © 2018 Jay Packer. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    //Hold list of todo categories
    var categoryArray = [Category]()
    
    //Context for CoreData
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        //Hard code static values for testing.
//        let newCat = Category(context: context)
//        newCat.name = "Groceries"
//        categoryArray.append(newCat)
//
//        let newCat2 = Category(context: context)
//        newCat2.name = "Work"
//        categoryArray.append(newCat2)
//
//        let newCat3 = Category(context: context)
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
        
        let category = categoryArray[indexPath.row]
        
        cell.textLabel?.text = category.name
        
        return cell
    }
    
    //Number of Rows in the table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC  = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryArray[indexPath.row]
        }
    }

    
    //MARK: - Data Manipulation Methods
    
    func saveCategories() {
        
        do {
            try context.save()
        } catch {
            print("Error saving categories to context. Error message: \(error)")
        }
        
        self.tableView.reloadData()
        
    }
    
    //request parameter used for searching. Default value shows all items
    func loadCategories() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error loading categories from context. Error message: \(error)")
        }
        
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
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            self.categoryArray.append(newCategory)
            
            //Save changes
            self.saveCategories()
        
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
