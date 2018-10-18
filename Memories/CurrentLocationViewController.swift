//
//  ViewController.swift
//  Memories
//
//  Created by Arsalan Wahid Asghar on 10/12/18.
//  Copyright © 2018 asghar. All rights reserved.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController,CLLocationManagerDelegate {

    //MARK:- Properties
    let locationManager = CLLocationManager()
    var location: CLLocation?

    //MARK:- Outlets
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!


    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
    }


    //MARK:- App Logic
    func enableLocationService(){

        locationManager.delegate = self

        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            checkLocationServcies()
        case .authorizedAlways:
            break
        case .restricted, .denied:
            locationServiceDenied(with: "Location Service Disabled", message: "Enable Location Service", actionTitle: "ok")
        }
    }

    //Check for active location services
    func checkLocationServcies(){
        if CLLocationManager.locationServicesEnabled(){
            enableLocationBasedFeatures()
        }else{
            locationServiceDenied(with: "Location Service unavailabe", message: "Enable Location Service From Settings", actionTitle: "ok")
        }

        if CLLocationManager.headingAvailable(){
            //Do something realted to headingservice
        }else{
            locationServiceDenied(with: "Heading service not available", message: "Current hardware no supported", actionTitle: "Ok")
        }
    }


    func enableLocationBasedFeatures(){

        //setting the location accuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        //start getting the users location
        locationManager.startUpdatingLocation()
    }

    func locationServiceDenied(with title:String , message:String , actionTitle:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle, style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }


    func updateLabels(){

        if let location = location{
            self.latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            self.longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""
        }else{
            self.latitudeLabel.text = ""
            self.longitudeLabel.text = ""
            tagButton.isHidden = true
            messageLabel.text = "Tap 'Get Location to Start'"
        }
    }


    //MARK:- Actions
    @IBAction func getLocation(){
        enableLocationService()
    }


    //MARK:- CLLocationDelegate

    //Tells delegate that location Manager was unable to get location data
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Failed Due To: \(error)")
    }


    //Tells delegate new location data is available
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        location = newLocation
        updateLabels()
        print("Last Location Recieved: \(newLocation)")
    }

    //Checks change in Location Permissions
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted,.denied:
            locationServiceDenied(with: "Location Service Disabled", message: "Please enable from settings", actionTitle: "Oops")
        case .authorizedWhenInUse:
            checkLocationServcies()
        case .authorizedAlways, .notDetermined:
            break
    }

}

}
