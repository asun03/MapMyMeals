//
//  Review.swift
//  MapMyMeals
//
//  name: Angela Sun
//  email: amsun@usc.edu

import Foundation
// review struct to store into firebase
struct Review {
    public var restaurant: Restaurant
    public var rating : Double
    public var date : Date
    public var reviewText : String
    
    init(restaurant: Restaurant, rating: Double, date: Date, reviewText: String) {
        self.restaurant = restaurant
        self.rating = rating
        self.date = date
        self.reviewText = reviewText
    }
    
    // dict so we can store in database
    var dictionary: [String: Any] {
        return [
            "restaurantID" : restaurant.id!,
            "restaurantName" : restaurant.name!,
            "restaurantRating" : restaurant.rating!,
            "restaurantPrice" : restaurant.price ?? "$",
            "restaurantDistance" : restaurant.distance!,
            "restaurantAddress" : restaurant.address!,
            "restaurantImageURL" : restaurant.image_url!,
            "date" : date,
            "rating" : rating,
            "reviewText" : reviewText
        ]
    }
}
