//
//  AnnotationViewController.swift
//  MapMyMeals
//
//  name: Angela Sun
//  email: amsun@usc.edu

import Foundation
import UIKit
import FirebaseFirestore
import FirebaseAuth

class AnnotationViewController: UIViewController, UITextFieldDelegate {
    var reviewAnnotation : ReviewAnnotation? 
    @IBOutlet weak var restaurantNameLabel: UILabel!
    @IBOutlet weak var yelpInfoLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // trim distance and convert to miles
        var distance = (reviewAnnotation?.distance ?? 0.0) * 0.000621371
        distance = round(distance * 100)/100
        
        // fill out view
        restaurantNameLabel.text = "\(reviewAnnotation?.name ?? "")"
        yelpInfoLabel.text = "\(reviewAnnotation?.price ?? "$") | \(reviewAnnotation?.yelpRating ?? 1)/5 | \(distance) mi"
        addressLabel.text = "\(reviewAnnotation?.address ?? "")"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateLabel.text = "Date Reviewed: \(dateFormatter.string(from: reviewAnnotation!.date))"
        
        //dateLabel.text = "\(reviewAnnotation?.date)"
        ratingLabel.text = "My rating: \(reviewAnnotation?.myRating ?? 0)/5 stars"
        reviewLabel.text = "My review: \n\n\(reviewAnnotation?.reviewText ?? "No review found")"
        
    }
}
