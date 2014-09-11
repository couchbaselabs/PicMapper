//
//  AppDelegate.swift
//  PicMapper
//
//  Created by Chris Anderson on 9/9/14.
//  Copyright (c) 2014 Chris Anderson. All rights reserved.
//

import UIKit
import MapKit
import AssetsLibrary

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var database: CBLDatabase?


    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        // Override point for customization after application launch.
        setupCouchbase()
        importPhotos()
        return true
    }

    func setupCouchbase() {
        var manager = CBLManager.sharedInstance()
        var error: NSError?
        self.database = manager.databaseNamed("geo", error: &error)
        if (error != nil) {
            println(error)
            exit(-1)
        }
        setupViews()
    }
    
    func setupViews() {
        var geoView = self.database?.viewNamed("geo")
        var block: CBLMapBlock = {
            (doc: [NSObject: AnyObject]!, emit: CBLMapEmitBlock!) in
            if let long = doc["long"] as? NSNumber {
                if let lat = doc["lat"] as? NSNumber {
//                    let coord = NSArray(array: [long , lat])
//                    let geoJSON = NSDictionary(dictionary: ["type":"Point", "coordinates" : coord])
//                    println(coord[0].debugDescription)
                    let key: AnyObject! = CBLGeoPointKey(long, lat)
                    if key != nil {
                        emit(key, nil)
                    }
                }
            }

        }
        geoView?.setMapBlock(block, version: "2")
    }
    
    func importPhotos() {
        let assetsLibrary = ALAssetsLibrary()
        assetsLibrary.enumerateGroupsWithTypes(0xFFFFFFFF,
            usingBlock: {(group:ALAssetsGroup!, stop) in
                if group != nil {
                    NSLog("group %@", group!)
                    
                    group.enumerateAssetsUsingBlock { (asset, index, stop) in
                        if asset != nil {
                            let location: AnyObject! = asset.valueForProperty(ALAssetPropertyLocation)
                            if location != nil {
//                                NSLog("CLLocation %@", location? as CLLocation)
                                self.saveLocation(asset)
                            }
                        }
                    }
                }
            }, failureBlock: {(error:NSError!) in
                NSLog("error %@", error)
            })
    }
    
    func saveLocation(asset: ALAsset) {
        let location = asset.valueForProperty(ALAssetPropertyLocation) as CLLocation
        let rep = asset.defaultRepresentation()
        let url = rep.url()
        let thumb = asset.thumbnail().takeUnretainedValue()
        let img = UIImage(CGImage: thumb)
        NSLog("URL %@", url)
        var lat = location.coordinate.latitude
        var long = location.coordinate.longitude
        
        var doc = self.database?.documentWithID(url.absoluteString)
        var error: NSError?
        doc?.putProperties(["lat":lat,"long":long], error: &error)
        var rev = doc?.currentRevision.createRevision()
        let data = UIImageJPEGRepresentation(img, 0.75)
        rev?.setAttachmentNamed("thumb", withContentType: "image/jpeg", content: data)
        rev?.save(&error)
        if (error != nil && error?.code != 409) {
            println(error)
        }
    }
    
    func applicationWillResignActive(application: UIApplication!) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication!) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication!) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication!) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication!) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

