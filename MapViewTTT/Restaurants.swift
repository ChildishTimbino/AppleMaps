//
//  Restaurants.swift
//  MapViewTTT
//
//  Created by Timothy Hull on 2/22/17.
//  Copyright © 2017 Sponti. All rights reserved.
//

import UIKit
import MapKit

class Restaurants: NSObject, MKAnnotation {
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var url: URL?
    
    init(title: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.coordinate = coordinate
    }

    

}
