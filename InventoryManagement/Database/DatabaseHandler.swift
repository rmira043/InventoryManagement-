/////////////////////////////////////////////////////////////////////
//  PROGRAMMER: Reynaldo Miranda ,
//  PANTHER ID: 4709465 ,
//  CLASS: COP4655 ONLINE
//  INSTRUCTOR: Steven Luis ECS 282
//  DUE: SATURDAY 04/18/2020
//
//
//  DatabaseHandler.swift
//  InventoryManagement
//
//  Created by Rey on 04/01/2020.
//  Copyright © 2020 Rey. All rights reserved.
//

import UIKit
import CoreData

class DatabaseHandler {
    
    //this functions fetch all the items from coredata database
    class func fetchAllItems() -> [Item]? {
        //container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        
        //create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
        
        let categories = try? managedContext.fetch(fetchRequest)
        
        return categories
    }
    
    //this functions add a new item in database
    class func addItem(id: UUID, name: String, category: Category?, photo: Data?, price: Double, currency: Currency?, qty: Int, barcode: String, completion: @escaping (_ succeeded:Bool, _ error:Error?) -> Void) {
        //container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        //prepare the request of type NSFetchRequest  for the entity
        let item = NSEntityDescription.insertNewObject(forEntityName: "Item", into: managedContext) as? Item
        item?.id = id
        item?.name = name
        item?.category = category
        item?.price = price
        item?.currency = currency
        item?.quantity = Int16(qty)
        item?.barcode = barcode
        item?.image = photo
        
        do {
            try managedContext.save()
            completion(true, nil)
        } catch {
            print(error)
            print("Failed to add item")
            managedContext.reset()
            let error = CustomError(description: "Item can not be added! Please try again later.")
            completion(false, error)
        }
    }
    
    //this functions fetch update category in database
    class func updateItem(id: UUID, name: String, category: Category?, photo: Data?, price: Double, currency: Currency?, qty: Int, barcode: String, completion: @escaping (_ succeeded:Bool, _ error:Error?) -> Void) {
        //container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
        let predicate = NSPredicate(format: "%K == %@", "id", id as CVarArg)
        fetchRequest.predicate = predicate
        let objects = try? managedContext.fetch(fetchRequest)
        if let item = objects?.first {
            item.name = name
            item.category = category
            item.price = price
            item.currency = currency
            item.quantity = Int16(qty)
            item.barcode = barcode
            item.image = photo
            do {
                try managedContext.save()
                completion(true, nil)
            } catch let error {
                print("Failed")
                print(error.localizedDescription)
                let error = CustomError(description: "Something went wrong while updating item! Please try again later.")
                completion(false, error)
            }
        } else {
            let error = CustomError(description: "Please try again!")
            completion(false, error)
        }
    }
    
    //this functions fetch delete item from database
    class func deleteItem(item: Item, completion: @escaping (_ succeeded:Bool, _ error:Error?) -> Void) {
        //container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
        let predicate = NSPredicate(format: "%K == %@", "id", item.id! as CVarArg)
        fetchRequest.predicate = predicate
        let objects = try? managedContext.fetch(fetchRequest)
        if let category = objects?.first{
            managedContext.delete(category)
        } else {
            let error = CustomError(description: "Item can not be deleted! Please try again later.")
            completion(false, error)
        }
        
        do {
            try managedContext.save()
            completion(true, nil)
        } catch {
            print(error)
            print("Failed to delete Item")
            managedContext.reset()
            let error = CustomError(description: "Item can not be deleted! Please try again later.")
            completion(false, error)
        }
    }
    
    //this function will fetch item using barcode
    class func getItem(barcode: String) -> Item? {
        //container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        
        //create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
        let predicate = NSPredicate(format: "barcode = [c] %@", barcode)
        fetchRequest.predicate = predicate
        let objects = try? managedContext.fetch(fetchRequest)
        if let item = objects?.first{
            return item
        } else {
            return nil
        }
    }
    
    class func updateItemStockQty(item: Item, qty: Int, completion: @escaping (_ succeeded: Bool, _ error: Error?) -> Void) {
        //container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Item>(entityName: "Item")
        let predicate = NSPredicate(format: "%K == %@", "id", item.id! as CVarArg)
        fetchRequest.predicate = predicate
        let objects = try? managedContext.fetch(fetchRequest)
        if let item = objects?.first{
            item.quantity = item.quantity - Int16(qty)
            do {
                try managedContext.save()
                completion(true, nil)
            } catch let error {
                print("Failed")
                print(error.localizedDescription)
                managedContext.reset()
                let error = CustomError(description: "Something went wrong while updating item! Please try again later.")
                completion(false, error)
            }
        } else {
            let error = CustomError(description: "Please try again!")
            completion(false, error)
        }
    }
    
    //this functions fetch all the categories from coredata database
    class func fetchAllCategories() -> [Category]? {
        //container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        
        //create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Category>(entityName: "Category")
        
        let categories = try? managedContext.fetch(fetchRequest)
        
        return categories
    }
    
    //this functions fetch category using category name from database
    class func getCategory(name: String) -> Category? {
        //container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        
        //create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Category>(entityName: "Category")
       let predicate = NSPredicate(format: "name = [c] %@", name)
        fetchRequest.predicate = predicate
        let objects = try? managedContext.fetch(fetchRequest)
        if let category = objects?.first{
            return category
        } else {
            return nil
        }
    }
    
    //this functions add a new category in database
    class func addCategory(id: UUID, categoryName: String, completion: @escaping (_ succeeded:Bool, _ error:Error?) -> Void) {
        //container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        let fetchRequest = NSFetchRequest<Category>(entityName: "Category")
        let predicate = NSPredicate(format: "name = [c] %@", categoryName.lowercased())
        fetchRequest.predicate = predicate
        let objects = try? managedContext.fetch(fetchRequest)
        
        // There should be no objects found if it's unique
        if objects!.count == 0 {
            //prepare the request of type NSFetchRequest  for the entity
            let category = NSEntityDescription.insertNewObject(forEntityName: "Category", into: managedContext) as? Category
            category?.id = id
            category?.name = categoryName
            
            do {
                try managedContext.save()
                completion(true, nil)
            } catch {
                print(error)
                print("Failed to add category")
                managedContext.reset()
                let error = CustomError(description: "Failed to add category!")
                completion(false, error)
            }
        } else {
            let error = CustomError(description: "Category alrealy exist." )
            completion(false, error)
        }
    }
    
    //this functions fetch update category in database
    class func updateCategory(id: UUID, categoryName: String, completion: @escaping (_ succeeded:Bool, _ error:Error?) -> Void) {
        //container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Category>(entityName: "Category")
        let predicate = NSPredicate(format: "name = [c] %@", categoryName.lowercased())
        fetchRequest.predicate = predicate
        let objects = try? managedContext.fetch(fetchRequest)
        if let CategoryItem = objects?.first {
            let fetchRequest_unique = NSFetchRequest<Category>(entityName: "Category")
            let predicate_unique = NSPredicate(format: "name = [c] %@", categoryName.lowercased())
            fetchRequest_unique.predicate = predicate_unique
            let objects = try? managedContext.fetch(fetchRequest_unique)
            if objects!.count == 0 {
                CategoryItem.name = categoryName
                do {
                    try managedContext.save()
                    completion(true, nil)
                } catch let error {
                    print("Failed")
                    print(error.localizedDescription)
                    let error = CustomError(description: "Something went wrong while updating data! Please try again later.")
                    completion(false, error)
                }
            } else {
                let error = CustomError(description: "Category alrealy exist." )
                completion(false, error)
            }
        } else {
            let error = CustomError(description: "Please try again!")
            completion(false, error)
        }
    }
    
    //this functions fetch delete employee from database
    class func deleteCategory(category: Category, completion: @escaping (_ succeeded:Bool, _ error:Error?) -> Void) {
        //container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Category>(entityName: "Category")
        let predicate = NSPredicate(format: "%K == %@", "id", category.id! as CVarArg)
        fetchRequest.predicate = predicate
        let objects = try? managedContext.fetch(fetchRequest)
        if let category = objects?.first{
            managedContext.delete(category)
        } else {
            completion(false, nil)
        }
        
        do {
            try managedContext.save()
            completion(true, nil)
        } catch {
            print(error)
            print("Failed to delete category")
            managedContext.reset()
            completion(false, error)
        }
    }
    
    //this functions fetch all the categories from coredata database
    class func fetchAllCurrency() -> [Currency]? {
        //container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        
        //create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Currency>(entityName: "Currency")
        
        let currencies = try? managedContext.fetch(fetchRequest)
        
        return currencies
    }
    
    //this functions fetch currency using currency name from database
    class func getCurrency(name: String) -> Currency? {
        //container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        
        //create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Currency>(entityName: "Currency")
       let predicate = NSPredicate(format: "name = [c] %@", name)
        fetchRequest.predicate = predicate
        let objects = try? managedContext.fetch(fetchRequest)
        if let currency = objects?.first{
            return currency
        } else {
            return nil
        }
    }
    
    //this functions add a new currency in database
    class func addCurrency(id: UUID, currencyName: String, completion: @escaping (_ succeeded:Bool, _ error:Error?) -> Void) {
        //container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Currency>(entityName: "Currency")
        let predicate = NSPredicate(format: "name = [c] %@", currencyName.lowercased())
        fetchRequest.predicate = predicate
        let objects = try? managedContext.fetch(fetchRequest)
        
        // There should be no objects found if it's unique
        if objects!.count == 0 {
            //prepare the request of type NSFetchRequest  for the entity
            let currency = NSEntityDescription.insertNewObject(forEntityName: "Currency", into: managedContext) as? Currency
            currency?.id = id
            currency?.name = currencyName
            
            do {
                try managedContext.save()
                completion(true, nil)
            } catch {
                print(error)
                print("Failed to add category")
                managedContext.reset()
                completion(false, error)
            }
        } else {
            let error = CustomError(description: "Currency alrealy exist." )
            completion(false, error)
        }
    }
    
    //this functions fetch delete currency from database
    class func deleteCurrency(currency: Currency, completion: @escaping (_ succeeded:Bool, _ error:Error?) -> Void) {
        //container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Currency>(entityName: "Currency")
        let predicate = NSPredicate(format: "%K == %@", "id", currency.id! as CVarArg)
        fetchRequest.predicate = predicate
        let objects = try? managedContext.fetch(fetchRequest)
        if let category = objects?.first{
            managedContext.delete(category)
        } else {
            completion(false, nil)
        }
        
        do {
            try managedContext.save()
            completion(true, nil)
        } catch {
            print(error)
            print("Failed to delete currency")
            managedContext.reset()
            completion(false, error)
        }
    }
    
    
    //this functions fetch all the sold items from coredata database
    class func fetchAllSoldItems() -> [Sell]? {
        //container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        
        //create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Sell>(entityName: "Sell")
        
        let soldItems = try? managedContext.fetch(fetchRequest)
        
        return soldItems
    }
    
    //this functions add a new sold items in database
    class func addSoldItem(id: UUID, item: Item, qty: Int, completion: @escaping (_ succeeded:Bool, _ error:Error?) -> Void) {
        //container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        
        //prepare the request of type NSFetchRequest  for the entity
        let soldItem = NSEntityDescription.insertNewObject(forEntityName: "Sell", into: managedContext) as? Sell
        soldItem?.id = id
        soldItem?.quantity = Int16(qty)
        soldItem?.item = item
        
        do {
            try managedContext.save()
            completion(true, nil)
        } catch {
            print(error)
            print("Failed to add sold item")
            managedContext.reset()
            let error = CustomError(description: "Item can not be added! Please try again later.")
            completion(false, error)
        }
    }
    
    //this functions delete sold item from database
    class func deleteSoldItem(soldItem: Sell, completion: @escaping (_ succeeded:Bool, _ error:Error?) -> Void) {
        //container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Sell>(entityName: "Sell")
        let predicate = NSPredicate(format: "%K == %@", "id", soldItem.id! as CVarArg)
        fetchRequest.predicate = predicate
        let objects = try? managedContext.fetch(fetchRequest)
        if let category = objects?.first{
            managedContext.delete(category)
        } else {
            let error = CustomError(description: "Item can not be deleted! Please try again later.")
            completion(false, error)
        }
        
        do {
            try managedContext.save()
            completion(true, nil)
        } catch {
            print(error)
            print("Failed to delete Item")
            managedContext.reset()
            let error = CustomError(description: "Item can not be deleted! Please try again later.")
            completion(false, error)
        }
    }
}

