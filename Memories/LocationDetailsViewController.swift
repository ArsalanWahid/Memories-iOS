//
//  LocationTableViewController.swift
//  Memories
//
//  Created by Arsalan Wahid Asghar on 06/11/2018.
//  Copyright © 2018 asghar. All rights reserved.
//

import UIKit
import CoreLocation


//Will be lazy loded since its global and a closure as well
private let dateFormatter: DateFormatter = {
    let format = DateFormatter()
    format.dateStyle = .medium
    format.timeStyle = .short
    print("*** DateFormatter Made Only Once")
    return format
}()


class LocationDetailsViewController: UITableViewController {

    //MARK:- Outlets
    @IBOutlet weak var descrptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var longitudeTextLabel: UILabel!
    @IBOutlet weak var latitudeTextLabel: UILabel!
    @IBOutlet weak var addressTextLabel: UILabel!
    @IBOutlet weak var dateTextLabel: UILabel!

    //MARK:- Actions
    @IBAction func Done(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func Cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }


    //MARK:- Properties

    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    var selectedCategory = "No Category"

    //MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        categoryLabel.text = selectedCategory
        latitudeTextLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeTextLabel.text = String(format: "%.8f", coordinate.longitude)

        if let placemark = placemark{
            addressTextLabel.text = string(from: placemark)
        }else{
            addressTextLabel.text = "No address Found"
        }

        dateTextLabel.text = format(date: Date())
    }



    //MARK:- Placemark Formatter

    func string(from placemark: CLPlacemark) -> String {
        var text = ""
        if let s = placemark.subThoroughfare {
            text += s + " " }
        if let s = placemark.thoroughfare {
            text += s + ", "
        }
        if let s = placemark.locality {
            text += s + ", "
        }
        if let s = placemark.administrativeArea {
            text += s + " " }
        if let s = placemark.postalCode {
            text += s + ", "
        }
        if let s = placemark.country {
            text += s }
        return text
    }

    func format(date: Date) -> String{
        return dateFormatter.string(from: date)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }


    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0{
            return 88
        }else if indexPath.section == 2 && indexPath.row == 2 {
            addressTextLabel.frame.size = CGSize(width: view.bounds.width - 115, height: 10000)
            addressTextLabel.sizeToFit()
            addressTextLabel.frame.origin.x = view.bounds.width - addressTextLabel.frame.width - 20
            return addressTextLabel.frame.height + 20
        }
        else{
            return 44
        }
    }

    //MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       if segue.identifier == "PickCategory" {
            let controller  = segue.destination as!CategoryPickerViewController
            controller.selectedCategoryName = selectedCategory
        }
    }


    //Unwind segue
    @IBAction func categoryPickerDidPickCategory(_ segue: UIStoryboardSegue){
        let controller = segue.source as! CategoryPickerViewController
        selectedCategory = controller.selectedCategoryName
        categoryLabel.text = selectedCategory
    }

}
