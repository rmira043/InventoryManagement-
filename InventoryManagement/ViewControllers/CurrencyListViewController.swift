/////////////////////////////////////////////////////////////////////
//  PROGRAMMER: Reynaldo Miranda , Henry Benitez
//  PANTHER ID: 4709465 ,
//  CLASS: COP4655 ONLINE
//  INSTRUCTOR: Steven Luis ECS 282
//  DUE: SATURDAY 04/18/2020
//
//
//  CurrencyListViewController.swift
//  InventoryManagement
//
//  Created by Rey on 04/01/2020.
//  Copyright © 2020 Rey. All rights reserved.
//

import UIKit

class CurrencyListViewController: UIViewController {

    //MARK:- Interface Builder
    @IBOutlet weak var tableView: UITableView!
    
    //MARK:- Properties
    var currencyList = [Currency]()
    
    //MARK:- Viewcontroller LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //fetch all the currencies from the local database
        self.currencyList = DatabaseHandler.fetchAllCurrency()!
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

//MARK:- TableView Delegate and Datasource Methods
extension CurrencyListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel!.text = currencyList[indexPath.row].name!
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //delete the currency from coredata
            DatabaseHandler.deleteCurrency(currency: currencyList[indexPath.row]) { (isDeleted, error) in
                if error != nil {
                    self.showAlert(title: "Error!", message: "Currency can not be deleted! Please try again later.")
                }
                if isDeleted {
                    self.currencyList = DatabaseHandler.fetchAllCurrency()!
                    self.tableView.reloadData()
                } else {
                    self.showAlert(title: "Error!", message: "Currency can not be deleted! Please try again later.")
                }
            }
        }
    }
}
