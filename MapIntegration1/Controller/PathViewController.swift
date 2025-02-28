//
//  PathViewController.swift
//  MapIntegration1
//
//  Created by Nishant Chauhan on 28/02/25.
//

import UIKit
import OlaMapCore
import CoreLocation



class PathViewController: UIViewController, OlaMapServiceDelegate {
   
    
    
    @IBOutlet weak var polylineView: UIView!
    private let olaMap = OlaMapService(auth: .apiKey(key: Utility.getApiKey()), tileURL: Utility.getTileUrl(), projectId: Utility.getProjectId())
    var overviewPolyline = ""
    var timer:Timer?
    var index = 0;
    
    var sourcePointArr = [
        "28.485008935832635, 77.06311584232837",
        "28.489100455513586, 77.05597840170037",
        "28.484022684944243, 77.05156130762863",
        "28.47837360526484, 77.04678543208081",
        "28.47706415390132, 77.04536190502084",
        "28.47371724099788, 77.04776402065656",
        "28.476448337672405, 77.04726005252166"
    ]
    
    
    var sourceCoordinates:String = "28.485008935832635, 77.06311584232837"
    var destinationCoordinates:String = "28.476448337672405, 77.04726005252166"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scheduleATimeIntervalWithTimer()
        makeApiCall();
    }
    
    
    func makeApiCall(){
        var apiUrl = Constant.API.productURL;

        apiUrl.append(String(format: "origin=%@", sourceCoordinates))
        apiUrl.append(String(format: "&destination=%@", destinationCoordinates))
        apiUrl.append(String(format: "&mode=%@", "driving"))
        apiUrl.append(String(format: "&alternatives=%@", "false"))
        apiUrl.append(String(format: "&steps=%@", "false"))
        apiUrl.append(String(format: "&overview=%@", "full"))
        apiUrl.append(String(format: "&language=%@", "en"))
        apiUrl.append(String(format: "&traffic_metadata=%@", "false"))
        apiUrl.append(String(format: "&api_key=%@", Utility.getApiKey()))
        
        APIManager.postRequestCommon(url: apiUrl, header: nil, loaderShow: true, params: [:], loaderInView: self) { [self] response in
            if let routesArr  = response["routes"] as? [Any]{
                if routesArr.count > 0, let dict = routesArr.first as? [String:Any],let overviewPolylineStr = dict["overview_polyline"] as? String {
                     overviewPolyline = overviewPolylineStr
                    self.prepareMap()
                    let polylineSetOlaToKormangla = self.decodePolyline(overviewPolyline);
                    DispatchQueue.main.async { [self] in
                        plotPolyline(polylineSetOlaToKormangla: polylineSetOlaToKormangla);

                    }
                }
            }
        }
    }
    
     func prepareMap() {
        olaMap.loadMap(onView: self.polylineView)
        olaMap.addCurrentLocationButton(self.polylineView)
        olaMap.setCurrentLocationMarkerColor(UIColor.systemBlue)
        olaMap.setRotatingGesture(true)
        olaMap.delegate = self
        olaMap.setMinimumZoomLevel(12.0)
    }
    
    
    func mapSuccessfullyLoaded() {
        print("mapSuccessfullyLoaded");
        fetchCurrentLocation()
    }
    
    private func plotPolyline(polylineSetOlaToKormangla:[OlaCoordinate]) {
        self.olaMap.showPolyline(identifier: "polyline-id", .solid, polylineSetOlaToKormangla, .black)
        self.olaMap.setMapCamera(polylineSetOlaToKormangla)
        let dropAnnotation = CustomAnnotationView(identifier: "drop", image: UIImage(named: "img_drop"))
        dropAnnotation.bounds = CGRect(x: 0, y: 0, width: 40, height: 40)
        self.olaMap.setAnnotationMarker(at: polylineSetOlaToKormangla.last!, annotationView: dropAnnotation, identifier: "dropAnnotation.identifier")
        
        let pickupAnnotation = CustomAnnotationView(identifier: "pickup", image: UIImage(named: "img_pickup"))
        pickupAnnotation.bounds = CGRect(x: 0, y: 0, width: 30, height: 30)
        self.olaMap.setAnnotationMarker(at: polylineSetOlaToKormangla.first!, annotationView: pickupAnnotation, identifier: "pickupAnnotation.identifier")
        
        olaMap.setZoomLevel(1.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.olaMap.setMapCamera(polylineSetOlaToKormangla)
        })
    }

  
    func decodePolyline(_ encodedPolyline: String) -> [OlaCoordinate] {
        var coordinates: [OlaCoordinate] = []
        var index = encodedPolyline.startIndex
        _ = encodedPolyline.count
        var latitude = 0
        var longitude = 0

        while index < encodedPolyline.endIndex {
            var result = 0
            var shift = 0
            var byte: UInt8 = 0

            repeat {
                guard index < encodedPolyline.endIndex else { break }
                byte = UInt8(encodedPolyline[index].asciiValue!) - 63
                index = encodedPolyline.index(after: index)
                result |= Int(byte & 0x1F) << shift
                shift += 5
            } while byte >= 0x20

            let deltaLatitude = ((result & 1) == 1 ? ~(result >> 1) : (result >> 1))
            latitude += deltaLatitude

            result = 0
            shift = 0

            repeat {
                guard index < encodedPolyline.endIndex else { break }
                byte = UInt8(encodedPolyline[index].asciiValue!) - 63
                index = encodedPolyline.index(after: index)
                result |= Int(byte & 0x1F) << shift
                shift += 5
            } while byte >= 0x20

            let deltaLongitude = ((result & 1) == 1 ? ~(result >> 1) : (result >> 1))
            longitude += deltaLongitude

            let coordinate = OlaCoordinate(
                latitude: Double(latitude) * 1e-5,
                longitude: Double(longitude) * 1e-5
            )
            coordinates.append(coordinate)
        }
        
        return coordinates
    }

    
    func scheduleATimeIntervalWithTimer(){
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
    }
    

    @objc func timerFired() {
        
//        if (index < sourcePointArr.count){
//            sourceCoordinates = sourcePointArr[index];
//            index+=1;
//            self.makeApiCall()
//        }
//        else{
//            self.stopTimer()
//        }
    
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }


    func fetchCurrentLocation(){
        LocationManager.shared.requestCurrentLocation { coordinate, error in
            if let coordinate = coordinate {
                print("Latitude: \(coordinate.latitude), Longitude: \(coordinate.longitude)")
            } else if let error = error {
                print("Error getting location: \(error.localizedDescription)")
            }
        }

    }
    
    
    
    
    
    
    
    
    
    
    
    func mapViewDidChange(gesture: OlaMapCore.OlaMapGesture) {
        print("mapViewDidChange");
    }
    
    
    func mapViewDidBecomeIdle() {
        print("mapViewDidBecomeIdle");

    }
    
    func regionDidChangeAnimated() {
        print("regionDidChangeAnimated");

    }
    
    func didChangeCamera() {
        print("didChangeCamera");

    }
    
    func regionIsChanging(_ gesture: OlaMapCore.OlaMapGesture) {
        print("regionIsChanging");

    }
    
    func didAddAnnotationViewsOnMap() {
        print("didAddAnnotationViewsOnMap");

    }
    
    func regionDidChangeAnimated(_ mode: OlaMapCore.NavigationTrackingMode) {
        print("regionDidChangeAnimated");

    }
    
    func didTapOnMap(_ coordinate: OlaMapCore.OlaCoordinate) {
        print("didTapOnMap");

    }
    
    func didTapOnMap(feature: OlaMapCore.POIModel) {
        print("didTapOnMap");

    }
    
    func didLongTapOnMap(_ coordinate: OlaMapCore.OlaCoordinate) {
        print("didLongTapOnMap");

    }
    
    func didRouteSelected(_ overviewPolyline: String) {
        print("didRouteSelected");

    }
    
    func mapFailedToLoad(_ error: any Error) {
        print("mapFailedToLoad");

    }
    
  
    
    func mapSuccessfullyLoadedStyle() {
        print("mapSuccessfullyLoadedStyle");

    }
    
    func didSelectAnnotationView(_ annotationId: String) {
        print("didSelectAnnotationView");

    }

}
