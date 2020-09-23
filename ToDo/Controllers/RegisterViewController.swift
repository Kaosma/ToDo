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
                    let url = URL(string: "https://us-central1-todo-e0009.cloudfunctions.net/user")!
                    var request = URLRequest(url: url)
                    request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                    request.httpMethod = "POST"
                    let JSON: [String: Any] = [
                        "email": email,
                        "password": password,
                        "id": id!]
                    var jsonData:Data?
                    do {
                        jsonData = try JSONSerialization.data(
                          withJSONObject: JSON,
                          options: .prettyPrinted)
                    } catch {
                        print(error.localizedDescription)
                    }
                    request.httpBody = jsonData

                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        guard let data = data,
                            let response = response as? HTTPURLResponse,
                            error == nil else {                                              // check for fundamental networking error
                            print("error", error ?? "Unknown error")
                            return
                        }

                        guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                            print("statusCode should be 2xx, but is \(response.statusCode)")
                            print("response = \(response)")
                            return
                        }

                        let responseString = String(data: data, encoding: .utf8)
                    }
                    task.resume()
                }
            }
        }
    }
    
}
