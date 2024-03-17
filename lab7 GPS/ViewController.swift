//
//  ViewController.swift
//  lab7 GPS
//
//  Created by Pavan savaliya on 2024-03-14.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    let manager = CLLocationManager()
    var startTime: Date?
    var totalDistance: CLLocationDistance = 0.0
    var totalTime: TimeInterval = 0.0
    var previousSpeed: CLLocationSpeed = 0.0
    var maxAcceleration: CLLocationSpeed = 0.0
    var maxSpeed: CLLocationSpeed = 0.0
    var isTripStarted: Bool = false
    var lastKnownLocation: CLLocation?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblMaxSpeed: UILabel!
    @IBOutlet weak var lblCurrentSpeed: UILabel!
    @IBOutlet weak var lblAverageSpeed: UILabel!
    @IBOutlet weak var lblDistance: UILabel!
    @IBOutlet weak var lblMaxAccelertion: UILabel!
    
    @IBOutlet weak var lblStartStop: UILabel!
    @IBOutlet weak var lblMaxWarning: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            render(location)
            
            let speed = location.speed // Speed in meters/second
            
            // Convert speed to km/h
            let speedKMH = speed * 3.6
            
            // Update current speed
            lblCurrentSpeed.text = String(format: "%.2f km/h", speedKMH)
            if(speedKMH > 115){
                lblMaxWarning.backgroundColor = UIColor.red
                print(String(format: "%.2f km", (totalDistance / 1000.0)))
            }else{
                lblMaxWarning.backgroundColor = UIColor.clear
            }
            
            // Update max speed
            if isTripStarted {
                maxSpeed = max(maxSpeed, speedKMH)
                lblMaxSpeed.text = String(format: "%.2f km/h", maxSpeed)
            }
            
            // Update distance
            if isTripStarted {
                if let lastLocation = lastKnownLocation{
                    let distance = location.distance(from: lastLocation)
                    totalDistance += distance
                    let distanceKM = totalDistance / 1000.0 // Convert meters to kilometers
                    lblDistance.text = String(format: "%.2f km", distanceKM)
                }
            }
            
            // Update average speed
            if isTripStarted {
                let currentTime = Date()
                totalTime = currentTime.timeIntervalSince(startTime!)
                let averageSpeed = (totalDistance / 1000.0) / (totalTime / 3600.0)
                lblAverageSpeed.text = String(format: "%.2f km/h", averageSpeed)
            }
            
            // Update max acceleration 
            if isTripStarted {
               let acceleration = abs(speed - previousSpeed)
               maxAcceleration = max(maxAcceleration, acceleration)
               lblMaxAccelertion.text = String(format: "%.2f m/s^2", maxAcceleration)
               
               previousSpeed = speed
           }
            lastKnownLocation = location //Update the last known location
        }
        
    }

    func render(_ location: CLLocation) {
        let coordinate = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.7, longitudeDelta: 0.7)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        mapView.addAnnotation(pin)
        mapView.setRegion(region, animated: true)
    }

    @IBAction func btnStartTrip(_ sender: Any) {
        if !isTripStarted {
            startTime = Date()
            totalDistance = 0.0
            totalTime = 0.0
            previousSpeed = 0.0
            maxAcceleration = 0.0
            maxSpeed = 0.0
            
            // Reset labels
            lblMaxSpeed.text = "0.00 km/h"
            lblAverageSpeed.text = "0.00 km/h"
            lblDistance.text = "0.00 km"
            lblMaxAccelertion.text = "0.00 m/s^2"
            lblStartStop.backgroundColor = UIColor.green
            isTripStarted = true
        }
    }
    
    @IBAction func btnStopTrip(_ sender: Any) {
        isTripStarted = false
        lblMaxSpeed.text = ""
        lblAverageSpeed.text = ""
        lblDistance.text = ""
        lblMaxAccelertion.text = ""
        lblStartStop.backgroundColor = UIColor.gray
    }
}
