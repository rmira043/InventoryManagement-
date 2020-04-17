/////////////////////////////////////////////////////////////////////
//  PROGRAMMER: Reynaldo Miranda , Henry Benitez
//  PANTHER ID: 4709465 ,
//  CLASS: COP4655 ONLINE
//  INSTRUCTOR: Steven Luis ECS 282
//  DUE: SATURDAY 04/18/2020
//
//
//  SellViewController.swift
//  InventoryManagement
//
//  Created by Rey on 04/01/2020.
//  Copyright © 2020 Rey. All rights reserved.
//

import UIKit
import BarcodeScanner

class SellListViewController: UIViewController {

    //MARK:- Interface Builder
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK:- Properties
    var backupItemList = [Sell]()
    var soldItemList = [Sell]()
    var errorLabel: UILabel = {
        let label = UILabel()
        label.text = "No Items found! Please add some items to get started."
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textAlignment = .center
        return label
    }()
    
    var stackView = UIStackView()
    var qtyStepper = UIStepper()
    var qtyLabel = UILabel()
    var quantity = 1
    
    //MARK:- Viewcontroller LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //fetch all the sold items from the local database
        backupItemList = DatabaseHandler.fetchAllSoldItems()!
        soldItemList = DatabaseHandler.fetchAllSoldItems()!
        tableView.reloadData()
        
        //if there is no any sold item then display erro in middle of the screen
        if soldItemList.isEmpty {
            errorLabel.center = tableView.center
            tableView.backgroundView = errorLabel
        } else {
            tableView.backgroundView = nil
        }
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
    
    //this method gets call when user increment or decrement quantity while adding new entry
    @objc private func stepperValueChange(sender: UIStepper) {
        if Int(sender.value) >= quantity {
            //increment qty
            quantity += 1
            qtyLabel.text = "\(quantity)"
        } else {
            //descrement qty
            quantity -= 1
            qtyLabel.text = "\(quantity)"
        }
    }
}

//MARK:- Button Actions
extension SellListViewController {
    //this method gets called when user tap on right top add button
    @IBAction func addButtonPressed() {
        
        //initiate the barcode scanner view controller
        let barcodeScannerVC = BarcodeScannerViewController()
        barcodeScannerVC.codeDelegate = self
        barcodeScannerVC.errorDelegate = self
        barcodeScannerVC.dismissalDelegate = self

        //display barcode scanner on the screen
        present(barcodeScannerVC, animated: true, completion: nil)
    }
}

//MARK:- TableView Delegate and Datasource Methods
extension SellListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return soldItemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell") as! ItemTableViewCell
        if let name = soldItemList[indexPath.row].item?.name {
            cell.nameLabel.text = name
        } else {
            cell.nameLabel.text = "Item N/A in Stock"
        }
        
        if let category = soldItemList[indexPath.row].item?.category?.name {
            cell.categoryLabel.text = category
        } else {
            cell.categoryLabel.text = "-"
        }
        
        if let currency = soldItemList[indexPath.row].item?.currency?.name, let price = soldItemList[indexPath.row].item?.price {
            let currency = CurrencySymbol(rawValue: currency)!
            cell.priceLabel.text = "\(price * Double(soldItemList[indexPath.row].quantity))\(currency.symbol)"
        } else {
            cell.priceLabel.text = "-"
        }
        
        cell.qtyLabel.text = "\(soldItemList[indexPath.row].quantity)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85.0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //delete the employee from coredata
            DatabaseHandler.deleteSoldItem(soldItem: soldItemList[indexPath.row]) { (isDeleted, error) in
                if let error = error as? CustomError {
                    self.showAlert(title: "Error!", message: error.localizedDescription)
                } else {
                    if isDeleted {
                        self.soldItemList = DatabaseHandler.fetchAllSoldItems()!
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
}

//MARK:- Searchbar Delegate
extension SellListViewController: UISearchBarDelegate {
    //this method get's call when user changes search string in search textfield
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            soldItemList = backupItemList
            tableView.reloadData()
        }
        else {
            soldItemList = backupItemList.filter {($0.item!.name!.lowercased().contains(searchText.lowercased())) || ($0.item!.category!.name!.lowercased().contains(searchText.lowercased()))}
            tableView.reloadData()
        }
    }

}


//MARK:- Barcode Scanner Delegate Methods
extension SellListViewController: BarcodeScannerCodeDelegate, BarcodeScannerErrorDelegate, BarcodeScannerDismissalDelegate {
    //this method get's call when user successfully scanned the barcode
    func scanner(_ controller: BarcodeScannerViewController, didCaptureCode code: String, type: String) {
        //reset the barcode scanner controller
        controller.reset()
        
        //remove barcode scanner screen from screen
        controller.dismiss(animated: true) {
            //check if item is available with scanned barcode if no then display error
            guard let soldItem = DatabaseHandler.getItem(barcode: code) else {
                self.showAlert(title: "Error!", message: "No item found with this barcode in your stock.")
                return
            }
            //once the scanning complete diplay action sheet to select the how many qty then want to add
            let alertController = UIAlertController(title: "Add quantity\n\n\n\n\n\n", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            let margin:CGFloat = 10.0
            //configure userinteface for stepper and qty label
            self.stackView = UIStackView(frame: CGRect(x: margin, y: margin, width: alertController.view.bounds.size.width - margin * 4.0, height: 120))
            self.qtyStepper.addTarget(self, action: #selector(self.stepperValueChange(sender:)), for: .valueChanged)
            self.qtyStepper.minimumValue = 1
            self.qtyStepper.maximumValue = 100
            self.qtyLabel.text = "1"
            self.stackView.addArrangedSubview(self.qtyLabel)
            self.stackView.addArrangedSubview(self.qtyStepper)
            self.stackView.axis = .vertical
            self.stackView.alignment = .center
            
            //add stackview in alert controller
            alertController.view.addSubview(self.stackView)

            //once the user done selecting qty then user will press Ok button.
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                //check it the qty that user entered is available in stock. If not available then diplay error that stock is not available.
                if soldItem.quantity >= self.quantity {
                    //add item to sold item database
                    DatabaseHandler.addSoldItem(id: UUID(), item: soldItem, qty: self.quantity) { (isAdded, error) in
                        if let error = error as? CustomError {
                            self.showAlert(title: "Error!", message: error.localizedDescription)
                        }
                        if isAdded {
                            //if there is no any sold item then display erro in middle of the screen
                            if self.soldItemList.isEmpty {
                                self.errorLabel.center = self.tableView.center
                                self.tableView.backgroundView = self.errorLabel
                            } else {
                                self.tableView.backgroundView = nil
                            }
                            
                            //once the entry gets added, we need to update the actual qty of item in item database
                            DatabaseHandler.updateItemStockQty(item: soldItem, qty: self.quantity) { (isUpdated, error) in
                                if let error = error as? CustomError {
                                    self.showAlert(title: "Error!", message: error.localizedDescription)
                                }
                                if isUpdated {
                                    //once the stock updated then display item in tableview
                                    self.quantity = 1
                                    self.qtyStepper.value = 1
                                    self.soldItemList = DatabaseHandler.fetchAllSoldItems()!
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                } else {
                    self.showAlert(title: "Error!", message: "No stock available. Please update your stock.")
                }
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion:{})
        }
    }
    
    //this method gets call when there is error while scanning the barcode
    func scanner(_ controller: BarcodeScannerViewController, didReceiveError error: Error) {
        print(error)
    }
    
    //this method gets call when barcode scanner view get's dismissed
    func scannerDidDismiss(_ controller: BarcodeScannerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
