//
//  MapViewController.swift
//  QueroConhecer
//
//  Created by Abner Lima on 25/03/23.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var viInfo: UIView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    
    var places: [Place]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.isHidden = true
        viInfo.isHidden = true
        
        if places.count == 1 {
            title = places[0].name
        } else {
            title = "Meus lugares"
        }

        for place in places {
            addToMap(place)
        }
        
        showPlaces()
    }
    
    func addToMap(_ place: Place) {
        let annotation = MKPointAnnotation()
        annotation.title = place.name
        annotation.coordinate = place.coordinate
        mapView.addAnnotation(annotation)
    }
    
    func showPlaces() {
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    @IBAction func showRoute(_ sender: UIButton) {
    }
    
    @IBAction func showSearchBar(_ sender: UIBarButtonItem) {
    }
}
