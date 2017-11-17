//
//  TableViewController.swift
//  ConciergeApp
//
//  Created by James Schulman on 11/11/17.
//  Copyright © 2017 James Schulman. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseAuth
import FirebaseDatabase
import UserNotifications

class TableViewController: UITableViewController,CLLocationManagerDelegate {
    
    //Categories for the table view
    let category = ["American", "Italian", "Chinese", "Mexican", "Japanese", "Sushi", "Seafood","Breakfast", "Lunch","Dinner"]
    var checkedCategories = [String]()
    

    // Db reference
    var ref = Database.database().reference()
    
    //Parameters of the Yelp! Fusion API
//    var domain = "https://api.yelp.com/v3/businesses/search?term="
//    var locationParam = ""
//    var catParam = ""
    let locationManager = CLLocationManager()
    
    //Structure to hold all businesses returned from the API
//    struct POI: Decodable {
//        let businesses: [Business]
//    }
//
//    //Struct for individual businesses
//    struct Business: Decodable {
//        let name: String?
//        let distance: Float?
//
//        init(json: [String: Any]) {
//            name = json["name"] as? String ?? ""
//            distance = json["distance"] as? Float
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Establishing location settings
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
//        var timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.fusionCall), userInfo: nil, repeats: true)
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in})

        // Following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // Setting location parameter for api with users current location
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.first {
//            let lat:String = String(location.coordinate.latitude)
//            let long:String = String(location.coordinate.longitude)
//            locationParam = "&latitude="+lat+"&longitude="+long
//        }
//    }
    
    // Checking the status of the users location
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        if (status == CLAuthorizationStatus.denied) {
//            showLocationDisabledPopUp()
//        }
//    }
//
//    // Popup that redirects user to settings if location servises disabled
//    func showLocationDisabledPopUp() {
//        let alertController = UIAlertController(title: "Background Location Accesses Disabled" ,
//                                                message: "In order for us to supply awesome stuff to do, we need your location",
//                                                preferredStyle: .alert)
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        alertController.addAction(cancelAction)
//
//        let openAction = UIAlertAction(title: "Open Settings", style: .default) {(action) in
//            if let Url = URL(string: UIApplicationOpenSettingsURLString ) {
//                UIApplication.shared.open(Url, options: [:], completionHandler: nil)
//            }
//        }
//
//        alertController.addAction(openAction)
//        self.present(alertController, animated: true, completion: nil)
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Initializing how many sections are in the table view
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return category.count
    }
    
//    func getSnapCellRowAt(completion: @escaping ([DataSnapshot]) -> ()) {
//        if let user = Auth.auth().currentUser {
//                let hashedData: NSData = sha256(data: user.email!.data(using: String.Encoding.utf8)! as NSData)
//                let hashedEmail: String = hexStringFromData(input: sha256(data: hashedData))
//                self.ref.child("users").child(hashedEmail).child("foodPreferences").ref.observe( .value, with: { (snapshot) -> Void in
//                if snapshot.exists() {
//                   completion(snapshot.children.allObjects as! [DataSnapshot])
//                }
//            })
//        }
//    }
    
//    func getSnapDidSelect(completion: @escaping ([DataSnapshot]) -> ()) {
//        if let user = Auth.auth().currentUser {
//            let hashedData: NSData = sha256(data: user.email!.data(using: String.Encoding.utf8)! as NSData)
//            let hashedEmail: String = hexStringFromData(input: sha256(data: hashedData))
//            self.ref.child("users").child(hashedEmail).child("foodPreferences").ref.observe( .value, with: { (snapshot) -> Void in
//                if snapshot.exists() {
//                    completion(snapshot.children.allObjects as! [DataSnapshot])
//                }
//            })
//        }
//    }
    
    // Showing the strings inside of the Category array in the table view cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let user = Auth.auth().currentUser {
            let hashedData: NSData = sha256(data: user.email!.data(using: String.Encoding.utf8)! as NSData)
            let hashedEmail: String = hexStringFromData(input: sha256(data: hashedData))
            self.ref.child("users").child(hashedEmail).child("foodPreferences").ref.observe( .value, with: { (snapshot) -> Void in
                if snapshot.exists() {
                    for s in snapshot.children.allObjects as! [DataSnapshot] {
                        if !self.checkedCategories.contains((tableView.cellForRow(at: indexPath)!.textLabel?.text!)!) {
                            self.checkedCategories.append((tableView.cellForRow(at: indexPath)!.textLabel?.text!)!)
                        }
                        if cell.textLabel?.text == (s.value as! String) {
                            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
                        }
                    }
                }
            })
        }
        cell.textLabel?.text = category[indexPath.row]
        return cell
    }
    
    
    // Function for identfying check marked items and adding them to an array for api calling
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = Auth.auth().currentUser
        let hashedData: NSData = sha256(data: user!.email!.data(using: String.Encoding.utf8)! as NSData)
        let hashedEmail: String = hexStringFromData(input: sha256(data: hashedData))
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
            
            // Getting item that needs to be removed from the database
            var itemRemoved:String = checkedCategories[checkedCategories.index(of: (tableView.cellForRow(at: indexPath)!.textLabel?.text!)!)!]
            
            // Removing items from the checkedCategories array
            checkedCategories.remove(at: checkedCategories.index(of: (tableView.cellForRow(at: indexPath)!.textLabel?.text!)!)!)
            
            if let user = Auth.auth().currentUser {
                let hashedData: NSData = sha256(data: user.email!.data(using: String.Encoding.utf8)! as NSData)
                let hashedEmail: String = hexStringFromData(input: sha256(data: hashedData))
                self.ref.child("users").child(hashedEmail).child("foodPreferences").ref.observe( .value, with: { (snapshot) -> Void in
                    if snapshot.exists() {
                        for s in snapshot.children.allObjects as! [DataSnapshot] {
                            if s.value as! String == itemRemoved {
                                self.ref.child("users").child(hashedEmail).child("foodPreferences").child(s.key).removeValue()
                            }
                        }
                        itemRemoved = ""
                    }
                })
            }
        }
        else {
            
            // Putting a checkmark next to an item that has been selected
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            checkedCategories.append((tableView.cellForRow(at: indexPath)!.textLabel?.text!)!)
            
            // Storing the check marked item into the database
            if let user = Auth.auth().currentUser {
                let hashedData: NSData = sha256(data: user.email!.data(using: String.Encoding.utf8)! as NSData)
                let hashedEmail: String = hexStringFromData(input: sha256(data: hashedData))
                self.ref.child("users").child(hashedEmail).child("foodPreferences").childByAutoId().setValue((tableView.cellForRow(at: indexPath)!.textLabel?.text!)!)
            }
            else {
                print("no user is logged in")
            }
        }
    }
    
    // Hashing functions for database retrieval and storage
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
    
    
    
    // **NOTE**  these functions need to be moved to another viewcontroller --> need to separate from retrival and storage of datbase items
//    @objc func fusionCall() {
//        self.paramSnap { (catParam) -> () in
//            // Generating te url for the http get request to the yelp api
//            guard let url = URL(string:self.domain+"Food&categories="+catParam+self.locationParam) else { return }
//            var request = URLRequest(url:url)
//            request.httpMethod = "GET"
//            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//
//            request.addValue("Bearer -Cfy-cCnWTY1HVJAb6ISQcj5bS3Q4R8tNZn7nM0u98lemdk5jos9H8Wvce5ZdQbAG7fCVwZ_aOXtvf7ynjcMwH41TKIbghjFb5_E9DHevRGpX8TZOoA-WobdOVb3WXYx", forHTTPHeaderField: "Authorization")
//            let session = URLSession.shared
//            session.dataTask(with: request) { (data, response, err) in
//                if let response = response {
//                    print(response)
//                }
//
//                guard let data = data else { return }
//                do {
//                    let poi = try JSONDecoder().decode(POI.self, from:data)
//
//                    // Printing the first item return from the api call --  will be used to generate a push notification for the user
//                    //                print(poi.businesses[0].name as Any)
//                    let Content = UNMutableNotificationContent()
//                    let dist: String = String(format: "%.1f", poi.businesses[0].distance!/1609.344)
//                    Content.title = "Feeling hungry?"
//                    Content.body = poi.businesses[0].name! + " is "+dist+" miles away, want to check it out?"
//                    Content.badge = 1
//
//                    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//                    let request = UNNotificationRequest.init(identifier: "poiFound", content: Content, trigger: trigger)
//
//                    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
//
//                } catch let jsonErr {
//                    print("Error serializing json:", jsonErr)
//                }
//            }.resume()
//        }
//    }
//
//
//    func paramSnap(completion: @escaping (String) -> ()) {
//        var categoryParam = [String]()
//        var catParam: String = ""
//        if let user = Auth.auth().currentUser {
//            let hashedData: NSData = sha256(data: user.email!.data(using: String.Encoding.utf8)! as NSData)
//            let hashedEmail: String = hexStringFromData(input: sha256(data: hashedData))
//            _ = self.ref.child("users").child(hashedEmail).child("foodPreferences").ref.observe( .value, with: { (snapshot) -> Void in
//                if snapshot.exists() {
//                    for snap in snapshot.children.allObjects as! [DataSnapshot] {
//                        let cat = snap.value
//                        categoryParam.append(cat as! String)
////                        print(cat as! String)
//                        // async download so need to reload the table that this data feeds into.
//                        self.tableView.reloadData()
//                    }
//                    let joiner = ","
//                    catParam = categoryParam.joined(separator: joiner).lowercased()
//                }
//                completion(catParam)
//            })
//        }
//    }

    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}
