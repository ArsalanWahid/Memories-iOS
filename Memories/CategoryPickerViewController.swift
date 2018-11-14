//
//  CategoryPickerViewController.swift
//  Memories
//
//  Created by Arsalan Wahid Asghar on 14/11/2018.
//  Copyright © 2018 asghar. All rights reserved.
//

import UIKit

class CategoryPickerViewController: UITableViewController {

    //MARK:- Properties

    var selectedCategoryName = ""

    let categories = ["No Category",
        "Apple Store",
        "Bar",
        "Bookstore",
        "Club",
        "Grocery Store",
        "Historic Building",
        "House",
        "Icecream Vendor",
        "Landmark",
        "Park"]

    var selectedIndexPath = IndexPath()

    override func viewDidLoad() {
        super.viewDidLoad()

        for i in 0..<categories.count{
            if categories[i] == selectedCategoryName{
                selectedIndexPath = IndexPath(row: i, section: 0)
                break
            }
        }
    }
    
    //MARK:- Tableview Datasource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "category", for: indexPath)

        let categoryName = categories[indexPath.row]
        cell.textLabel?.text = categoryName

        if categoryName == selectedCategoryName{
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none

        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row != selectedIndexPath.row {
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .checkmark
            }

            if let oldCell = tableView.cellForRow(at: selectedIndexPath) {
                oldCell.accessoryType = .none
            }
            selectedIndexPath = indexPath
        }
    }

    //MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //This also works for unwind segues
        if segue.identifier == "PickCategory"{
            let cell = sender as! UITableViewCell
            if let cellIndex = tableView.indexPath(for: cell){
                selectedCategoryName = categories[cellIndex.row]
            }
        }
    }

}
