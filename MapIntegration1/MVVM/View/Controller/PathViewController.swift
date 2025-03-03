//
//  PathViewController.swift
//  MapIntegration1
//
//  Created by Nishant Chauhan on 28/02/25.
//

import UIKit
import OlaMapCore
import CoreLocation

class PathViewController: UIViewController {

    
    @IBOutlet weak var polylineView: UIView!
    
    var timer: Timer?
    var index = 0
    private let viewModel = PathViewModel2()
    var distanceArray:[Int] = [];
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        viewModel.prepareMap(on: polylineView)
        scheduleATimeIntervalWithTimer()
        viewModel.makeApiCall(on: self)
    }

    private func setupBindings() {
           viewModel.onRouteUpdate = { [weak self] polylineCoordinates in
               DispatchQueue.main.async {
                   self?.viewModel.plotPolyline(polylineSetOlaToKormangla: polylineCoordinates)
               }
           }
       }
    func scheduleATimeIntervalWithTimer() {
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
    }
    
    @objc func timerFired() {
           if index < viewModel.sourcePointArr.count {
               viewModel.updateSourceCoordinate(with: viewModel.sourcePointArr[index])
               viewModel.makeApiCall(on: self)
               index += 1
           } else {
               let totalDistance = viewModel.totalDistanceTravelled(viewModel.distanceArray)
               let alert = UIAlertController(title: "End Ride", message: "You have travelled a total distance of \(totalDistance) KM.", preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "OK", style: .default))
               present(alert, animated: true)
               stopTimer()
           }
       }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
