//
//  MapVC.swift
//  TRex
//
//  Created by Sys on 3/24/18.
//  Copyright © 2018 Sys. All rights reserved.
//

import UIKit
import MapKit
import Photos
import CoreLocation

class MapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

      let initialLocation = CLLocation(latitude: 53.900670, longitude: 27.557042)
       
        centerMapOnLocation(location: initialLocation)
        
    
        
       let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
        fetchResult.enumerateObjects ({result, index, stop in
            if let asset = result as? PHAsset {
                if let location = asset.location {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = location.coordinate
                    self.mapView.addAnnotation(annotation)
                }
            }
        })
    }

 
    let regionRadius: CLLocationDistance = 15000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }

}
