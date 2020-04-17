/////////////////////////////////////////////////////////////////////
//  PROGRAMMER: Reynaldo Miranda , Henry Benitez
//  PANTHER ID: 4709465 ,
//  CLASS: COP4655 ONLINE
//  INSTRUCTOR: Steven Luis ECS 282
//  DUE: SATURDAY 04/18/2020
//
//
//  AddCategoryViewController.swift
//  InventoryManagement
//
//  Created by Rey on 04/01/2020.
//  Copyright © 2020 Rey. All rights reserved.
//

import UIKit

class AddCategoryViewController: UIViewController {

    //MARK:- Interface Builder
    @IBOutlet weak var categoryNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    //MARK:- Properties
    var selectedCategory: Category?
    var isEditMode: Bool?
    
    //MARK:- Viewcontroller LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        //display appropriate title whether user in Add mode or Edit mode
        if isEditMode == true {
            title = "Edit Category"
        } else {
            title = "Add Category"
        }
        loadData()
    }
    
    //this methods check for all the inputs
    private func isValidInputs() -> Bool {
        if categoryNameTextField.text == "" {
            self.showAlert(title: "Input Error!", message: "Please enter Category Name.")
            return false
        } else {
            return true
        }
    }
    
    //this method will show alert message on this screen
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(
            UIAlertAction(title: "OK", style: .default, handler: nil)
        )
        self.present(alertController, animated: true, completion: nil)
    }
    
    //MARK:- Private Methods
    
    //this method populate the data by checking user is in add mode or in edit mode
    private func loadData() {
        // isEditmode = true means user is in Edit mode so display all the data in respected texfields
        if isEditMode == true {
            categoryNameTextField.text = selectedCategory!.name
        }
    }
    
    //this method gets call when user press on save button
    @IBAction func saveButtonPressed() {
        if self.isEditMode == true {
            if self.isValidInputs() {
                //update category in coredata
                DatabaseHandler.updateCategory(id: selectedCategory!.id!, categoryName: categoryNameTextField.text!) { (isUpdated, error) in
                    if let error = error as? CustomError {
                        self.showAlert(title: "Error!", message: error.localizedDescription)
                    }
                    if isUpdated {
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.showAlert(title: "Error!", message: "Category can not be updated! Please try again later.")
                    }
                }
            }
        } else {
            if self.isValidInputs() {
                //add new category in coredata
                DatabaseHandler.addCategory(id: UUID(), categoryName: categoryNameTextField.text!) { (isAdded, error) in
                    if let error = error as? CustomError {
                        self.showAlert(title: "Error!", message: error.localizedDescription)
                    }
                    if isAdded {
                        self.navigationController?.popViewController(animated: true)
                    } else {
                        self.showAlert(title: "Error!", message: "Category can not be added! Please try again later.")
                    }
                }
            }
        }
    }


}

