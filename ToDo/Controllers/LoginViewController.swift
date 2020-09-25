//
//  LoginViewController.swift
//  ToDo
//
//  Created by Erik Ugarte on 2020-09-16.
//  Copyright © 2020 Creative League. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import ChameleonFramework

class LoginViewController: UIViewController {
    
    // Login TextFields
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // Authentication when trying to login, if successfull the segue is performed
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    self.performSegue(withIdentifier: "LoginToList", sender: self)
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
