//
//  AppDelegate.swift
//  Todoey
//
//  Created by Jay Packer on 3/28/18.
//  Copyright © 2018 Jay Packer. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        //Print out location of realm database
        //print("Realm database stored at \(Realm.Configuration.defaultConfiguration.fileURL)")
        
        //Migration of Realm from old data models to new data models
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 2,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    
                    // For existing records, set dateCreated to April 5th, 2018 at 8:30AM
                    var dateComponents = DateComponents()
                    dateComponents.year = 2018
                    dateComponents.month = 4
                    dateComponents.day = 5
                    dateComponents.timeZone = TimeZone(abbreviation: "CST") // Central Standard Time
                    dateComponents.hour = 8
                    dateComponents.minute = 30
                    
                    // Create date from components
                    let userCalendar = Calendar.current // user calendar
                    let dateCreated = userCalendar.date(from: dateComponents)

                    // The enumerateObjects(ofType:_:) method iterates over every Item and Category object stored in the Realm file
                    migration.enumerateObjects(ofType: Item.className()) { oldObject, newObject in
                        newObject!["dateCreated"] = dateCreated
                    }
                    migration.enumerateObjects(ofType: Category.className()) { oldObject, newObject in
                        newObject!["dateCreated"] = dateCreated
                    }
                }
                //Implement new property of Category to assign and store a random background color
                if (oldSchemaVersion < 2) {
                    let randomBGColor = UIColor.randomFlat.hexValue()
                    migration.enumerateObjects(ofType: Category.className()) { oldObject, newObject in
                        //initially assign all categories a random color. Were this a production app, it would be best to somehow give each category a random color, but that would involve querying all the categories, looping over them, and then assigning each a random color.
                        newObject!["categoryBGColor"] = randomBGColor
                    }
                    
                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        // Now that we've told Realm how to handle the schema change, opening the file will automatically perform the migration
        do {
            _ = try Realm()
        } catch {
            print("Error initializing new realm. \(error)")
        }
        
        return true
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}
