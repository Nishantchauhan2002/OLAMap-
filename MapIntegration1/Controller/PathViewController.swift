//
//  PathViewController.swift
//  MapIntegration1
//
//  Created by Nishant Chauhan on 28/02/25.
//

import UIKit
import OlaMapCore


class PathViewController: UIViewController, OlaMapServiceDelegate {
   
    
    
    @IBOutlet weak var polylineView: UIView!
    private let olaMap = OlaMapService(auth: .apiKey(key: Utility.getApiKey()), tileURL: Utility.getTileUrl(), projectId: Utility.getProjectId())
    
    var sourceCoordinates:String = "28.485008935832635, 77.06311584232837"
    var destinationCoordinates:String = "28.476448337672405, 77.04726005252166"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        olaMap.loadMap(onView: self.polylineView)
        olaMap.addCurrentLocationButton(self.view)
        olaMap.setCurrentLocationMarkerColor(UIColor.systemBlue)
        olaMap.setDebugLogs(true)
        olaMap.delegate = self
        olaMap.setMaxZoomLevel(16.0)
        // Do any additional setup after loading the view.
        makeApiCall();
    }
    
    
    func makeApiCall(){
        var apiUrl = Constant.API.productURL;
//        https://api.olamaps.io/routing/v1/directions?origin=28.476448337672405%2C%2077.04726005252166&destination=28.485008935832635%2C%2077.06311584232837&mode=driving&alternatives=false&steps=false&overview=full&language=en&traffic_metadata=false&api_key=axLfy5EnHjCgtT6mayvqNUJsPemSbNdSr6LvMaGK
        
        var postDict = Dictionary<String,Any>();
//        postDict["origin"] = "28.485008935832635, 77.06311584232837";
//        postDict["destination"] = "28.476448337672405, 77.04726005252166";
//        postDict["mode"] = "driving";
//        postDict["alternatives"] = false
//        postDict["steps"] = false
//        postDict["overview"] = "full"
//        postDict["language"] = "en"
//        postDict["traffic_metadata"] = false
//        postDict["api_key"] = Utility.getApiKey()

        apiUrl.append(String(format: "origin=%@", sourceCoordinates))
        apiUrl.append(String(format: "&destination=%@", destinationCoordinates))
        apiUrl.append(String(format: "&mode=%@", "driving"))
        apiUrl.append(String(format: "&alternatives=", false))
        apiUrl.append(String(format: "&steps=", false))
        apiUrl.append(String(format: "&overview=%@", "full"))
        apiUrl.append(String(format: "&language=%@", "en"))
        apiUrl.append(String(format: "&traffic_metadata=%@", false))
        apiUrl.append(String(format: "&api_key=%@", Utility.getApiKey()))
        
        apiUrl = apiUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed)!
        APIManager.postRequestCommon(url: apiUrl, header: nil, loaderShow: true, params: postDict, loaderInView: self) { response in
            print(response)
            
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
    
    func mapSuccessfullyLoaded() {
        print("mapSuccessfullyLoaded");

    }
    
    func mapSuccessfullyLoadedStyle() {
        print("mapSuccessfullyLoadedStyle");

    }
    
    func didSelectAnnotationView(_ annotationId: String) {
        print("didSelectAnnotationView");

    }

}
