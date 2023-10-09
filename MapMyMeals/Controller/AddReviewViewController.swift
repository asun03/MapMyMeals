//
//  AddReviewViewController.swift
//  MapMyMeals
//
//  name: Angela Sun
//  email: amsun@usc.edu

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class AddReviewViewController : UIViewController, UITextViewDelegate {
    var restaurant : Restaurant?
    @IBOutlet weak var restaurantNameLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var ratingSlider: UISlider!
    @IBOutlet weak var reviewTextView: UITextView!
    
    
    @IBOutlet weak var ratingLabel: UILabel!
    var rating = 0.0
    var date = Date()
    var reviewText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set text view border
        reviewTextView.layer.borderWidth = 1
        reviewTextView.layer.borderColor = UIColor.black.cgColor
        
        reviewTextView.delegate = self
        restaurantNameLabel.text = restaurant?.name ?? ""
    }
    
    // select date
    @IBAction func datePickerDidChange(_ sender: UIDatePicker) {
        date = sender.date
    }
    
    
    // change slider in increments of .5 
    @IBAction func sliderDidChange(_ sender: UISlider) {
        rating = Double(round(sender.value / 0.5) * 0.5)
        ratingLabel.text = "Rating: \(rating)"
        
    }
    
    // edit text
    func textViewDidChange(_ textView: UITextView) {
        reviewText = textView.text
    }
    
    // lower keyboard
    func textViewDidEndEditing(_ textView: UITextView) {
        reviewTextView.resignFirstResponder()
        reviewText = textView.text
    }
    
    // lower keyboard
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        reviewTextView.resignFirstResponder()
        return true
    }
    
    // lower keyboard
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
                textView.resignFirstResponder()
            return false
        }
        return true
    }
        
    // add review
    @IBAction func addButtonDidTapped(_ sender: UIBarButtonItem) {
        // alert and don't save if no review
        if reviewTextView.text.isEmpty {
            let alert = UIAlertController(title: "Warning", message: "Please enter a review!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default)
            alert.addAction(okAction)
            present(alert, animated: true)
        } else {
            // else save review in firestore and dismiss
            let review = Review(restaurant: restaurant!, rating: rating, date: date, reviewText: reviewText)
            
            // if signed in
            if let user = Auth.auth().currentUser {
                Firestore.firestore().collection("users").document(user.uid).collection("restaurants").document((restaurant?.name)!).setData(review.dictionary)
            } else {
                // if no user signed in, should never get here
               fatalError("No user logged in!")
            } 
            self.dismiss(animated: true)
        }
    }
    
    
    // go back to table view
    @IBAction func backButtonDidTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true)
    }
    
}
