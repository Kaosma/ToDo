//
//  ViewController.swift
//  ToDo
//
//  Created by Erik Ugarte on 2020-09-15.
//  Copyright © 2020 Creative League. All rights reserved.
//
import UIKit
import Firebase
import SwipeCellKit
import ChameleonFramework

class TodoViewController: UITableViewController {
    
    // MARK: Variables
    var categoryArray = [String]()
    var categoryColorArray = [String]()
    
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
                let categoryColor = UIColor.randomFlat().hexValue()
                self.db.collection("categories").addDocument(data: ["id" : self.id,
                                                              "category" : categoryName,
                                                                 "tasks" : [String]().self,
                                                           "colorString" : categoryColor])
                self.categoryArray.append(categoryName)
                self.categoryColorArray.append(categoryColor)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCategoryCell", for: indexPath) as! SwipeTableViewCell
        cell.textLabel?.text = categoryArray[indexPath.row]

        cell.backgroundColor = UIColor(hexString: categoryColorArray[indexPath.row] ?? "1D9BF6")
        cell.textLabel?.textColor = ContrastColorOf(UIColor(hexString: categoryColorArray[indexPath.row])!, returnFlat: true)
        cell.delegate = self
        return cell
    }
    
    // Selecting a cell with a touch segues into that category's TableView
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToTasks", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTasks" {
            let destinationVC = segue.destination as! TaskViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.selectedCategory = categoryArray[indexPath.row]
            }
        }
    }
    
    // Loads the categories to the categoryArray
    func loadCategories(){
        self.db.collection("categories").self.whereField("id", isEqualTo: id).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.categoryArray.append((document.data()["category"] as? String)!)
                    self.categoryColorArray.append((document.data()["colorString"] as? String)!)
                }
                self.tableView.reloadData()
            }
        }
    }
    
    
    /*
    self.db.collection("categories").self.whereField("id", isEqualTo: self.id).getDocuments() { (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            for document in querySnapshot!.documents {
                if let docArray = document.data()["categories"] as? [String] {
                    loadedCategoryArray = docArray
                } else {
                    
                }
            }
            loadedCategoryArray.append(categoryName)
        }
    }*/
    
    
    
    // MARK: Main
    override func viewDidLoad() {
        super.viewDidLoad()
        let Nib = UINib(nibName: "TodoCategoryCell", bundle: nil)
        tableView.register(Nib, forCellReuseIdentifier: "Cell")
        loadCategories()
        tableView.rowHeight = 70.0
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = self.navigationController?.navigationBar else {fatalError("Navigation controller does not exist")}
        navBar.barTintColor = UIColor(hexString: "1D9BF6")
    }
}

// MARK: Swipe Cell Delegate Methods
extension TodoViewController: SwipeTableViewCellDelegate{
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            let collectionReference = self.db.collection("categories")
            let query : Query = collectionReference.whereField("category", isEqualTo: self.categoryArray[indexPath.row])
            
            query.getDocuments(completion: { (snapshot, error) in
                if let error = error {
                    print(error.localizedDescription)
                } else {
                    for document in snapshot!.documents {
                        self.db.collection("categories").document("\(document.documentID)").delete()
                }
            }})
            self.categoryArray.remove(at: indexPath.row)
            tableView.reloadData()
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")

        return [deleteAction]
    }
}
