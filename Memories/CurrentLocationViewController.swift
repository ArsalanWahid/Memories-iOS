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
    private let locationManager = CLLocationManager()
    private var location: CLLocation?
    var updatingLocation = false
    private var lastLocationError:Error?

    //GeoCoding properties
    private let geocoder = CLGeocoder()
    private var placeMark : CLPlacemark?
    var performingReverseGeocoding = false
    private var lastGeocodingError: Error?

    //Timer
    var timer:Timer?

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
        print("This is the class \(self.description)")
        updateLabels()
        configureGetButton()

    }


    //MARK:- Location Logic
    private func askForLocationService() {

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
    private func checkAvailableLocationServcies() {
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

        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(didTimeOut), userInfo: nil, repeats: false)

        locationManager.delegate = self
        //setting the location accuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters

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
            lastGeocodingError = nil

            if let timer = timer{
                //Stop the timer
                timer.invalidate()
            }
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
    private func updateLabels() {

        if let location = location {

            self.latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            self.longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagButton.isHidden = false
            messageLabel.text = ""

            if let placemark = placeMark {
                addressLabel.text = string(from: placemark) //Custom format method
            }else if performingReverseGeocoding {
                addressLabel.text = "Performing Reverse Geocoding"
            }else if lastGeocodingError != nil{
                addressLabel.text = "Error finding Address"
            }else{
                addressLabel.text = "No Address Found"
            }
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
                }else if error.domain == "KMemoriesErrorDomain"{
                    statusMessage = "Location timed Out"
                }else{
                    statusMessage = "Error Getting Location"
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

    //Custom formatting method for placemark address returned
    private func string(from placemark: CLPlacemark) -> String {
        var line1 = ""
        if let s = placemark.subThoroughfare{
            line1 += s + " "
        }

        if let s = placemark.thoroughfare{
            line1 += s
        }

        var line2 = ""

        if let s = placemark.locality {
            line2 += s + " "
        }
        if let s = placemark.administrativeArea {
            line2 += s + " "
        }
        if let s = placemark.postalCode {
            line2 += s
        }

        return line1 + "\n" + line2
    }

    //Changes the text of the get location button
    private func configureGetButton() {
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

            //Refersh state properties
            placeMark = nil
            lastGeocodingError = nil
            location = nil
            lastLocationError = nil
            askForLocationService()
            updateLabels()
            configureGetButton()
        }
    }

    //custom method for time out
    @IBAction func didTimeOut() {
        print("*** Time Out")
        disableLocationBasedFeatures()
        lastLocationError = NSError(domain: "KMemoriesErrorDomain", code: 1, userInfo: nil)
        updateLabels()
        configureGetButton()

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

        //Discard old location readings
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }

        //Ignore horizonzal accuray values less than zero
        if newLocation.horizontalAccuracy < 0 {
            return
        }

        //Managing accuracy issues
        var distance = CLLocationDistance.greatestFiniteMagnitude
        if let location = location{
            distance = newLocation.distance(from: location)
        }
        print("*** Distance between reading \(distance)")

        //Check if newlocation has better accuracy than old value
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {

            //Assign the new Location value
            location = newLocation
            lastLocationError = nil
            updateLabels()

            //MARK:- Location Manager Stopped
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("*** Done with Location updates")
                disableLocationBasedFeatures()
                configureGetButton()

                if distance > 0 {
                    performingReverseGeocoding = false
                }
            }

            //Geocoding code
            if !performingReverseGeocoding {
                print("*** Going to Geocode")
                performingReverseGeocoding = true

                //This function is being performed ayncronously and returns handler later
                geocoder.reverseGeocodeLocation(newLocation, completionHandler: {
                    (placemarks,error) in
                    if let error = error {
                        if (error as NSError).code == CLError.network.rawValue {
                            print("To many geocoding request being made")
                        }
                    }
                    //print("Found placemarks \(placemarks), error \(error)")

                    self.lastGeocodingError = error
                    if error == nil , let p = placemarks, !p.isEmpty {
                        self.placeMark = p.last!
                    }else{
                        self.placeMark = nil
                    }

                    self.performingReverseGeocoding = false
                    self.updateLabels()
                })
                print("*** Done Geocoding")
            }
        }else if distance < 1 {

            let timeinterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)

            //MARK:- Location Manger Stopped
            // if there isnt a better reading for 10 sections stop the location manager
            if timeinterval > 10{
                print("*** Force Done")
                disableLocationBasedFeatures()
                updateLabels()
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



