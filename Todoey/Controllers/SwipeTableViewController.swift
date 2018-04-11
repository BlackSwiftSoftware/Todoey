//
//  SwipeTableViewController.swift
//  Todoey

//This class was created to use a DRY (don't repeat yourself) approach. Initially, we implemented the swiping options on table rows in the CategoryViewController. Rather than copy, paste, and modify that code for TodoListViewController, we're making the code modular so that we can both viewcontrollers can be children of this master class, thus inheriting the functionality of swipeable table cells.

//
//  Created by Jay Packer on 4/9/18.
//  Copyright © 2018 Jay Packer. All rights reserved.
//

import UIKit
import SwipeCellKit
import ChameleonFramework

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Set tableView Properties
        tableView.separatorStyle = .none
        
    }

    //MARK: - TableView Datasource Methods
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //indexPath is location identifier for each cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        return cell

        
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            
            self.deleteFromModel(at: indexPath)
            
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        
        //Looks like I can use .fill to do something without destroying the row...
        //read more here: https://cocoapods.org/pods/SwipeCellKit#expansion
        //also this? https://github.com/SwipeCellKit/SwipeCellKit/blob/develop/Guides/Advanced.md
        
        //options.expansionStyle = .fill
        
        return options
    }

    func deleteFromModel(at indexPath: IndexPath) {
        //update data model using override function from within the view controller we're working on.
    }
    
}

//Necessary to use ChameleonFramework method to set the statusbar color from the child ViewController.
extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
}
