//
//  ViewController.swift
//  PicMapper
//
//  Created by Chris Anderson on 9/9/14.
//  Copyright (c) 2014 Chris Anderson. All rights reserved.
//

import UIKit
import MapKit
import Foundation

class ViewController: UIViewController, MKMapViewDelegate {
                            
    @IBOutlet weak var map: MKMapView!
    var database: CBLDatabase?
    var liveQuery: CBLLiveQuery?

    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        database = appDelegate.database
        displayMap()
        queryView()
    }

    func displayMap() {
        var location = CLLocationCoordinate2D(
            latitude: 16.40,
            longitude: -86.34
        )
        var span = MKCoordinateSpanMake(100, 100)
        var region = MKCoordinateRegion(center: location, span: span)
        map.setRegion(region, animated: true)
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var aView : MKAnnotationView? = mapView.dequeueReusableAnnotationViewWithIdentifier("annotateImg")
        if aView == nil {
            aView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotateImg")
        } else {
            aView?.annotation = annotation
        }
        var id = annotation.title;
        var doc = self.database?.documentWithID(id)
        var thumb = doc?.currentRevision.attachmentNamed("thumb")
        var data: NSData! = thumb?.content
        var img = UIImage(data: data)
        aView?.image = imageWithImage(img, scaledToSize: CGSize(width: 40, height: 40))
        return aView
    }
    
    func imageWithImage(image:UIImage, scaledToSize newSize:CGSize) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        image.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        var newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }
    
    func queryView() {
        let geoView = self.database?.viewNamed("geo")
        let query = geoView?.createQuery()
//        var bbox = CBLGeoRect(min: CBLGeoPoint(x: -100, y: 0), max: CBLGeoPoint(x: 180, y: 90))
//        query?.boundingBox = bbox
        self.liveQuery = query?.asLiveQuery()
        self.liveQuery?.addObserver(self, forKeyPath: "rows", options: nil, context: nil)
    }
    
    override func observeValueForKeyPath(keyPath: String!, ofObject object: AnyObject!, change: [NSObject : AnyObject]!, context: UnsafeMutablePointer<Void>) {
        if object as NSObject == self.liveQuery! {
            println("CHANGES! observeValueForKey: (object)")
            if let rows = self.liveQuery?.rows {
                 self.drawRows(rows)
            }
        }
    }
    
    
    
    func drawRows(rows:CBLQueryEnumerator) {
        var error: NSError?
        if (error != nil) {
            println(error)
        }
        let count = rows.count
        let countInt = Int(count)
        for var index = 0; index < countInt; ++index {
            var row = rows.rowAtIndex(UInt(index))
            var id = row?.documentID
            let props = row?.document.userProperties as [NSObject : AnyObject]!
            if let long = props["long"] as? NSNumber {
                if let lat = props["lat"] as? NSNumber {
                    var annotation = CustomPointAnnotation()
                    annotation.setCoordinate(CLLocationCoordinate2D(latitude: lat, longitude: long))
                    annotation.title = id
                    map.addAnnotation(annotation)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


class CustomPointAnnotation: MKPointAnnotation {
//    var image: NSImage 
}
