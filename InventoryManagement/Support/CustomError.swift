/////////////////////////////////////////////////////////////////////
//  PROGRAMMER: Reynaldo Miranda , Henry Benitez
//  PANTHER ID: 4709465 ,
//  CLASS: COP4655 ONLINE
//  INSTRUCTOR: Steven Luis ECS 282
//  DUE: SATURDAY 04/18/2020
//
//
//  CustomError.swift
//  InventoryManagement
//
//  Created by Rey on 04/01/2020.
//  Copyright © 2020 Rey. All rights reserved.
//

import Foundation

//this class is used to display the custom error to our user. It simply extends the system default Error protocol
class CustomError: Error {
    var domain: String = ""
    var code: Int = 0
    var localizedDescription: String = ""
    
    init(errorDomain: String, errorCode: Int, localizedDescription: String) {
        self.domain = errorDomain
        self.code = errorCode
        self.localizedDescription = localizedDescription
    }
    
    convenience init(description: String) {
        self.init(errorDomain: "", errorCode: 0, localizedDescription: description)
    }
}
