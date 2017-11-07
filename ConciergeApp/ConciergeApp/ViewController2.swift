//
//  ViewController2.swift
//  
//
//  Created by Conrad Liu on 10/26/17.
//

import UIKit
import FirebaseAuth
import CoreLocation

class ViewController2: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate {
   
    //Vars for the picker and label on screen
    @IBOutlet weak var poiDropdown: UIPickerView!
    @IBOutlet weak var poiLabel: UILabel!
    
    //Parameters of the Yelp! Fusion API
    var domain = "https://api.yelp.com/v3/businesses/search?term="
    var categoryParam = ""
    var locationParam = ""
    let locationManager = CLLocationManager()
    
    //categories for the pickerview
    let category = ["Food", "Hotels", "Museums"]
    
    //Structure to hold all businesses returned from the API
    struct POI: Decodable {
        let businesses: [Business]
    }
    
    //Struct for individual businesses
    struct Business: Decodable {
        let name: String?
//        let location: String?
//        let phone : String?
        
        init(json: [String: Any]) {
            name = json["name"] as? String ?? ""
//            location = json["location"] as? String ?? ""
//            phone = json["phone"] as? String ?? ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Initializing location services
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        print(Auth.auth().currentUser?.email as Any)
    }
    
    //setting location parameter for api with users current location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print(location.coordinate)
            let lat:String = String(location.coordinate.latitude)
            let long:String = String(location.coordinate.longitude)
            locationParam = "&latitude="+lat+"&longitude="+long
        }
    }
    
    //checking the status of users location services
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.denied) {
            showLocationDisabledPopUp()
        }
    }
    
    //popup that redirects user to settings if location servises disabled
    func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "Background Location Accesses Disabled" ,
                                                message: "In order for us to supply awesome stuff to do, we need your location",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) {(action) in
            if let Url = URL(string: UIApplicationOpenSettingsURLString ) {
                UIApplication.shared.open(Url, options: [:], completionHandler: nil)
            }
        }
        
        alertController.addAction(openAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //http GET request
    @IBAction func onGoGet(_ sender: Any) {
        guard let url = URL(string:domain+categoryParam+locationParam) else { return }
        var request = URLRequest(url:url)
        request.httpMethod = "GET"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer -Cfy-cCnWTY1HVJAb6ISQcj5bS3Q4R8tNZn7nM0u98lemdk5jos9H8Wvce5ZdQbAG7fCVwZ_aOXtvf7ynjcMwH41TKIbghjFb5_E9DHevRGpX8TZOoA-WobdOVb3WXYx", forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, err) in
            if let response = response {
                print(response)
            }
            
            guard let data = data else { return }
            do {
                let poi = try JSONDecoder().decode(POI.self, from:data)
                print(poi.businesses[0].name as Any)
            } catch let jsonErr {
                print("Error serializing json:", jsonErr)
            }
        }.resume()
    }
    
    //functions for selecting items from the pickerview list
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return category[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return category.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        poiLabel.text = category[row]
        categoryParam = poiLabel.text!
    }
    
    //log the user out
    @IBAction func logoutAction(_ sender: UIButton) {
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "segue2", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
