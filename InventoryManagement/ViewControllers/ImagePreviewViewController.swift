/////////////////////////////////////////////////////////////////////
//  PROGRAMMER: Reynaldo Miranda , Henry Benitez
//  PANTHER ID: 4709465 ,
//  CLASS: COP4655 ONLINE
//  INSTRUCTOR: Steven Luis ECS 282
//  DUE: SATURDAY 04/18/2020
//
//
//  ImagePreviewViewController.swift
//  InventoryManagement
//
//  Created by Rey on 04/01/2020.
//  Copyright © 2020 Rey. All rights reserved.
//

import UIKit

class ImagePreviewViewController: UIViewController {
    
    //MARK:- Interface Builder
    @IBOutlet weak var imageView: UIImageView!
    
    //MARK:- Properties
    var selectedPhotoData: Data?
    
    //MARK:- Viewcontroller LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        if let data = selectedPhotoData {
            imageView.image = UIImage(data: data)
        }
    }
}

//MARK:- Button Actions
extension ImagePreviewViewController {
    @IBAction func closeButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
}
