//
//  ViewController.swift
//  emv2
//
//  Created by Roen Wainscoat on 10/19/17.
//  Copyright © 2017 Roen Wainscoat. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    var latitude: Double?
    var longitude: Double?
    var altitude: Double?
    let locationManager = CLLocationManager()
    @IBOutlet weak var myLatitude: UITextField!
    @IBOutlet weak var myLongitude: UITextField!
    @IBOutlet weak var evLatitude: UITextField!
    @IBOutlet weak var evLongitude: UITextField!
    @IBOutlet weak var evDistance: UITextField!
    @IBOutlet weak var TARView: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        TARView.text = String("disabled")
        locationManager.delegate  = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        evLoad()
        // Do any additional setup after loading the view, typically from a nib.
}
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            print("GPS allowed.")
        }
        else {
            print("GPS not allowed.")
            return
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let myCoordinate = locationManager.location?.coordinate
        altitude = locationManager.location?.altitude
        latitude = myCoordinate?.latitude
        longitude = myCoordinate?.longitude
        
        myLatitude.text = String(latitude!)
        myLongitude.text = String(longitude!)
    }
    
    func evLoad() {
        super.viewDidLoad()
        fetchURL()
       // performSelector(inBackground: #selector(fetchURL), with: nil)
    }
    
    var evLocDidRefresh = false
    
    func fetchURL() {
        var data = "00 A 0.0 0.0"
        if let url = URL(string: "https://roen.us/wapps/dev/evn/evn.txt") {
            do {
                data = "7 A 7.0 7.0"
                let data = try String(contentsOf: url)
                let allEvData = data.components(separatedBy: " ")
                evLatitude.text = allEvData[2]
                evLongitude.text = allEvData[3]
                let evlatNum = Double(evLatitude.text ?? "") ?? 0.0
                let evlonNum = Double(evLongitude.text ?? "") ?? 0.0
                let mylatNum = Double(myLatitude.text ?? "") ?? 0.0
                let mylonNum = Double(myLongitude.text ?? "") ?? 0.0
                let dlat: Double = mylatNum - evlatNum
                let dlon: Double = (mylonNum - evlonNum) * 0.931
                let distance: Double = sqrt(dlat * dlat + dlon * dlon) * 111325.0
                let idistance = Int32(distance)
                evDistance.text = String(idistance)
                //evDistance.text = "33"
                evLocDidRefresh = true
            } catch {
                // error loading
                data = "9 A 9.0 9.0"
                let data = data.components(separatedBy: " ")
                evLatitude.text = data[1]
                evLongitude.text = data[2]
            }
        } else {
            // url bad
            data = "4 A 4.0 4.0"
        }
//        data = "2 A 2.0 2.0"
    }
    
    @IBAction func evRefresh(_ sender: UIButton) {
        evLoad()
        print("Refresh queued")
        sleep(1)
        if evLocDidRefresh == true {
            print("Refreshed from source")
            evLocDidRefresh = false
        } else {
            print("There was an error refreshing EVInfo from source. Please try again!")
        }
    }
    
    @IBAction func autoEVR(_ sender: UIButton) {
        var index = 10
        while index >= 0 {
            index -= 1
            print("Here is the index ", index)
            evLoad()
            print("Refresh queued")
            sleep(1)
            if evLocDidRefresh == true {
                print("Refreshed from source")
                evLocDidRefresh = false
            } else {
                print("There was an error refreshing EVInfo from source. Please try again!")
            }
            sleep(3)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

