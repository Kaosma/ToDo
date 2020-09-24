//
//  AccountViewController.swift
//  ToDo
//
//  Created by Erik Ugarte on 2020-09-24.
//  Copyright © 2020 Creative League. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class AccountViewController: UIViewController {
    
    let url = URL(string: "https://us-central1-todo-e0009.cloudfunctions.net/user")!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        // PUT CRUD
    }
    
    // Creates an alert that allows you to sign out
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
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
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        let userUrl = url.absoluteString + "/" + Auth.auth().currentUser!.uid
        guard let newUrl = URL(string: userUrl) else {
            print("Error: cannot create URL")
            return
        }
        // Create the request
        var request = URLRequest(url: newUrl)
        request.httpMethod = "DELETE"
        URLSession.shared.dataTask(with: request) { data, response, error in
        }.resume()
        
        /*let user = Auth.auth().currentUser
        user!.delete();
        do {
            try Auth.auth().signOut()
            self.navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }*/
    }
    
    // MARK: Main
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.navigationController?.navigationBar.backItem?.title = "Back"
        emailTextField.text = Auth.auth().currentUser?.email
        // PASSWORD SHOW
    }
}
