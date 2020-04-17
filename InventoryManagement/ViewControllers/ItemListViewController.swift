/////////////////////////////////////////////////////////////////////
//  PROGRAMMER: Reynaldo Miranda , Henry Benitez
//  PANTHER ID: 4709465 ,
//  CLASS: COP4655 ONLINE
//  INSTRUCTOR: Steven Luis ECS 282
//  DUE: SATURDAY 04/18/2020
//
//
//  ItemListViewController.swift
//  InventoryManagement
//
//  Created by Rey on 04/01/2020.
//  Copyright © 2020 Rey. All rights reserved.
//

import UIKit


//This enum is used to identify the symbol of currency
enum CurrencySymbol: String {
    case usd = "USD"
    case gbp = "GBP"
    case eur = "EUR"
    
    var symbol: String {
        switch self {
        case .usd:
            return "$"
        case .gbp:
            return "£"
        case .eur:
            return "€"
        }
    }
}

class ItemListViewController: UIViewController {

    //MARK:- Interface Builder
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARK:- Properties
    var backupItemList = [Item]()
    var itemList = [Item]()
    var selectedItem: Item?
    var isEditMode: Bool?
    var errorLabel: UILabel = {
        let label = UILabel()
        label.text = "No Items found! Please add some items to get started."
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 12.0)
        label.textAlignment = .center
        return label
    }()
    
    //MARK:- Viewcontroller LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //default selected item should be nil
        selectedItem = nil
        
        //fetch all the items from the local database and store in properties
        backupItemList = DatabaseHandler.fetchAllItems()!
        itemList = DatabaseHandler.fetchAllItems()!
        tableView.reloadData()
        
        //display error if there is no items available
        if itemList.isEmpty {
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

}

//MARK:- Button Actions
extension ItemListViewController {
    //this method gets called when user tap on right top add button
    @IBAction func addButtonPressed() {
        //it means user want to add new item so set isEditMode false
        self.isEditMode = false
        
        //perform segue and open AddViewController
        self.performSegue(withIdentifier: "ItemListToAddUpdate", sender: self)
    }
    
    //this methods gets called when filter buttom from left side of screen pressed
    @IBAction func filterButtonPressed() {
        let alertController = UIAlertController(title: "Filter", message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let defaultAction = UIAlertAction(title: "Default", style: .default) { (action) in
            print("Default")
            self.itemList = self.backupItemList
            self.tableView.reloadData()
        }
        
        let itemNameAscendingAction = UIAlertAction(title: "Item Name(Ascending)", style: .default) { (action) in
            print("Item Name(Ascending)")
            self.itemList.sort {$0.name!.lowercased() < $1.name!.lowercased()}
            self.tableView.reloadData()
        }
        
        let itemNameDescendingAction = UIAlertAction(title: "Item Name(Descending)", style: .default) { (action) in
            print("Item Name(Descending)")
            self.itemList.sort {$0.name!.lowercased() > $1.name!.lowercased()}
            self.tableView.reloadData()
        }
        
        let categoryNameAscendingAction = UIAlertAction(title: "Category Name(Ascending)", style: .default) { (action) in
            print("Category Name(Ascending)")
            self.itemList.sort {$0.category!.name!.lowercased() < $1.category!.name!.lowercased()}
            self.tableView.reloadData()
        }
        
        let categoryNameDescendingAction = UIAlertAction(title: "Category Name(Descending)", style: .default) { (action) in
            print("Category Name(Descending)")
            self.itemList.sort {$0.category!.name!.lowercased() > $1.category!.name!.lowercased()}
            self.tableView.reloadData()
        }
        
        let stockAscendingAction = UIAlertAction(title: "Stock (Ascending)", style: .default) { (action) in
            print("Stock (Ascending)")
            self.itemList.sort {$0.quantity < $1.quantity}
            self.tableView.reloadData()
        }
        
        let stockDescendingAction = UIAlertAction(title: "Stock (Descending)", style: .default) { (action) in
            print("Stock (Descending)")
            self.itemList.sort {$0.quantity > $1.quantity}
            self.tableView.reloadData()
        }
        
        let priceAscendingAction = UIAlertAction(title: "Price (Ascending)", style: .default) { (action) in
            print("Price (Ascending)")
            self.itemList.sort {$0.price < $1.price}
            self.tableView.reloadData()
        }
        
        let priceDescendingAction = UIAlertAction(title: "Price (Descending)", style: .default) { (action) in
            print("Price (Descending)")
            self.itemList.sort {$0.price > $1.price}
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(defaultAction)
        alertController.addAction(itemNameAscendingAction)
        alertController.addAction(itemNameDescendingAction)
        alertController.addAction(categoryNameAscendingAction)
        alertController.addAction(categoryNameDescendingAction)
        alertController.addAction(stockAscendingAction)
        alertController.addAction(stockDescendingAction)
        alertController.addAction(priceAscendingAction)
        alertController.addAction(priceDescendingAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

//MARK:- TableView Delegate and Datasource Methods
extension ItemListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell") as! ItemTableViewCell
        cell.nameLabel.text = itemList[indexPath.row].name
        cell.categoryLabel.text = itemList[indexPath.row].category?.name
        let currency = CurrencySymbol(rawValue: itemList[indexPath.row].currency!.name!)!
        cell.priceLabel.text = "\(itemList[indexPath.row].price)\(currency.symbol)"
        cell.qtyLabel.text = "\(itemList[indexPath.row].quantity)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedItem = itemList[indexPath.row]
        isEditMode = true
        performSegue(withIdentifier: "ItemListToAddUpdate", sender: self)
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
            DatabaseHandler.deleteItem(item: itemList[indexPath.row]) { (isDeleted, error) in
                if let error = error as? CustomError {
                    self.showAlert(title: "Error!", message: error.localizedDescription)
                } else {
                    if isDeleted {
                        self.itemList = DatabaseHandler.fetchAllItems()!
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
}

//MARK:- Searchbar Delegate
extension ItemListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //filter out the items when text gets change in search box
        
        //display all if search textfield is blank
        if searchText == "" {
            itemList = backupItemList
            tableView.reloadData()
        }
        else {
            //display according to search text
            //search works with item name and category name
            itemList = backupItemList.filter {($0.name!.lowercased().contains(searchText.lowercased())) || ($0.category!.name!.lowercased().contains(searchText.lowercased()))}
            tableView.reloadData()
        }
    }

}

//MARK:- Segue
extension ItemListViewController {
    //this methods gets called when you performSegue(Ex. line 84)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ItemListToAddUpdate" {
            let destinationVC = segue.destination as! AddItemViewController
            destinationVC.selectedItem = selectedItem
            destinationVC.isEditMode = self.isEditMode
        }
    }
}
