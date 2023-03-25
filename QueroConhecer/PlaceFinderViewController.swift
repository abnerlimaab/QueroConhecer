//
//  PlaceFinderViewController.swift
//  QueroConhecer
//
//  Created by Abner Lima on 25/03/23.
//

import UIKit
import MapKit

class PlaceFinderViewController: UIViewController {
        
    @IBOutlet weak var tfCity: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!
    @IBOutlet weak var viLoading: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func findCity(_ sender: UIButton) {
        tfCity.resignFirstResponder()
        let address = tfCity.text!
        load(show: true)
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            self.load(show: false)
            
            guard let placemark = placemarks?.first else {return}
            
            print(Place.getFormattedAddress(with: placemark))
        }
    }
    
    func load(show: Bool) {
        viLoading.isHidden = !show
        
        show ? aiLoading.startAnimating() : aiLoading.stopAnimating()
     }
    
    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
