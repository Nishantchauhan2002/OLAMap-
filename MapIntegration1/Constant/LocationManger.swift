//
//  LocationManger.swift
//  MapIntegration1
//
//  Created by Nishant Chauhan on 28/02/25.
//

import Foundation
import UIKit
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    private var locationManager = CLLocationManager()
    private var completionHandler: ((CLLocationCoordinate2D?, Error?) -> Void)?
    
    private override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestCurrentLocation(completion: @escaping (CLLocationCoordinate2D?, Error?) -> Void) {
        self.completionHandler = completion
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        completionHandler?(location.coordinate, nil)
        locationManager.stopUpdatingLocation() // Stop to save battery
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        completionHandler?(nil, error)
    }
}
