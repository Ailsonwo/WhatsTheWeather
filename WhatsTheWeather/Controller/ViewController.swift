//
//  ViewController.swift
//  WhatsTheWeather
//
//  Created by Ailson Pereira on 15/06/22.
//  Copyright © 2022 Ailson Pereira. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    
    @IBOutlet weak var locationLable: UILabel!
    
    @IBOutlet weak var dayLabel: UILabel!
    
    @IBOutlet weak var weatherImage: UIImageView!
    
    @IBOutlet weak var weatherLabel: UILabel!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var celcius: UILabel!
    
    let gradientLayer = CAGradientLayer()
    
    let apiKey = "4c5329ad3935f6dcb3883ade51a03489"
    var lat = 37.773972
    var lon = -122.431297
    var activityIndicator: NVActivityIndicatorView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundView.layer.addSublayer(gradientLayer)
        
        let indicatorSize:CGFloat = 70
        let indicatorFrame = CGRect(x: (view.frame.width-indicatorSize)/2, y: (view.frame.height-indicatorSize)/2, width: indicatorSize, height: indicatorSize)
        activityIndicator = NVActivityIndicatorView(frame: indicatorFrame, type: .lineScale, color: UIColor.white, padding: 20.0)
        activityIndicator.backgroundColor = UIColor.darkGray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() &&
            CLLocationManager.authorizationStatus() != CLAuthorizationStatus.denied{
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[0]
        lat = location.coordinate.latitude
        lon = location.coordinate.longitude
        
        setWeather(latitude: -23.4784963, longitude: -46.1350955)

        self.locationManager.stopUpdatingLocation()
        print("Chega aqui")
    }
    
    func setWeather(latitude: Double, longitude: Double){
        Alamofire.request("http://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(self.apiKey)&units=metric").responseJSON{
            response in
            if let responseStr = response.result.value{
                let jsonResponse = JSON(responseStr)
                let jsonWeather = jsonResponse["weather"].array![0]
                let jsonTemp = jsonResponse["main"]
                let iconName = jsonWeather["icon"].stringValue
                
                self.celcius.text = "℃"
                self.weatherImage.image = UIImage(named: iconName)
                self.locationLable.text = jsonResponse["name"].stringValue
                self.temperatureLabel.text = String(Int(round(jsonTemp["temp"].doubleValue)))
                self.weatherLabel.text = jsonWeather["main"].stringValue
                
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE"
                self.dayLabel.text = dateFormatter.string(from: date)
                
                if iconName.suffix(1) == "n" {
                    self.setNightGradientBackground()
                } else if jsonWeather["main"].stringValue != "Sunny" {
                    self.setCloudyGradientBackground()
                } else {
                    self.setSunnyGradientBackground()
                }
            }
            
        }
        self.activityIndicator.stopAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.denied{
            setWeather(latitude: lat, longitude: lon)
            let alertNoLocation = UIAlertController(title: "Location Error", message: "We can't find your location, please go to settings and change the location sharing authorization.", preferredStyle: .alert)
            alertNoLocation.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            alertNoLocation.addAction(UIAlertAction(title: "Settings", style: .default){ (_) -> Void in
                
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }

                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: nil)
                }
                
            })
            
            present(alertNoLocation, animated: true, completion: nil)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        setSunnyGradientBackground()
    }

    func setSunnyGradientBackground() {
        
        let topColor = UIColor(red: 0.0, green: 180.0/255.0, blue: 1.0, alpha: 1.0).cgColor
        
        let bottonColor = UIColor(red: 0.0, green: 160.0/255.0, blue: 1.0, alpha: 1.0).cgColor
        
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [topColor, bottonColor]
    }
    
    func setCloudyGradientBackground() {
        
        let topColor = UIColor(red: 0.0, green: 90.0/255.0, blue: 130.0/255.0, alpha: 1.0).cgColor
        
        let bottonColor = UIColor(red: 0.0, green: 75.0/255.0, blue: 130.0/255.0, alpha: 1.0).cgColor
        
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [topColor, bottonColor]
    }
    
    func setNightGradientBackground() {
        
        let topColor = UIColor(red: 130.0/255.0, green: 130.0/255.0, blue: 130.0/255.0, alpha: 1.0).cgColor
        
        let bottonColor = UIColor(red: 110.0/255.0, green: 110.0/255.0, blue: 110.0/255.0, alpha: 1.0).cgColor
        
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [topColor, bottonColor]
    }
}


