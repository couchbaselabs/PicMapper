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


    func application(application: UIApplication!, didFinishLaunchingWithOptions launchOptions: NSDictionary!) -> Bool {
        // Override point for customization after application launch.
        importPhotos()
        return true
    }

    func importPhotos() {
        let assetsLibrary = ALAssetsLibrary()
        var groups = [ALAssetsGroup]()

        assetsLibrary.enumerateGroupsWithTypes(0xFFFFFFFF,
            usingBlock: {(group:ALAssetsGroup!, stop) in
//                groups.append(group);
                if group != nil {
                    NSLog("group %@", group!)
                    
                    group.enumerateAssetsUsingBlock {
                        (asset, index, stop) in
                        if asset != nil {
                            let location: AnyObject? = asset.valueForProperty(ALAssetPropertyLocation)
                            if location.description != "nil" {
                                NSLog("CLLocation %@", location? as CLLocation)
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
        let location: AnyObject? = asset.valueForProperty(ALAssetPropertyLocation) as CLLocation
        let rep = asset.defaultRepresentation()
        let url = rep.url()
        //        let thumb = asset.thumbnail()
        NSLog("CLLocation %@", location? as CLLocation)
        NSLog("URL %@", url)
        

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

