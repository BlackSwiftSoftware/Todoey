//
//  TodoListViewController.swift
//  Todoey
//
//  Created by Jay Packer on 3/28/18.
//  Copyright © 2018 Jay Packer. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    var realm: Realm!
    
    //Holds list of todo items
    var todoItems: Results<Item>?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    //Used to filter a list of items by a specific category
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    //Set the color of the carrier, clock, battery...
    override var preferredStatusBarStyle: UIStatusBarStyle {
        
        guard let bgColor = selectedCategory?.categoryBGColor else {fatalError()}
        
        return isColorLight(withHexCode: bgColor) ? .default : .lightContent
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print location where app is saving data
        //print("Realm DB: \(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))")
        
        //Create Realm instance
        realm = try! Realm()
        
        //Chameleon framework allows styling the status bar (carrier, clock, battery) based on underlying background.
        //Only this doesn't work... Took me forever to figure out why, but I realized that we're setting the color of the navigation color, so the color isn't set statically on ViewController, which I'm guessing is why this line doesn't work.
        //self.setStatusBarStyle(UIStatusBarStyleContrast)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {

        //Title of the view. We set it to the category name, since we're showing items inside that category.
        title = selectedCategory?.name ?? "Items"

        guard let bgColor = selectedCategory?.categoryBGColor else {fatalError()}
        
        updateNavBar(withHexCode: bgColor)

    }
    
//Jarring flashing of color. Better to use willMove method below.
//    override func viewWillDisappear(_ animated: Bool) {
//        updateNavBar(withHexCode: "242424")
//    }
    
    //Handle the transition back to the category viewcontroller.
    override func willMove(toParentViewController parent: UIViewController?) {
        updateNavBar(withHexCode: "242424")
    }
    
    //MARK: - Custom color methods
    func isColorLight(withHexCode colorHexCode: String) -> Bool {
        
        guard let navBarColor = UIColor(hexString: colorHexCode) else {fatalError()}
        
        if let componentColors = navBarColor.cgColor.components {
            let colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;
            if (colorBrightness > 0.6) {
                return true
            } else {
                return false
            }
        }
        
        //Defaults to returning false if the above fails. A hack.
        return false
        
    }
    
    //MARK: - Navbar Setup Methods
    
    func updateNavBar(withHexCode colorHexCode: String) {
        
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist.")}
        
        guard let navBarColor = UIColor(hexString: colorHexCode) else {fatalError()}
        
        //Set styles and colors the navbar and search bar.
        searchBar.barTintColor = navBarColor
        searchBar.isTranslucent = false
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = navBarColor.cgColor
        
        navBar.barTintColor = navBarColor
        navBar.isTranslucent = false
        
        // Removes hairline/shadow of navigation bar
        navBar.setValue(true, forKey: "hidesShadow")

        //Make sure the controls on the navbar contrast with the color of the navbar.
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        //The title of the navBar is a set a little differently using a dictionary.
        navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: ContrastColorOf(navBarColor, returnFlat: true)]
        
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
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if todoItems?.isEmpty == false {
            let item = (todoItems?[indexPath.row])!
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            
            let catBGColor = UIColor(hexString: (selectedCategory?.categoryBGColor)!)
            
            if let bgColor = catBGColor?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = bgColor
                cell.textLabel?.textColor = ContrastColorOf(bgColor, returnFlat: true)
                //changes checkmark accessory color too
                cell.tintColor = ContrastColorOf(bgColor, returnFlat: true)
                
            }
            
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
    
    override func deleteFromModel(at indexPath: IndexPath) {

        if let itemToDelete = self.todoItems?[indexPath.row] {
            do {
                try realm.write {
                    //Now delete category.
                    realm.delete(itemToDelete)
                }
            } catch {
                print("Error deleting item. \(error)")
            }
        }
                
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
