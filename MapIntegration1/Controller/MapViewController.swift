//
//  MapViewController.swift
//  MapIntegration1
//
//  Created by Nishant Chauhan on 28/02/25.
//

import UIKit

class MapViewController: UIViewController {
  
    
    
    @IBOutlet weak var polylineMapButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
          
    }
    
    @IBAction func polylineMapButtonAction(_ sender: UIButton) {
        let navigationVc = PathViewController();
        self.navigationController?.pushViewController(navigationVc, animated: true);
    }
    
    
}
