//
//  ViewController.swift
//  Memories
//
//  Created by Arsalan Wahid Asghar on 10/12/18.
//  Copyright © 2018 asghar. All rights reserved.
//
//
// 1. GetLocation action()
// 2. askForLocationService()
// 3. checkAvailableLocationServcies()
// 4. enableLocationServices() || disableLocationServices()

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController,CLLocationManagerDelegate {

    //MARK:- Properties
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError:Error?

    //GeoCoding properties
    let geocoder = CLGeocoder()
    var placeMark : CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: Error?

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
        configureGetButton()
    }


    //MARK:- Location Logic
    func askForLocationService() {

        //Asks for user permission to use location services
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            checkAvailableLocationServcies()
        case .authorizedAlways:
            break
        case .restricted, .denied:
            locationServiceDenied(with: "Location Service Disabled", message: "Enable Location Service", actionTitle: "ok")
        }
    }

    //Check for active location services
    func checkAvailableLocationServcies() {
        if CLLocationManager.locationServicesEnabled() {
            enableLocationBasedFeatures()
        }else {
            locationServiceDenied(with: "Location Service unavailabe", message: "Enable Location Service From Settings", actionTitle: "ok")
        }

        if CLLocationManager.headingAvailable() {
            //Do something realted to headingservice
        }else {
            //            locationServiceDenied(with: "Heading service not available", message: "Current hardware no supported", actionTitle: "Ok")
        }
    }

    // Start/setup the desired location features
    func enableLocationBasedFeatures() {

        locationManager.delegate = self
        //setting the location accuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters

        //start getting the users location
        locationManager.startUpdatingLocation()

        updatingLocation = true
    }

    //Stop the location features
    func disableLocationBasedFeatures() {
        //Stops getting the location
        if updatingLocation{
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
    }


    //MARK:- Alerts
    func locationServiceDenied(with title:String , message:String , actionTitle:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle, style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    //MARK:- View Updates
    func updateLabels() {

        if let location = location {
            self.latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            self.longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""
        }else {
            self.latitudeLabel.text = ""
            self.longitudeLabel.text = ""
            tagButton.isHidden = true
            messageLabel.text = "Tap 'Get My Location to Start'"

            //Show the user the approprite message based on the error recieved from the delegate methodd
            let statusMessage : String
            if let error = (lastLocationError as NSError?) {

                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                    statusMessage = "Location service Disabled"
                }else {
                    statusMessage = "Error getting location"
                }

            }else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location service disabled"
            }else if updatingLocation {
                statusMessage = "searching"
            }else {
                statusMessage = "Tap 'Get Location to start'"
            }
            messageLabel.text = statusMessage
        }
    }

    //Changes the text of the get location button
    func configureGetButton() {
        if updatingLocation {
            getButton.setTitle("Stop", for: .normal)
        } else {
            getButton.setTitle("Get My Location", for: .normal)
        }
    }




    //MARK:- Actions
    @IBAction func getLocation() {

        let authStatus = CLLocationManager.authorizationStatus()

        if authStatus == .notDetermined {
            // Do nothing
        }
        if authStatus == .denied || authStatus == .restricted {
            //Do nothing
        }

        if updatingLocation{
            disableLocationBasedFeatures()
            configureGetButton()
        }else {
            location = nil
            lastLocationError = nil
            askForLocationService()
            updateLabels()
            configureGetButton()
        }
    }


    //MARK:- CLLocationManagerDelegate

    //Error In Getting Location Are Obtained Here
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {

        print("didFailWithError \(error)")

        //Exit function if there is a location unknow error as device may need more time
        if (error as NSError).code == CLError.locationUnknown.rawValue{
            return
        }

        lastLocationError = error
        disableLocationBasedFeatures()
        updateLabels()
        configureGetButton()
    }


    //New Location Values Are Recieved Here
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        //Get the last location from the locations array
        let newLocation = locations.last!
        print("Location recieved: \(newLocation)")

        print("\(newLocation.timestamp.timeIntervalSinceNow)")

        //Discard old location readings
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }

        //Ignore horizonzal accuray values less than zero
        if newLocation.horizontalAccuracy < 0 {
            return
        }

        //Check if newlocation has better accuracy than old value
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {

            //Assign the new Location value
            location = newLocation
            lastLocationError = nil
            updateLabels()

            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy{
                print("*** Done with Location updates")
                disableLocationBasedFeatures()
                configureGetButton()
            }
        }

    }

    //Checks Change In Location Permissions
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {

        switch status {
        case .restricted,.denied:
            locationServiceDenied(with: "Location Service Disabled", message: "Please enable from settings", actionTitle: "Oops")

        case .authorizedWhenInUse:
            checkAvailableLocationServcies()

        case .authorizedAlways, .notDetermined:
            break
        }
    }
}
