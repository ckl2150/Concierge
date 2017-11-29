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

class ViewController2: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   
    let locationManager = CLLocationManager()
    var locationParam: String = ""
    var ref = Database.database().reference()
    var bgTask = UIBackgroundTaskInvalid
    var lastFiredNotification:NSDate = NSDate()
    var notificationPreference: Double = -1
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var profPic: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBAction func settingsButton(_ sender: Any) {
        self.performSegue(withIdentifier: "preferencesSegue", sender: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        profPic.layer.cornerRadius = profPic.frame.size.width/2
        profPic.clipsToBounds = true
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startMonitoringSignificantLocationChanges()
        }
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            let hashedData: NSData = self.sha256(data: user!.email!.data(using: String.Encoding.utf8)! as NSData)
            let hashedEmail: String = self.hexStringFromData(input: self.sha256(data: hashedData))
            self.ref.child("users").child(hashedEmail).child("account").ref.observe( .value, with: { (snapshot) -> Void in
                if snapshot.exists() {
                    for s in snapshot.children.allObjects as! [DataSnapshot] {
                        print(s.key)
                        if s.key == "userName" {
                            print(s.value as! String)
                            self.usernameLabel.text = (s.value as! String)
                        }
                    }
                }
            })
        }
    }
    
    func sha256(data : NSData) -> NSData {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256(data.bytes, CC_LONG(data.length), &hash)
        let res = NSData(bytes: hash, length: Int(CC_SHA256_DIGEST_LENGTH))
        return res
    }
    
    private func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        var hexString = ""
        
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        
        return hexString
    }
    
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
    
    func getNotificationFrequency(completion: @escaping ([DataSnapshot]) -> ()) {
        if let user = Auth.auth().currentUser {
            let hashedData: NSData = sha256(data: user.email!.data(using: String.Encoding.utf8)! as NSData)
            let hashedEmail: String = hexStringFromData(input: sha256(data: hashedData))
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
