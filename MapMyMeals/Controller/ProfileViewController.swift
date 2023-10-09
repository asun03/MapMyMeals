//
//  ProfileViewController.swift
//  MapMyMeals
//
//  name: Angela Sun
//  email: amsun@usc.edu

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage


class ProfileViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var selectPhoto: UIButton!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // make photo circular with black border
        profilePhoto.layer.cornerRadius = profilePhoto.bounds.width / 2.0 
        profilePhoto.clipsToBounds = true
        profilePhoto.layer.borderWidth = 3.0
        profilePhoto.layer.borderColor = UIColor.black.cgColor
        
        // if signed in
        if let user = Auth.auth().currentUser {
            let email = user.email
            emailLabel.text = "Email: \(email ?? "")"
            
            // load user photo or show blank icon
            let reference = Storage.storage().reference(withPath: "users/\(user.uid)/profilePhoto.jpg")
            // download in memory
            reference.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let error = error { // if error, just use default icon
                  print("error loading profile photo: \(error)")
                  self.profilePhoto.image = UIImage(named: "default_profile_icon")
              } else {
                // if found photo
                  if let data = data {
                      self.profilePhoto.image = UIImage(data: data)
                  } else { // else dfault photo
                      self.profilePhoto.image = UIImage(named: "default_profile_icon")
                  }
              }
            }
        } else {
            // if no user signed in, should never get here
           fatalError("No user logged in!")
        }
    }
    
    // tap select photo button
    @IBAction func selectPhotoDidTapped(_ sender: UIButton) {
        // initialize and set properties
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    
    // finish picking a photo
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        profilePhoto.image = image // set image view as image
        
        // upload profile photo to firebase storage
        if let user = Auth.auth().currentUser {
            let imageData = image.jpegData(compressionQuality: 0.5)! // fix compression quality?? ask
            let profilePhotoRef = Storage.storage().reference(withPath: "users/\(user.uid)/profilePhoto.jpg") // path under user
            // upload file to path
            profilePhotoRef.putData(imageData, metadata: nil) { (metadata, error) in
                if error != nil {
                    print("error uploading profile pic")
                } else {
                    print("uploaded profile pic")
                }
            }
        }
        picker.dismiss(animated: true) // dismiss the picker
    }
    
    // sign out and go to sign up view 
    @IBAction func signOutDidTapped(_ sender: UIButton) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            print("signed out")
            performSegue(withIdentifier: "signOutSegue", sender: nil)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
}



