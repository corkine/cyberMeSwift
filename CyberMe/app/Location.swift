//
//  Location.swift
//  helloSwift
//
//  Created by Corkine on 2023/2/6.
//

import Foundation
import CoreLocation

class WidgetLocationManager: NSObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager?
    private var handler: ((CLLocation?,Error?) -> Void)?

    override init() {
        super.init()
        DispatchQueue.main.async {
            self.locationManager = CLLocationManager()
            self.locationManager!.delegate = self
            if self.locationManager!.authorizationStatus == .notDetermined {
                self.locationManager!.requestWhenInUseAuthorization()
            }
        }
    }
    
    func fetchLocation(handler: @escaping (CLLocation?,Error?) -> Void) {
        self.handler = handler
        self.locationManager?.requestLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.handler!(locations.last!, nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        self.handler!(nil, error)
    }
}
