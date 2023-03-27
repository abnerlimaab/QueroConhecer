//
//  PlaceAnnotation.swift
//  QueroConhecer
//
//  Created by Abner Lima on 27/03/23.
//

import Foundation
import MapKit

class PlaceAnnotation: NSObject, MKAnnotation {
    
    enum PlaceType {
        case place
        case pointsOfInterest
    }
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var type: PlaceType
    var address: String?
    
    init(coordinate: CLLocationCoordinate2D, type: PlaceType) {
        self.coordinate = coordinate
        self.type = type
    }
    
}
