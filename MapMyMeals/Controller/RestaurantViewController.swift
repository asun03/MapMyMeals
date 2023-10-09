//
//  RestaurantViewController.swift
//  MapMyMeals
//
//  name: Angela Sun
//  email: amsun@usc.edu

import Foundation
import UIKit
import FirebaseFirestore
import Kingfisher
import CoreLocation


class RestaurantCell : UITableViewCell {
    @IBOutlet weak var restaurantParentView: UIView!
    @IBOutlet weak var restaurantNameLabel: UILabel!
    @IBOutlet weak var restaurantImageView: UIImageView!
    @IBOutlet weak var restaurantInfoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}


class RestaurantViewController: UIViewController, UITableViewDataSource, CLLocationManagerDelegate {
    @IBOutlet weak var tableView: UITableView!
    var restaurantList: [Restaurant] = []
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // get user location
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    // get restaurants nearby user's location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let latitude = (locationManager.location?.coordinate.latitude)!
        let longitude = (locationManager.location?.coordinate.longitude)!

        // get yelp request
        getRestaurantsFromYelp(latitude: latitude, longitude: longitude, category: "food", limit: 20, sortBy: "distance", locale: "en_US") { (response, error) in
            if let response = response {
                self.restaurantList = response
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // failed getting location function
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let err = error as? CLError, err.code == .denied {
            let alert = UIAlertController(title: "Error", message: "Please enable location services", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // # sections in table view
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // # restaurants in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantList.count
    }
    
    // height of table cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }
    
    // show restaurant in cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantCell", for: indexPath) as! RestaurantCell
        let currRestaurant = restaurantList[indexPath.row]
        cell.restaurantNameLabel?.text = currRestaurant.name
        
        // trim city/state/zip
        var address = currRestaurant.address ?? "Unknown"
        if let addressRange = address.range(of: "\n"){
            let trimmedString = currRestaurant.address?[..<addressRange.lowerBound].description.trimmingCharacters(in: .whitespacesAndNewlines)
            address = trimmedString ?? "Unknown"
        }
        
        // trim distance and convert to miles
        var distance = (currRestaurant.distance ?? 0.0) * 0.000621371
        distance = round(distance * 100)/100
        
        // restaurant info
        let restaurantInfo = "Distance: \(distance) mi \nRating: \(currRestaurant.rating ?? 0)/5.0 stars \nPrice: \(currRestaurant.price ?? "$") \nAddress: \(address)"
        cell.restaurantInfoLabel?.text = restaurantInfo
        
        // set image
        let imageURL = URL(string: currRestaurant.image_url ?? "")
        cell.restaurantImageView.kf.setImage(with: imageURL)
        return cell
    }
    
    // get restaurants from yelp
    func getRestaurantsFromYelp(latitude: Double,
                                longitude: Double,
                                category: String,
                                limit: Int,
                                sortBy: String,
                                locale: String,
                                completionHandler: @escaping ([Restaurant]?, Error?) -> Void){
        let apiKey = "huryHw0Po4LbgdIgOb_6Us1qa8OBjgkoWMkGYc0KMTDmi5x_tnZZrHahkF7StzKr57Ry0aFQWjVQOcaD3OoMNhyTZabpxPCgjfvqH6lQSzNrWmF6vyYOM75yIvlOZHYx"
        let url = URL(string: "https://api.yelp.com/v3/businesses/search?latitude=\(latitude)&longitude=\(longitude)&categories=\(category)&limit=\(limit)&sort_by=\(sortBy)&locale=\(locale)")
        
        // request
        var request = URLRequest(url: url!)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        // session and task
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("error with yelp session")
                completionHandler(nil, error)
            }
            do {
                // json
                let json = try JSONSerialization.jsonObject(with: data!, options: [])
                guard let dict = json as? NSDictionary else { return }
                guard let businesses = dict.value(forKey: "businesses") as? [NSDictionary] else { return }
                
                var geocodingAttempts = 0
                
                // get restaurant data
                for business in businesses {
                    var restaurant = Restaurant()
                    restaurant.id = business.value(forKey: "id") as? String
                    restaurant.name = business.value(forKey: "name") as? String
                    restaurant.rating = business.value(forKey: "rating") as? Float
                    restaurant.price = business.value(forKey: "price") as? String
                    restaurant.distance = business.value(forKey: "distance") as? Double
                    restaurant.image_url = business.value(forKey: "image_url") as? String
                    
                    let address = business.value(forKeyPath: "location.display_address") as? [String]
                    restaurant.address = address?.joined(separator: "\n")
                    
                  
                    // only add to list if addr is geocodeable
                    let geocoder = CLGeocoder()
                    geocoder.geocodeAddressString(restaurant.address!) { placemarks, error in
                        geocodingAttempts += 1
                        if let error = error {
                            print("Error with geocoder inside fetching fom yelp: \(error)")
                        } else if (placemarks?.first?.location) != nil {
                            // print("successfully geocoded")
                            // print(\(location))
                            self.restaurantList.append(restaurant)
                        }
                        
                        // if i finish geocoding everything, then call the completionHandler - prof oh
                        if geocodingAttempts == businesses.count {
                            completionHandler(self.restaurantList, nil)
                        }
                    }
                }
                
            } catch {
                print("catch")
                completionHandler(nil, error)
            }
        }.resume()
    }
    
    // segue to add review vc 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // go to add review view controller
        if segue.identifier == "restaurantViewToAddReview" {
            let destinationVC = segue.destination as! UINavigationController
            let addReviewVC = destinationVC.topViewController as! AddReviewViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            let selectedRestaurant = restaurantList[selectedIndexPath.row]
            addReviewVC.restaurant = selectedRestaurant
        }
    }
}
