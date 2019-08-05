//
//  ViewController.swift
//  weather
//
//  Created by Apple on 15/05/2019.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var conditionLAbel: UILabel!
    
    @IBOutlet weak var temperatureLavel: UILabel!
    
    @IBOutlet weak var backgroundView: UIView!
    
    var gradientLayer = CAGradientLayer()
    
    //https://openweathermap.org
    let apiKey = "8c1e240150949fb7bfe0bf0503c8a20e"
    //координаты СПб
    var lat = 59.57 //широта
    var long = 30.19  //долгота
    
    var activityIndicator: NVActivityIndicatorView!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.layer.addSublayer(gradientLayer)
        
        let inicatorSize: CGFloat = 70
        let indicatorFrame = CGRect(x: (view.frame.width-inicatorSize)/2, y: (view.frame.height-inicatorSize)/2, width: inicatorSize, height: inicatorSize)
        activityIndicator = NVActivityIndicatorView(frame: indicatorFrame, type: .lineScale, color: UIColor.white, padding: 20.0)
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        locationManager.requestWhenInUseAuthorization()  //запрос на использование геопоиции
        //определение местоположения включены на устройстве (Именно на устройстве, а не в приложении)
        if(CLLocationManager.locationServicesEnabled()){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        setBlueGradientBackground()
    }
    
    //MARK: CLLocationManagerDelegate
    
    //Сообщает делегату, что доступны новые данные о местоположении
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        //если приложение иммет права на использовании местоположения
        //https://developer.apple.com/documentation/corelocation/clauthorizationstatus
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse {
            let location = locations[0]
            lat = location.coordinate.latitude
            long = location.coordinate.longitude
            print(lat)
            print(long)
            jsonmanager()
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    //Сообщает делегату, что диспетчеру местоположений не удалось получить значение местоположения.
    //использование координат по умолчанию
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        jsonmanager()
        self.locationManager.stopUpdatingLocation()
    }
    
    
    func jsonmanager() {
       Alamofire.request("http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(long)&appid=\(apiKey)&units=metric").responseJSON { (response) in
            
            if let responseStr = response.result.value{
                let jsonResponce = JSON(responseStr)
                let jsonWeather = jsonResponce["weather"].array![0]
                let jsonTemp = jsonResponce["main"]
                let iconName = jsonWeather["icon"].stringValue
                
                self.locationLabel.text = jsonResponce["name"].stringValue
                self.conditionImageView.image = UIImage(named: iconName)
                self.conditionLAbel.text = jsonWeather["main"].stringValue
                self.temperatureLavel.text = "\(Int(round(jsonTemp["temp"].doubleValue)))"
                
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE"
                self.dayLabel.text = dateFormatter.string(from: date)
                
                let suffic = iconName.suffix(1)
                //n-ночь d-день
                if (suffic == "n") {
                    self.setGrayGradientBackground()
                }else {
                    self.setBlueGradientBackground()
                }
            }
            self.activityIndicator.stopAnimating()
        }
    }
    
    
    func setBlueGradientBackground(){
        let topColor = UIColor(red: 95.0/255.0, green: 165.0/255.0, blue: 1.0, alpha: 1.0).cgColor
        //let topColor = UIColor.blue
        let buttonColor = UIColor(red: 72.0/255.0, green: 144.0/255.0, blue: 184.0/255.0, alpha: 1.0).cgColor
        //let buttonColor = UIColor.yellow
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [topColor, buttonColor]
        
    }
    
    func setGrayGradientBackground(){
        //let topColor = UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0).cgColor
        let topColor = UIColor.darkGray
       // let buttonColor = UIColor(red: 72.0/255.0, green: 72.0/255.0, blue: 72.0/255.0, alpha: 1.0).cgColor
        let buttonColor = UIColor.lightGray
        
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [topColor, buttonColor]
    }

}

