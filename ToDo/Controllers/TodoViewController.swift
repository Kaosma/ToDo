//
//  ViewController.swift
//  ToDo
//
//  Created by Erik Ugarte on 2020-09-15.
//  Copyright © 2020 Creative League. All rights reserved.
//

import UIKit
import Firebase

class TodoViewController: UITableViewController {
    
    // MARK: Variables
    var categoryArray = ["Home", "Job", "Football"]
    
    // MARK: Constants
    
    // MARK: IB Actions
    // Creates an alert to add a new category
    @IBAction func addCategoryButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            self.categoryArray.append(textField.text!)
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Are you sure you want to sign out?", message: "", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Sign out", style: .default){ (action) in
            do {
                try Auth.auth().signOut()
                self.navigationController?.popToRootViewController(animated: true)
            } catch let signOutError as NSError {
              print ("Error signing out: %@", signOutError)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true)
    }
    
    // MARK: TableViewFunctions
    // Returns the amount of elements in categoryArray
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    // Creates the cells in the TableView
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCategoryCell", for: indexPath)
        cell.textLabel?.text = categoryArray[indexPath.row]
        return cell
    }
    
    // Selecting a cell with a touch checkmarks it
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: Main
    override func viewDidLoad() {
        super.viewDidLoad()
        let Nib = UINib(nibName: "TodoCategoryCell", bundle: nil)
        tableView.register(Nib, forCellReuseIdentifier: "Cell")
    }
}

