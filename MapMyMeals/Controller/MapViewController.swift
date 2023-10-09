//
//  MapViewController.swift
//  MapMyMeals
//
//  name: Angela Sun
//  email: amsun@usc.edu

import Foundation
import CoreLocation
import MapKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // set up location manager
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // move more than 1 meter
        locationManager.delegate = self
        mapView.delegate = self
        
        // if user hasn't chosen location permission
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }

        locationManager.startUpdatingLocation() // start tracking
        
        // make MKUserTrackingButton
        let trackingButton = MKUserTrackingButton(mapView: mapView)
        trackingButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackingButton)

        // autolayout lower right corner
        NSLayoutConstraint.activate([
            trackingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            trackingButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
        
    }
    
    // get map markers
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // load annotations from firebase
        loadAnnotationsFromFirebase()

    }
    
    // put markers on map from firebase
    func loadAnnotationsFromFirebase(){
        // if logged in, get user's reviews
        if let user = Auth.auth().currentUser {
            Firestore.firestore().collection("users").document(user.uid).getDocument { (document, error) in
                if let error = error {
                    print("error getting user documents: \(error)")
                    return
                }
                guard let document = document, document.exists else {
                    print("no document")
                    return
                }
                let userRestaurants = document.reference.collection("restaurants")  
                userRestaurants.getDocuments { (querySnapshot, err) in
                    if let err = err {
                        print("error getting user review documents: \(err)")
                        return
                    }
                    guard let querySnapshot = querySnapshot else {
                        print("error getting query snapshot")
                        return
                    }
                    
                    // for every restaurant review, put annotation on map
                    for document in querySnapshot.documents {
                        // get data
                        let review = document.data()
                        let restaurantName = review["restaurantName"] as! String
                        let restaurantAddress = review["restaurantAddress"] as! String
                        let timestamp = review["date"] as! Timestamp
                        let date = timestamp.dateValue()
                        let rating = review["rating"] as! Float 
                        let restaurantDistance = review["restaurantDistance"] as! Double
                        let restaurantPrice = review["restaurantPrice"] as! String
                        let restaurantRating = review["restaurantRating"] as! Double
                        let reviewText = review["reviewText"] as! String
                        
                        // geocode and make marker
                        let geocoder = CLGeocoder()
                        geocoder.geocodeAddressString(restaurantAddress) { placemarks, error in
                            if let error = error {
                                print("Error with geocoder with \(restaurantName): \(error)")
                                return
                            }
                            if let placemark = placemarks?.first {
                                // add annotation
                                let annotation = ReviewAnnotation(name: restaurantName, price: restaurantPrice, yelpRating: rating, distance: restaurantDistance, address: restaurantAddress, date: date, myRating: restaurantRating, reviewText: reviewText)
                                annotation.title = (restaurantName)
                                annotation.coordinate = placemark.location!.coordinate
                                self.mapView.addAnnotation(annotation)
                            }
                        }
                        
                    }
                }
                
            }
        }
    }

    // center map view on user
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            // region centered on user location
            let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: false); // don't animate zooming in 
        }
    }
    
    // error notification eg if user denies access
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let err = error as? CLError, err.code == .denied {
            let alert = UIAlertController(title: "Error", message: "Please enable location services", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // click on annotation -> show details
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotation = view.annotation as? ReviewAnnotation else {
            print("error clicking location")
            return
        }
        performSegue(withIdentifier: "mapToAnnotation", sender: annotation)
    }
    
    // send annotation info to annotation vc
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "mapToAnnotation" {
            if let annotationVC = segue.destination as? AnnotationViewController, let reviewAnnotation = sender as? ReviewAnnotation {
                annotationVC.reviewAnnotation = reviewAnnotation
            }
        }
    }
    
    
    
    
}
