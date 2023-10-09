//
//  ReviewAnnotation.swift
//  MapMyMeals
//
//  name: Angela Sun
//  email: amsun@usc.edu

import Foundation
import UIKit
import MapKit

// custom map annotation 
class ReviewAnnotation : MKPointAnnotation {
    let name: String
    let price : String
    let yelpRating : Float
    let distance : Double
    let address : String
    let date : Date
    let myRating : Double
    let reviewText : String
    
    init(name: String, price: String, yelpRating: Float, distance: Double, address: String, date: Date, myRating: Double, reviewText: String) {
        self.name = name
        self.price = price
        self.yelpRating = yelpRating
        self.distance = distance
        self.address = address
        self.date = date
        self.myRating = myRating
        self.reviewText = reviewText
    }
    
}
