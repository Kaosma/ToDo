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
    let db = Firestore.firestore()
    let id = Auth.auth().currentUser!.uid
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // HTTP PUT Request when saved info to change the user's info
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        let userUrl = url.absoluteString + "/" + id
        var request = URLRequest(url: URL(string: userUrl)!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let JSON: [String: Any] = [
            "email": emailTextField.text!,
            "password": passwordTextField.text!,
            "id": id]
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: JSON, options: []) else { return }
        request.httpBody = httpBody
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            /*
            guard error == nil else {
                print("Error: error calling PUT")
                return
            }
            guard let data = data else {
                print("Error: Did not receive data")
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("Error: HTTP request failed")
                return
            }
            do {
                guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("Error: Cannot convert data to JSON object")
                    return
                }
                guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
                    print("Error: Cannot convert JSON object to Pretty JSON data")
                    return
                }
                guard let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) else {
                    print("Error: Could print JSON in String")
                    return
                }
                
                print(prettyPrintedJson)
            } catch {
                print("Error: Trying to convert JSON data to string")
                return
            }*/
        }.resume()
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
    // HTTP DELETE Request when saved info to change the user's info
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        let userUrl = url.absoluteString + "/" + Auth.auth().currentUser!.uid
        guard let newUrl = URL(string: userUrl) else {
            print("Error: cannot create URL")
            return
        }
        var request = URLRequest(url: newUrl)
        request.httpMethod = "DELETE"
        URLSession.shared.dataTask(with: request) { data, response, error in
            /*
            guard error == nil else {
                print("Error: error calling DELETE")
                print(error!)
                return
            }
            guard let data = data else {
                print("Error: Did not receive data")
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("Error: HTTP request failed")
                return
            }
            do {
                guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("Error: Cannot convert data to JSON")
                    return
                }
                guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
                    print("Error: Cannot convert JSON object to Pretty JSON data")
                    return
                }
                guard let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) else {
                    print("Error: Could print JSON in String")
                    return
                }
            } catch {
                print("Error: Trying to convert JSON data to string")
                return
            }*/
        }.resume()
        
        // Also deleting user from the Firebase Auth and signing out the user
        let user = Auth.auth().currentUser
        user!.delete();
        do {
            try Auth.auth().signOut()
            self.navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
    }
    
    // MARK: Main
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.text = Auth.auth().currentUser?.email
        
        // HTTP GET Request to retrieve the user's password and show it in the account settings
        let userUrl = url.absoluteString + "/" + id
        let task = URLSession.shared.dataTask(with: URL(string: userUrl)!) {(data, response, error) in
            guard let data = data else { return }
            
            let idData = String(data: data, encoding: .utf8)!.replacingOccurrences(of: "{", with: "").replacingOccurrences(of: "}", with: "").replacingOccurrences(of: "\"id\":", with: "").replacingOccurrences(of: "\"", with: "")
            
            self.db.collection("users").self.whereField("id", isEqualTo: idData).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        self.passwordTextField.text = document.data()["password"] as? String
                    }
                }
            }
        }
        task.resume()
        
    }
}
