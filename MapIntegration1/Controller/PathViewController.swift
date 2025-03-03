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
    var timer: Timer?
    var index = 0
    var currentPolylineId: String?
    private var polylineIdentifier: String = "polyline-id"
    private var totalDistanceCovered:Int = 0;
    
    var distanceArray:[Int] = [];
    var sourcePointArr = [
        "28.482599215119546, 77.06567223366044",
        "28.489100455513586, 77.05597840170037",
        "28.484022684944243, 77.05156130762863",
        "28.47837360526484, 77.04678543208081",
        "28.47706415390132, 77.04536190502084",
        "28.47371724099788, 77.04776402065656",
        "28.476448337672405, 77.04726005252166"
    ]
    
    var sourceCoordinates = "28.485008935832635, 77.06311584232837"
    var destinationCoordinates = "28.476448337672405, 77.04726005252166"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareMap() // Load the map only once
        scheduleATimeIntervalWithTimer()
        makeApiCall()
    }
    
    func makeApiCall() {
        var apiUrl = Constant.API.productURL
        apiUrl.append(String(format: "origin=%@", sourceCoordinates))
        apiUrl.append(String(format: "&destination=%@", destinationCoordinates))
        apiUrl.append(String(format: "&mode=%@", "driving"))
        apiUrl.append(String(format: "&alternatives=%@", "false"))
        apiUrl.append(String(format: "&steps=%@", "false"))
        apiUrl.append(String(format: "&overview=%@", "full"))
        apiUrl.append(String(format: "&language=%@", "en"))
        apiUrl.append(String(format: "&traffic_metadata=%@", "false"))
        apiUrl.append(String(format: "&api_key=%@", Utility.getApiKey()))
        
        APIManager.postRequestCommon(url: apiUrl, header: nil, loaderShow: true, params: [:], loaderInView: self) { [weak self] response in
            guard let self = self else { return }
            if let routesArr = response["routes"] as? [[String: Any]],
               let dict = routesArr.first,
               let overviewPolylineStr = dict["overview_polyline"] as? String {
                
                self.overviewPolyline = overviewPolylineStr
                let polylineCoordinates = self.decodePolyline(overviewPolyline)
                
                DispatchQueue.main.async {
                    self.plotPolyline(polylineSetOlaToKormangla: polylineCoordinates)
                }
                
                //function to calculate the total Distance
                calculateTheCoveredDistance(dict);
            }
        }
    }
    
    func calculateTheCoveredDistance(_ dict:Dictionary<String,Any>){
        if let legArray = dict["legs"] as? [[String:Any]],let distanceDict = legArray.first{
            
            if let distance = distanceDict["distance"] as? Int{
                distanceArray.append(distance);
            }
        }
    }
    
    func totalDistanceTravelled(_ distanceArray:[Int]) -> Int{
        var totalDistance = 0;
        
        for i in 0..<distanceArray.count - 1 {
            totalDistance+=abs(distanceArray[i] - distanceArray[i + 1])
        }
        
        return totalDistance
    }
    func prepareMap() {
        olaMap.loadMap(onView: self.polylineView)
        olaMap.addCurrentLocationButton(self.polylineView)
        olaMap.setCurrentLocationMarkerColor(UIColor.systemBlue)
        olaMap.setRotatingGesture(true)
        olaMap.delegate = self
        olaMap.setMinimumZoomLevel(12.0)
    }

    private func plotPolyline(polylineSetOlaToKormangla: [OlaCoordinate]) {

        if let oldId = currentPolylineId {
            self.olaMap.deletePolyline(oldId);
            self.olaMap.removeAnnotation(by:"dropAnnotation")
            self.olaMap.removeAnnotation(by:"pickupAnnotation")
        }

        let newPolylineId = UUID().uuidString
        currentPolylineId = newPolylineId

        self.olaMap.showPolyline(identifier: newPolylineId, .solid, polylineSetOlaToKormangla, .blue)
        self.olaMap.setMapCamera(polylineSetOlaToKormangla)

        let dropAnnotation = CustomAnnotationView(identifier: "drop", image: UIImage(named: "img_drop"))
        dropAnnotation.bounds = CGRect(x: 0, y: 0, width: 40, height: 40)
        self.olaMap.setAnnotationMarker(at: polylineSetOlaToKormangla.last!, annotationView: dropAnnotation, identifier: "dropAnnotation")

        let pickupAnnotation = CustomAnnotationView(identifier: "pickup", image: UIImage(named: "img_cab"))
        pickupAnnotation.bounds = CGRect(x: 0, y: 0, width: 30, height: 30)
        self.olaMap.setAnnotationMarker(at: polylineSetOlaToKormangla.first!, annotationView: pickupAnnotation, identifier: "pickupAnnotation")
        
        olaMap.setZoomLevel(1.0)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.olaMap.setMapCamera(polylineSetOlaToKormangla)
        })
    }

    func decodePolyline(_ encodedPolyline: String) -> [OlaCoordinate] {
        var coordinates: [OlaCoordinate] = []
        var index = encodedPolyline.startIndex
        var latitude = 0
        var longitude = 0
        
        while index < encodedPolyline.endIndex {
            var result = 0
            var shift = 0
            var byte: UInt8
            
            repeat {
                byte = UInt8(encodedPolyline[index].asciiValue!) - 63
                index = encodedPolyline.index(after: index)
                result |= Int(byte & 0x1F) << shift
                shift += 5
            } while byte >= 0x20
            
            latitude += (result & 1) == 1 ? ~(result >> 1) : (result >> 1)
            
            result = 0
            shift = 0
            
            repeat {
                byte = UInt8(encodedPolyline[index].asciiValue!) - 63
                index = encodedPolyline.index(after: index)
                result |= Int(byte & 0x1F) << shift
                shift += 5
            } while byte >= 0x20
            
            longitude += (result & 1) == 1 ? ~(result >> 1) : (result >> 1)
            
            coordinates.append(OlaCoordinate(latitude: Double(latitude) * 1e-5, longitude: Double(longitude) * 1e-5))
        }
        
        return coordinates
    }
    
    func scheduleATimeIntervalWithTimer() {
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
    }
    
    @objc func timerFired() {
        if index < sourcePointArr.count {
            sourceCoordinates = sourcePointArr[index]
            index += 1
            makeApiCall()
        } else {
            print(distanceArray);
            totalDistanceCovered =  totalDistanceTravelled(distanceArray)
            let totalDistanceInKms = Double(totalDistanceCovered) / 1000

            let alert = UIAlertController(title: "End Ride",
                                              message: "You have travelled a total distance of \(totalDistanceInKms)KMs .",
                                              preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)
                
            self.present(alert, animated: true, completion: nil)
            stopTimer()
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - OlaMapServiceDelegate Methods
    
    func mapSuccessfullyLoaded() {
        print("Map successfully loaded")
    }
    
    func mapFailedToLoad(_ error: any Error) {
        print("Map failed to load: \(error.localizedDescription)")
    }
    
    func didSelectAnnotationView(_ annotationId: String) {
        print("Selected annotation: \(annotationId)")
    }
    
    func didChangeCamera() {
        print("Selected didChangeCamera")
    }
    
    func regionIsChanging(_ gesture: OlaMapCore.OlaMapGesture) {
        print("Selected didChangeCamera")

    }
    
}
