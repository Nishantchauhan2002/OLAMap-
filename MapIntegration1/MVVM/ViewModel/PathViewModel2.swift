//
//  PathViewModel2.swift
//  MapIntegration1
//
//  Created by Nishant Chauhan on 03/03/25.
//

import Foundation
import OlaMapCore
import CoreLocation
import UIKit


class PathViewModel2{
    
    var pathData:MapDataModel?
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
    var currentPolylineId: String?
    var polylineIdentifier: String = "polyline-id"
    var totalDistanceCovered:Int = 0;
    var distanceArray:[Int] = [];
    var onRouteUpdate: (([OlaCoordinate]) -> Void)?
    private let olaMap = OlaMapService(auth: .apiKey(key: Utility.getApiKey()), tileURL: Utility.getTileUrl(), projectId: Utility.getProjectId())

    
    func prepareMap(on view: UIView) {
        olaMap.loadMap(onView: view)
        olaMap.addCurrentLocationButton(view)
        olaMap.setCurrentLocationMarkerColor(UIColor.systemBlue)
        olaMap.setRotatingGesture(true)
        olaMap.setMinimumZoomLevel(12.0)
    }
    
    
    func makeApiCall(on viewController:UIViewController) {
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
        
        APIManager.postRequestCommon(url: apiUrl, header: nil, loaderShow: true, params: [:], loaderInView: viewController) { [weak self] response in
            guard let self = self else { return }
            
              if let jsonData = try? JSONSerialization.data(withJSONObject: response, options: []),
                 let decodedData = try? JSONDecoder().decode(MapDataModel.self, from: jsonData),
                 let firstRoute = decodedData.routes.first {
                  
                  let polylineCoordinates = self.decodePolyline(firstRoute.overviewPolyline)
                  
                  DispatchQueue.main.async {
                      self.plotPolyline(polylineSetOlaToKormangla: polylineCoordinates)
                  }
                  
                  calculateTheCoveredDistance(firstRoute)
              }
        }
    }
    
    func calculateTheCoveredDistance(_ routesArray:Route){
        let distance = routesArray.legs[0].distance
        print(distance)
        distanceArray.append(distance);
    }

    
    func plotPolyline(polylineSetOlaToKormangla: [OlaCoordinate]) {

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
    
    func totalDistanceTravelled(_ distanceArray:[Int]) -> Int{
        var totalDistance = 0;
        
        for i in 0..<distanceArray.count - 1 {
            totalDistance+=abs(distanceArray[i] - distanceArray[i + 1])
        }
        totalDistance = Int(Double(totalDistance)/1000);
        return totalDistance
    }
    
    func updateSourceCoordinate(with coordinate: String) {
        self.sourceCoordinates = coordinate
    }
}
