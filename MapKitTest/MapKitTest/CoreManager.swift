//
//  CoreManager.swift
//  MapKitTest
//
//  Created by Kiryl Rakk on 28/12/22.
//

import UIKit
import CoreData

class CoreManager {
    
    // MARK: - Core Data stack
    
    static let share  = CoreManager()
    init () {
        reloadData()
    }


    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "MapKitTest")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    // MARK: - Core Data Saving support
    var points = [Points]()
    
    func reloadData() {
        let request = Points.fetchRequest()
        let points = (try? persistentContainer.viewContext.fetch(request)) ?? []
        self.points = points
    }

    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func addPinsInCoreData(pin: Pin) {
        persistentContainer.performBackgroundTask { backgroundContext in
            let point = Points(context: backgroundContext)
            point.longitude = pin.longitude
            point.latitude = pin.latitude
            do {
                try backgroundContext.save()
            } catch {
                print(error.localizedDescription)
            }
            print("Pin was saved")
        }
        
    }
    
    func getPins() -> [Points]? {
        let fetchRequest = Points.fetchRequest()
        return try? persistentContainer.viewContext.fetch(fetchRequest) 
    }
}
