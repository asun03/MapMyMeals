//
//  ViewController.swift
//  MapMyMeals
//
//  name: Angela Sun
//  email: amsun@usc.edu

import UIKit
import FirebaseFirestore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift

class SignUpViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    // google sign in
    @IBAction func googleSignInDidTapped(_ sender: GIDSignInButton) {
        // onfiguration object
        let config = GIDConfiguration(clientID: "172972793599-fffcfnvhaun369gk0o8jqgro2t7eenuq.apps.googleusercontent.com")
        GIDSignIn.sharedInstance.configuration = config
        
        // sign in
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {
                print("error signing in with google: \(String(describing: error))")
                return
            }
     
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                print("error getting google user")
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            Auth.auth().signIn(with: credential) { result, error in
                // print("signed in with google!")
            }
            
            
            // create user in firestore so we can store stuff without it being a ghost
            if let userID = Auth.auth().currentUser?.uid {
                Firestore.firestore().collection("users").document(userID).setData(["id": userID])
            }
            
            
            // go to map view
            if let storyboard = self.storyboard, let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
                // Set tab bar controller as the root view controller of the navigation controller
                if let navigationController = self.navigationController {
                    navigationController.setViewControllers([tabBarController], animated: true)
                }
            }
        }
    }
    
    
    // creates user else error alert
    @IBAction func signUpDidTapped(_ sender: UIButton) {
        // note: firebase auth has standards eg valid .com email, password > 6 chars
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { authResult, error in
            // if create user unsuccessful, create an alert
            if let error = error as NSError? {
                var errorMessage = ""
                switch error.code {
                    case AuthErrorCode.emailAlreadyInUse.rawValue:
                        errorMessage = "You already have an account! Please log in"
                    case AuthErrorCode.invalidEmail.rawValue:
                        errorMessage = "Invalid email, please try again!"
                    case AuthErrorCode.weakPassword.rawValue:
                        errorMessage = "Password is too weak, please make sure it's at least 6 characters!"
                    default:
                        errorMessage = "Can't create account, please try again!"
                }

                // Display the error message
                let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
            // else create the user
            else {
                if let userID = authResult?.user.uid {
                // Create the user profile in Firestore
                    Firestore.firestore().collection("users").document(userID).setData([
                        "id": userID,
                        "email": self.emailTextField.text!,
                        "password": self.passwordTextField.text!
                    ])
                }
                
                // sign user in
                Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { user, error in
                }

                // go to map view by setting tab bar controller as root view controller
                if let storyboard = self.storyboard, let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
                    // Set the tab bar controller as the root view controller of the navigation controller
                    if let navigationController = self.navigationController {
                        navigationController.setViewControllers([tabBarController], animated: true)
                    }
                }
            }
        }
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

