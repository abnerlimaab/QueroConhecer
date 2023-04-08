//
//  MapViewController.swift
//  QueroConhecer
//
//  Created by Abner Lima on 25/03/23.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    enum MapMessageType {
        case routeError
        case authorizationWarn
    }

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var viInfo: UIView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    var places: [Place]!
    var pointsOfInterest: [MKAnnotation] = []
    lazy var locationManager = CLLocationManager()
    var btUserLocation: MKUserTrackingButton!
    var selectedAnnotation: PlaceAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.isHidden = true
        viInfo.isHidden = true
        
        mapView.mapType = .mutedStandard
        mapView.delegate = self
        
        locationManager.delegate = self
        
        if places.count == 1 {
            title = places[0].name
        } else {
            title = "Meus lugares"
        }

        for place in places {
            addToMap(place)
        }
        
        configureLocationButton()
        showPlaces()
        requestUserLoacationAuthorization()
    }
    
    func configureLocationButton() {
        btUserLocation = MKUserTrackingButton(mapView: mapView)
        btUserLocation.backgroundColor = .white
        btUserLocation.frame.origin.x = 10
        btUserLocation.frame.origin.y = 10
        btUserLocation.layer.cornerRadius = 5
        btUserLocation.layer.borderWidth = 1
        btUserLocation.layer.borderColor = UIColor(named: "main")?.cgColor
    }
    
    func requestUserLoacationAuthorization() {
        if CLLocationManager.locationServicesEnabled() {
            switch locationManager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                mapView.addSubview(btUserLocation)
            case .denied:
                showMessage(type: .authorizationWarn)
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
            default:
                break
            }
        }
    }
    
    func showMessage(type: MapMessageType) {
        let title = type == .authorizationWarn ? "Aviso" : "Erro"
        let message = type == .authorizationWarn ? "Para usar os recursos de localização do App, você precisa permiri o uso na tela de ajustes" : "Não foi possível encontrar esta rota"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel)
        alert.addAction(cancelAction)
        
        if type == .authorizationWarn {
            let confirmAction = UIAlertAction(title: "Ir para Ajustes", style: .default) { action in
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                }
            }
            
            alert.addAction(confirmAction)
        }
        
        present(alert, animated: true)
    }
    
    func addToMap(_ place: Place) {
        let annotation = PlaceAnnotation(coordinate: place.coordinate, type: .place)
        annotation.title = place.name
        annotation.address = place.address
        mapView.addAnnotation(annotation)
    }
    
    func showPlaces() {
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    func showInfo() {
        lbName.text = selectedAnnotation?.title
        lbAddress.text = selectedAnnotation?.address
        viInfo.isHidden = false
    }
    
    @IBAction func showRoute(_ sender: UIButton) {
        if locationManager.authorizationStatus != .authorizedWhenInUse {
            showMessage(type: .authorizationWarn)
            return
        }
        
        let request = MKDirections.Request()
        let placemarkSource = MKPlacemark(coordinate: locationManager.location!.coordinate)
        let placemarkTarget = MKPlacemark(coordinate: selectedAnnotation!.coordinate)
        
        request.source = MKMapItem(placemark: placemarkSource)
        request.destination = MKMapItem(placemark: placemarkTarget)
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if error == nil {
                if let response = response {
                    self.mapView.removeOverlays(self.mapView.overlays)
                    
                    let route = response.routes.first!
                    print("Nome: \(route.name)")
                    print("Distância: \(route.distance)")
                    print("Duração: \(route.expectedTravelTime)")
                    
                    for step in route.steps {
                        print("Em \(step.distance) metro(s), \(step.instructions)")
                    }
                    
                    self.mapView.addOverlay(route.polyline, level: .aboveRoads)
                    
                    var annotations = self.mapView.annotations.filter { annotation in
                        !(annotation is PlaceAnnotation)
                    }
                    annotations.append(self.selectedAnnotation!)
                    
                    self.mapView.showAnnotations(annotations, animated: true)
                }
            } else {
                self.showMessage(type: .routeError)
            }
        }
    }
    
    @IBAction func showSearchBar(_ sender: UIBarButtonItem) {
        searchBar.resignFirstResponder()
        searchBar.isHidden = !searchBar.isHidden
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is PlaceAnnotation) {
            return nil
        }
        
        let type = (annotation as! PlaceAnnotation).type
        let identifier = "\(type)"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        
        annotationView?.annotation = annotation
        annotationView?.canShowCallout = true
        annotationView?.markerTintColor = type == .place ? UIColor(named: "main") : UIColor(named: "pointOfInterest")
        annotationView?.glyphImage = type == .place ? UIImage(named: "placeGlyph") : UIImage(named: "poiGlyph")
        annotationView?.displayPriority = type == .place ? .required : .defaultHigh
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let camera = MKMapCamera()
        camera.centerCoordinate = view.annotation!.coordinate
        camera.pitch = 80
        camera.altitude = 100
        mapView.setCamera(camera, animated: true)
        
        selectedAnnotation = (view.annotation as! PlaceAnnotation)
        showInfo()
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor(named: "main")?.withAlphaComponent(0.8)
            renderer.lineWidth = 5
            
            return renderer
        }
        
        return MKOverlayRenderer(overlay: overlay)
    }
}

extension MapViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        loading.startAnimating()
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBar.text
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if error == nil {
                guard let response = response else {
                    self.loading.stopAnimating()
                    return
                }
                
                self.mapView.removeAnnotations(self.pointsOfInterest)
                self.pointsOfInterest.removeAll()
                
                for item in response.mapItems {
                    let annotation = PlaceAnnotation(coordinate: item.placemark.coordinate, type: .pointsOfInterest)
                    annotation.title = item.name
                    annotation.subtitle = item.phoneNumber
                    annotation.address = Place.getFormattedAddress(with: item.placemark)
                    self.pointsOfInterest.append(annotation)
                }
                
                self.mapView.addAnnotations(self.pointsOfInterest)
                self.mapView.showAnnotations(self.pointsOfInterest, animated: true)
            }
            self.loading.stopAnimating()
        }
        
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            mapView.showsUserLocation = true
            mapView.addSubview(btUserLocation)
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
}
