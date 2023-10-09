//
//  LoginViewController.swift
//  MapMyMeals
//
//  name: Angela Sun
//  email: amsun@usc.edu

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {
   
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var loginSuccess = false // if user logged in correctlly
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginSuccess = false
        loginTextField.delegate = self
        passwordTextField.delegate = self 
        
    }
    
    // log in
    @IBAction func loginDidTapped(_ sender: UIButton) {
        var errorMessage = ""

        // if empty text field, alert and return
        guard let email = loginTextField.text, !email.isEmpty else {
            // Display the error message
            errorMessage = "Please enter an email!"
            let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        guard let password = passwordTextField.text, !password.isEmpty else {
            errorMessage = "Please enter a password!"
            let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        
        // login with firebase
        Auth.auth().signIn(withEmail: loginTextField.text!, password: passwordTextField.text!) { authResult, error in
            // if failed, create an alert
            if let error = error as NSError? {
                print("error logging in")
                switch error.code {
                    case AuthErrorCode.invalidEmail.rawValue:
                        errorMessage = "Invalid email, please try again!"
                    case AuthErrorCode.wrongPassword.rawValue:
                        errorMessage = "Wrong password, please try again!"
                    case AuthErrorCode.userNotFound.rawValue:
                        errorMessage = "Account not found, please try again or sign up!"
                    default:
                        errorMessage = "Can't login, please try again!"
                }

                // Display the error message
                let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                // successfully logged in ->  set tab bar controller as root view controller
                self.loginSuccess = true // can login
                if let storyboard = self.storyboard, let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
                    if let navigationController = self.navigationController {
                          navigationController.setViewControllers([tabBarController], animated: true)
                      }
                  }
            }
        }
    }
    
    // checking if we should segue to map 
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // if trying to open map
        if identifier == "LoginToMapSegue" {
            // if didn't succeed logging in
            if(!loginSuccess){
                return false
            }
        }
        return true
    }
    
    // lower keyboard
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    // lower keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}
