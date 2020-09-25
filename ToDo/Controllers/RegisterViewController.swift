//
//  RegisterViewController.swift
//  ToDo
//
//  Created by Erik Ugarte on 2020-09-16.
//  Copyright © 2020 Creative League. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import ChameleonFramework

class RegisterViewController: UIViewController {
    
    // Register TextFields
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // Authentication when trying to register as user, if successfull the segue is performed
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    self.performSegue(withIdentifier: "RegisterToList", sender: self)
                    let id = authResult?.user.uid
                    print(id!)
                    
                    // Saving the user to Firestore using a custom REST API
                    guard let url = URL(string: "https://us-central1-todo-e0009.cloudfunctions.net/user") else { return }
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    let JSON: [String: Any] = [
                        "email": email,
                        "password": password,
                        "id": id!]
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    guard let httpBody = try? JSONSerialization.data(withJSONObject: JSON, options: []) else { return }
                    request.httpBody = httpBody

                    let session = URLSession.shared
                    session.dataTask(with: request) { (data, response, error) in
                        /*if let response = response {
                            print(response)
                        }
                        if let data = data {
                            do {
                                let json = try JSONSerialization.jsonObject(with: data, options: [])
                                print(json)
                            } catch {
                                print(error)
                            }
                        }*/
                    }.resume()
                }
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller does not exist")}
        if let navBarColor = UIColor(hexString: "1D9BF6") {
            navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        }
    }
}
