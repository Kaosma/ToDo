//
//  SwipeTableViewController.swift
//  ToDo
//
//  Created by Erik Ugarte on 2020-09-25.
//  Copyright © 2020 Creative League. All rights reserved.
//

import UIKit
import SwipeCellKit

class SwipeTableViewController: UITableViewController, SwipeTableViewCellDelegate {
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
}

// MARK: Swipe Cell Delegate Methods
extension TodoViewController: SwipeTableViewCellDelegate{
    
}
