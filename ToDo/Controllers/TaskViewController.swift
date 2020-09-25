//
//  TaskViewController.swift
//  ToDo
//
//  Created by Erik Ugarte on 2020-09-25.
//  Copyright © 2020 Creative League. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SwipeCellKit
import ChameleonFramework

class TaskViewController: UITableViewController {
    
    let db = Firestore.firestore()
    let id = Auth.auth().currentUser!.uid
    
    var taskArray = [String]()
    var gradientColor = ""
    var selectedCategory : String? {
        didSet {
            loadTasks()
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Task to Category \(selectedCategory!)", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Task", style: .default) { (action) in
            if !textField.text!.trimmingCharacters(in: .whitespaces).isEmpty {
                let taskName = textField.text!
                /*
                self.db.collection("categories").addDocument(data: [      "id" : self.id,
                                                                    "category" : categoryName,
                                                                       "tasks" : [String]().self])*/
                self.taskArray.append(taskName)
                self.tableView.reloadData()
            } else {}
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new task"
            textField = alertTextField
        }
        
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: TableViewFunctions
    // Returns the amount of elements in categoryArray
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    // Creates the cells in the TableView
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoTaskCell", for: indexPath)
        cell.textLabel?.text = taskArray[indexPath.row]
        if let color = UIColor(hexString: gradientColor)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(taskArray.count)) {
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        }
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
    
    func loadTasks() {
        self.db.collection("categories").self.whereField("category", isEqualTo: selectedCategory!).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.taskArray = (document.data()["tasks"] as? [String])!
                    self.gradientColor = (document.data()["colorString"] as? String)!
                }
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: Main
    override func viewDidLoad() {
        super.viewDidLoad()
        let Nib = UINib(nibName: "TodoTaskCell", bundle: nil)
        tableView.register(Nib, forCellReuseIdentifier: "Cell")
        navigationController?.title = selectedCategory
        tableView.rowHeight = 70.0
        tableView.separatorStyle = .none
    }
}

// MARK: Swipe Cell Delegate Methods
extension TaskViewController: SwipeTableViewCellDelegate{
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            self.taskArray.remove(at: indexPath.row)
            tableView.reloadData()
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")

        return [deleteAction]
    }
}
