//
//  ViewController2.swift
//  
//
//  Created by Conrad Liu on 10/26/17.
//

import UIKit
import FirebaseAuth
import CoreLocation
import UserNotifications
import FirebaseDatabase
import UserNotifications
import MapKit

class ViewController2: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate,MKMapViewDelegate {
   
    let locationManager = CLLocationManager()
    var locationParam: String = ""
    var ref = Database.database().reference()
    var bgTask = UIBackgroundTaskInvalid
    var lastFiredNotification:NSDate = NSDate()
    var notificationPreference: Double = -1
    var domain = "https://api.yelp.com/v3/businesses/search?term=" // URL to build upon
    var flag: Bool = false
    var myUrl: String = ""
    
    @IBOutlet weak var learnMoreBut: UIButton!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var profPic: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileNameBlur: UIVisualEffectView!
    @IBOutlet weak var localSpotView: UIImageView!
    @IBOutlet weak var localSpotDistLabel: UILabel!
    @IBOutlet weak var localSpotLabel: UILabel!
    @IBOutlet weak var localSpotPriceLabel: UILabel!
    
    @IBAction func settingsButton(_ sender: Any) {
        self.performSegue(withIdentifier: "preferencesSegue", sender: nil)
    }

    
    //Structure to hold all businesses returned from the API
    struct POI: Decodable {
        let businesses: [Business]
    }
    
    //Struct for individual businesses
    struct Business: Decodable {
        let name: String?
        let distance: Float?
        let image_url: String?
        let price: String?
        let url: String?
        
        init(json: [String: Any]) {
            name = json["name"] as? String ?? ""
            distance = json["distance"] as? Float
            image_url = json["image_url"] as? String ?? ""
            price = json["price"] as? String ?? ""
            url = json["url"] as? String ?? ""
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        flag = false
        
        map.delegate = self
        map.showsScale = true
        
        profPic.layer.cornerRadius = profPic.frame.size.width/2
        profPic.clipsToBounds = true
        
        profileNameBlur.layer.cornerRadius = 5
        profileNameBlur.clipsToBounds = true
        
        locationManager.requestAlwaysAuthorization()
        localSpotView.clipsToBounds = true
        
        learnMoreBut.addTarget(self, action: #selector(self.learnMoreAction(_:)), for: .touchUpInside)
        
        // Turn on location services. Critical for the app to know when to send notifications
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startMonitoringSignificantLocationChanges()
        }
    }
    
    @IBAction func learnMoreAction(_ sender: Any) {
        UIApplication.shared.open(URL(string: myUrl )!, options: [:], completionHandler: nil)
    }
    
    // Pulls the representative photo from a nearby point of interest as returned by the yelp API
    @IBAction func addPic(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }
            else {
                print("Camera not available")
            }
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action: UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
            
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action: UIAlertAction) in
            self.present(imagePickerController, animated: true, completion: nil)
            
        }))
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        profPic.image = image
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    // Database call to retrieve frequency for notification generation
    func getNotificationFrequency(completion: @escaping ([DataSnapshot]) -> ()) {
        if let user = Auth.auth().currentUser {
            let hashedData: NSData = Hash.sha256(data: user.email!.data(using: String.Encoding.utf8)! as NSData)
            let hashedEmail: String = Hash.hexStringFromData(input: Hash.sha256(data: hashedData))
            self.ref.child("users").child(hashedEmail).child("profile").ref.observe( .value, with: { (snapshot) -> Void in
                if snapshot.exists() {
                    completion(snapshot.children.allObjects as! [DataSnapshot])
                }
            })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            print(location.coordinate)
            let lat:String = String(location.coordinate.latitude)
            let long:String = String(location.coordinate.longitude)
            locationParam = "&latitude="+lat+"&longitude="+long
            
        }
        
        if flag == false {
            flag = true
            guard let url = URL(string:self.domain+"Food"+self.locationParam) else { return }
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
                    let name = poi.businesses[0].name
                    self.localSpotLabel.text = name
                    let dist: String = String(format: "%.1f", poi.businesses[0].distance!/1609.344)
                    self.localSpotDistLabel.text = dist+" mi"
                    self.localSpotPriceLabel.text = poi.businesses[0].price
                    let picUrl = URL(string: poi.businesses[0].image_url!)
                    self.myUrl = poi.businesses[0].url!
                    let task = URLSession.shared.dataTask(with: picUrl!, completionHandler: { (data, response, error) in
                        if error != nil {
                            print("Error")
                        }
                        else {
                            var documentsDirectory:String?
                            var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                            if paths.count > 0 {
                                documentsDirectory = paths[0]
                                let savePath = documentsDirectory! + "/picLocalSpot"
                                FileManager.default.createFile(atPath: savePath, contents: data, attributes: nil)
                                DispatchQueue.main.async {
                                    self.localSpotView.image = UIImage(named: savePath)
                                }
                            }
                        }
                    })
                    task.resume()
                } catch let jsonErr {
                    print("Error serializing json:", jsonErr)
                }
                }.resume()
            
        }
        self.getNotificationFrequency { (snapshot) -> () in
            for s in snapshot {
                if s.key == "notificationFreq" {
                    self.notificationPreference = 60 * (s.value as! Double)
                }
            }
      
            let currDate:NSDate = NSDate()
                if self.notificationPreference > 0 && currDate.timeIntervalSince(self.lastFiredNotification as Date) < 30 {
                print("Notification not requested yet")
            }
            else {
                print("Preparing fusion call")
                self.lastFiredNotification = NSDate()
                let fusion = Fusion()
                fusion.goFusion(locationParam: self.locationParam)
            }
        }
        
        if let location = locations.first {
            let lat:String = String(location.coordinate.latitude)
            let long:String = String(location.coordinate.longitude)
            locationParam = "&latitude="+lat+"&longitude="+long
        }
        
        let userLocation = locations.first
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01,0.01)
        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(userLocation!.coordinate.latitude, userLocation!.coordinate.longitude)
        let region: MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        map.setRegion(region, animated: true)
        self.map.showsUserLocation = true
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.denied) {
            showLocationDisabledPopUp()
        }
    }

    // Popup that redirects user to settings if location servises disabled
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

    //log the user out
    @IBAction func logoutAction(_ sender: UIButton) {
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "segue2", sender: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
