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
    let syncURL = NSURL(string: "http://mineral.local:4984/geo")

    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
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
        setupSync()
    }
    
    func setupSync() {
        var pull = self.database?.createPullReplication(syncURL)
        pull?.continuous = true        
        var push = self.database?.createPushReplication(syncURL)
        push?.continuous = true
        pull?.start()
        push?.start()
    }
    
    func setupViews() {
        var geoView = self.database?.viewNamed("geo")
        var block: CBLMapBlock = {
            (doc: [NSObject: AnyObject]!, emit: CBLMapEmitBlock!) in
            if let long = doc["long"] as? NSNumber {
                if let lat = doc["lat"] as? NSNumber {
                    let key: AnyObject! = CBLGeoPointKey(long.doubleValue, lat.doubleValue)
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
                    self.database?.manager.backgroundTellDatabaseNamed("geo", to: { (db:CBLDatabase!) -> Void in
                        group.enumerateAssetsUsingBlock { (asset, index, stop) in
                            if asset != nil {
                                let location: AnyObject! = asset.valueForProperty(ALAssetPropertyLocation)
                                if location != nil {
                                    self.saveLocation(db, asset: asset)
                                }
                            }
                        }
                    })
                }
            }, failureBlock: {(error:NSError!) in
                NSLog("error %@", error)
            })
    }
    
    func saveLocation(database: CBLDatabase, asset: ALAsset) {
        let location = asset.valueForProperty(ALAssetPropertyLocation) as CLLocation
        let rep = asset.defaultRepresentation()
        let url = rep.url()
        let thumb = asset.thumbnail().takeUnretainedValue()
        let img = UIImage(CGImage: thumb)
        var lat = location.coordinate.latitude
        var long = location.coordinate.longitude
        
        var doc = database.documentWithID(url.absoluteString)
        var revid = doc.currentRevisionID
        if revid == nil {
            var error: NSError?
            doc?.putProperties(["lat":lat,"long":long], error: &error)
            if error == nil {
                var rev = doc?.currentRevision.createRevision()
                let data = UIImageJPEGRepresentation(img, 0.75)
                rev?.setAttachmentNamed("thumb", withContentType: "image/jpeg", content: data)
                rev?.save(&error)
                if (error != nil && error?.code != 409) {
                    println(error)
                }
            }
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

