/////////////////////////////////////////////////////////////////////
//  PROGRAMMER: Reynaldo Miranda , Henry Benitez
//  PANTHER ID: 4709465 ,
//  CLASS: COP4655 ONLINE
//  INSTRUCTOR: Steven Luis ECS 282
//  DUE: SATURDAY 04/18/2020
//
//
//  CategoryListViewController.swift
//  InventoryManagement
//
//  Created by Rey on 04/01/2020.
//  Copyright © 2020 Rey. All rights reserved.
//

import UIKit

class CategoryListViewController: UIViewController {

    //MARK:- Interface Builder
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- Properties
    var categoryList = [Category]()
    var selectedCategory: Category?
    var isEditMode: Bool?
    
    //MARK:- Viewcontroller LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //fetch all the categories from the local database
        self.categoryList = DatabaseHandler.fetchAllCategories()!
        self.tableView.reloadData()
    }
    
    //MARK:- Private Methods
    //this method will show alert message on this screen
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(
            UIAlertAction(title: "OK", style: .default, handler: nil)
        )
        self.present(alertController, animated: true, completion: nil)
    }

}

//MARK:- Button Actions
extension CategoryListViewController {
    //this method gets called when user tap on right top add button
    @IBAction func addButtonPressed() {
        //it means user want to add new category so set isEditMode false
        self.isEditMode = false
        
        //perform segue and open AddViewController
        self.performSegue(withIdentifier: "CategoryListToAddUpdate", sender: self)
    }
}

//MARK:- TableView Delegate and Datasource Methods
extension CategoryListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel!.text = categoryList[indexPath.row].name!
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedCategory = categoryList[indexPath.row]
        isEditMode = true
        performSegue(withIdentifier: "CategoryListToAddUpdate", sender: self)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //delete the category from coredata
            DatabaseHandler.deleteCategory(category: categoryList[indexPath.row]) { (isDeleted, error) in
                if error != nil {
                    self.showAlert(title: "Error!", message: "Category can not be deleted! Please try again later.")
                }
                if isDeleted {
                    self.categoryList = DatabaseHandler.fetchAllCategories()!
                    self.tableView.reloadData()
                } else {
                    self.showAlert(title: "Error!", message: "Category can not be deleted! Please try again later.")
                }
            }
        }
    }
}

//MARK:- Segue
extension CategoryListViewController {
    //this methods gets called when you performSegue(Ex. line 73)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CategoryListToAddUpdate" {
            let destinationVC = segue.destination as! AddCategoryViewController
            destinationVC.selectedCategory = selectedCategory
            destinationVC.isEditMode = self.isEditMode
        }
    }
}


