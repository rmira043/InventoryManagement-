/////////////////////////////////////////////////////////////////////
//  PROGRAMMER: Reynaldo Miranda , Henry Benitez
//  PANTHER ID: 4709465 ,
//  CLASS: COP4655 ONLINE
//  INSTRUCTOR: Steven Luis ECS 282
//  DUE: SATURDAY 04/18/2020
//
//
//  AddCurrencyViewController.swift
//  InventoryManagement
//
//  Created by Rey on 04/01/2020.
//  Copyright © 2020 Rey. All rights reserved.
//

import UIKit

class AddCurrencyViewController: UITableViewController {

    //MARK:- Interface Builder
    
    //MARK:- Properties
    
    //MARK:- Viewcontroller LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
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

extension AddCurrencyViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        let currencyName = cell.textLabel?.text!
        
        //add new currency in coredata
        DatabaseHandler.addCurrency(id: UUID(), currencyName: currencyName!) { (isAdded, error) in
            if let error = error as? CustomError {
                self.showAlert(title: "Error!", message: error.localizedDescription)
            }
            if isAdded {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.showAlert(title: "Error!", message: "Currency can not be added! Please try again later.")
            }
        }
    }
}
