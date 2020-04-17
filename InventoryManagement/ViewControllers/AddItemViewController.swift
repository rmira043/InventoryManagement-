/////////////////////////////////////////////////////////////////////
//  PROGRAMMER: Reynaldo Miranda , Henry Benitez
//  PANTHER ID: 4709465 ,
//  CLASS: COP4655 ONLINE
//  INSTRUCTOR: Steven Luis ECS 282
//  DUE: SATURDAY 04/18/2020
//
//
//  AddItemViewController.swift
//  InventoryManagement
//
//  Created by Rey on 04/01/2020.
//  Copyright © 2020 Rey. All rights reserved.
//

import UIKit

class AddItemViewController: UIViewController {

    //MARK:- Interface Builder
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var numberOfPhotoButton: UIButton!
    @IBOutlet weak var choosePhotoButton: UIButton!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var currencyTextField: UITextField!
    @IBOutlet weak var stockQtyTextField: UITextField!
    @IBOutlet weak var barcodeTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    //MARK:- Properties
    var selectedItem: Item?
    var isEditMode: Bool?
    var imagePicker =  UIImagePickerController()
    var selectedPhoto: UIImage?
    var isPhotoSelected = false {
        didSet{
            numberOfPhotoButton.setTitle("Photo selected", for: .normal)
        }
    }
    
    let pickerView = UIPickerView()
    var pickerData = [String]()
    
    //MARK:- Viewcontroller LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        if isEditMode == true {
            title = "Edit Item"
        } else {
            title = "Add Item"
        }
        loadData()
    }
    
    private func configureUI() {
        
        //adds Button on textfield that requires.
        addDoneButtonOnKeyboard(for: priceTextField)
        addDoneButtonOnKeyboard(for: stockQtyTextField)
        addDoneButtonOnKeyboard(for: categoryTextField)
        addDoneButtonOnKeyboard(for: currencyTextField)
        
        //set the pickerview to inputview of textfield that required. Ex. Category and Currency
        categoryTextField.inputView = pickerView
        currencyTextField.inputView = pickerView
        pickerView.delegate = self
    }
    //this methods check for all the inputs
    private func isValidInputs() -> Bool {
        if nameTextField.text == "" {
            self.showAlert(title: "Input Error!", message: "Please enter Item Name.")
            return false
        } else if categoryTextField.text == "" {
            self.showAlert(title: "Input Error!", message: "Please select Category.")
            return false
        }  else if priceTextField.text == "" {
           self.showAlert(title: "Input Error!", message: "Please enter Price.")
           return false
        } else if currencyTextField.text == "" {
            self.showAlert(title: "Input Error!", message: "Please select Currency.")
            return false
        } else if stockQtyTextField.text == "" {
            self.showAlert(title: "Input Error!", message: "Please enter Quantity.")
            return false
        } else if barcodeTextField.text == "" {
           self.showAlert(title: "Input Error!", message: "Please enter Barcode.")
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
            nameTextField.text = selectedItem!.name
            categoryTextField.text = selectedItem!.category?.name
            let titleForNumberOfPhotoButton = selectedItem!.image == nil ? "No photo selected" : "Photo selected"
            numberOfPhotoButton.setTitle(titleForNumberOfPhotoButton, for: .normal)
            priceTextField.text = "\(selectedItem!.price)"
            currencyTextField.text = selectedItem!.currency?.name
            stockQtyTextField.text = "\(selectedItem!.quantity)"
            barcodeTextField.text = selectedItem!.barcode
        }
    }
    
    //this method is called when user select Camera option while uploading the photo
    private func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //this method is called when user select Gallery option while uploading the photo
    private func openGallery() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have permission to access gallery.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

//MARK:- Button Actions
extension AddItemViewController {
    //this method gets call when user press on save button
    @IBAction func saveButtonPressed() {
        if self.isEditMode == true {
            if self.isValidInputs() {
                //update Item in coredata
                let category = DatabaseHandler.getCategory(name: categoryTextField.text!)
                let currency = DatabaseHandler.getCurrency(name: currencyTextField.text!)
                let imageData = selectedPhoto == nil ? nil : UIImageJPEGRepresentation(selectedPhoto!, 1)
                let price = Double(priceTextField.text!)!
                let qty = Int(stockQtyTextField.text!)!
                
                DatabaseHandler.updateItem(id: selectedItem!.id!, name: nameTextField.text!, category: category, photo: imageData, price: price, currency: currency, qty: qty, barcode: barcodeTextField.text!) { (isAdded, error) in
                    if let error = error as? CustomError {
                        self.showAlert(title: "Error!", message: error.localizedDescription)
                    }
                    if isAdded {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        } else {
            if self.isValidInputs() {
                //add new Item in coredata
                let category = DatabaseHandler.getCategory(name: categoryTextField.text!)
                let currency = DatabaseHandler.getCurrency(name: currencyTextField.text!)
                let imageData = selectedPhoto == nil ? nil : UIImageJPEGRepresentation(selectedPhoto!, 1)
                let price = Double(priceTextField.text!)!
                let qty = Int(stockQtyTextField.text!)!
                
                DatabaseHandler.addItem(id: UUID(), name: nameTextField.text!, category: category, photo: imageData, price: price, currency: currency, qty: qty, barcode: barcodeTextField.text!) { (isAdded, error) in
                    if let error = error as? CustomError {
                        self.showAlert(title: "Error!", message: error.localizedDescription)
                    }
                    if isAdded {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    //this method gte's call when user press on camera button from swift
    @IBAction func choosePhotoButtonPressed() {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))

        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))

        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    
    //this method gets calle when selected photo button pressed
    @IBAction func numberOfPhotoButtonPressed() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "ImagePreviewViewController") as! ImagePreviewViewController
        vc.selectedPhotoData = selectedItem?.image
        self.present(vc, animated: true, completion: nil)
    }
}

//MARK:- ImagePicker delegate
extension AddItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //this method get's call when user done with photo selection
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedPhoto = image
            isPhotoSelected = true
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

//MARK:- TextField Delegate Methods
extension AddItemViewController: UITextFieldDelegate {
    //this method gets call when user select textfield to enter input
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        pickerData.removeAll()
        
        //if the textfield is for category then fetch categories from database and display in the picker
        if textField == categoryTextField {
            let categories = DatabaseHandler.fetchAllCategories()!
            if !categories.isEmpty {
                for cat in categories {
                    pickerData.append(cat.name!)
                    
                }
                pickerView.reloadAllComponents()
            }
        } else if textField == currencyTextField {
            //if the textfield is for currency then fetch currencies from database and display in the picker
            let currencies = DatabaseHandler.fetchAllCurrency()!
            if !currencies.isEmpty {
                for currency in currencies {
                    pickerData.append(currency.name!)
                }
                pickerView.reloadAllComponents()
            }
        }
        return true
    }
    
    //release the focus from textfield
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
}

//MARK:- Picker Datasource and Delegate Methods
extension AddItemViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    //how many number of components should display in picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //how many number of item should be display in picker list
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    //title for perticular ite,
    func pickerView( _ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }

    //gets call when user cahnge the selection in pickerview
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerData.isEmpty { return }
        if categoryTextField.isFirstResponder {
            categoryTextField.text = pickerData[row]
        } else if currencyTextField.isFirstResponder {
            currencyTextField.text = pickerData[row]
        }
        
    }
}
