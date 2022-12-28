//
//  ViewController.swift
//  MapKitTest
//
//  Created by Kiryl Rakk on 26/12/22.
//

import UIKit
import MapKit
import CoreLocation
import SnapKit

class ViewController: UIViewController {

    var moscowCoordinate  = CLLocationCoordinate2D(latitude:  55.741800 , longitude: 37.615800 )
    private lazy var mapView = MKMapView()
    private lazy var locationManager = CLLocationManager()
    
    
    private lazy var makeRouteButton : UIButton = {
        let button = UIButton()
        button.backgroundColor = .systemBlue
        button.setTitle("Mаршрут дo Москвы", for: .normal)
        button.addTarget(self, action: #selector(setRouteToMoscow), for: .touchUpInside)
        return button
    }()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        setLayers()
        addPin()
        configureMapView()
        print(locationManager.location)
    }
    
    func setLayers() {
        self.view.addSubview(mapView)
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.view.addSubview(makeRouteButton)
        makeRouteButton.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-75)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(32)
        }
    }

    @objc func setRouteToMoscow(){
        let request = MKDirections.Request()
        
        // добавляем начальную точку
        let sourceCoordinate = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude:  59.93617 , longitude: 30.31661 )
        let sourcePlace = MKPlacemark(coordinate: sourceCoordinate)
        request.source = MKMapItem(placemark: sourcePlace)
            

        // добавляем конечную точку
        let destinationCoodinate = moscowCoordinate
        let destinationPlace = MKPlacemark(coordinate: destinationCoodinate)
        request.destination = MKMapItem(placemark: destinationPlace)

        
        let direction = MKDirections(request: request)
        direction.calculate { [weak self] response, error in
            guard let response else { return }
            
            let route = response.routes[0]
            self?.mapView.delegate = self
            self?.mapView.addOverlay(route.polyline, level: .aboveRoads)
            
            let rect = route.polyline.boundingMapRect
           self?.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    func configureMapView() {
        mapView.mapType = .standard
        mapView.showsUserLocation = true
        let conf = MKHybridMapConfiguration()
        conf.showsTraffic = true
        mapView.preferredConfiguration = conf 
        let center = (locationManager.location?.coordinate) ?? CLLocationCoordinate2D(latitude:  59.93617 , longitude: 30.31661 )
        let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func addPin () {
        let annotation = MKPointAnnotation()
        annotation.coordinate = moscowCoordinate
        annotation.title = "Moscow"
        mapView.addAnnotation(annotation)

    }
    
    
   
  
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let render = MKPolylineRenderer(overlay: overlay)
        render.strokeColor = .blue
        render.lineWidth = 5
        return render
    }
}
