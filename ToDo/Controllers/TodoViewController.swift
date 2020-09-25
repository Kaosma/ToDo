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
    var categoryArray = [String]()
    
    // MARK: Constants
    let url = URL(string: "https://us-central1-todo-e0009.cloudfunctions.net/user")!
    let db = Firestore.firestore()
    let id = Auth.auth().currentUser!.uid
    
    // MARK: IB Actions
    // Creates an alert that allows you to add a new category
    @IBAction func addCategoryButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in

            if !textField.text!.trimmingCharacters(in: .whitespaces).isEmpty {
                let categoryName = textField.text!
                self.db.collection("categories").addDocument(data: [      "id" : self.id,
                                                                    "category" : categoryName,
                                                                       "tasks" : [String]().self])
                self.categoryArray.append(categoryName)
                self.tableView.reloadData()
            } else {}
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
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
    /*
    func loadCategories(){
        
        db.collection("users").whereField(field: "categories") { (querySnapshot, error) in
            if let e = error {
                print("There was an Issue retrieving data from Firestore. \(e)")
            } else {
                if let snapShotDocuments = querySnapshot?.documents {
                    for doc in snapShotDocuments {
                        let data = doc.data()
                        if let type = data["type"] as? String, let name = data["name"] as? String, let id = data["id"] as? String, let cost = data["cost"] as? Int, let boost = data["boost"] as? Double {
                            let newObject = PackageItem(type: type, name: name, id: id, cost: cost, boost: boost)
                            self.packageList.append(newObject)
                            
                            DispatchQueue.main.async {
                                self.packageTableViewOutlet.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }*/
    // MARK: Main
    override func viewDidLoad() {
        super.viewDidLoad()
        let Nib = UINib(nibName: "TodoCategoryCell", bundle: nil)
        tableView.register(Nib, forCellReuseIdentifier: "Cell")
    }
}

