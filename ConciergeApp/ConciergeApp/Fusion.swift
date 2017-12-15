//
//  Fusion.swift
//  ConciergeApp
//
//  Created by James Schulman on 11/28/17.
//  Copyright © 2017 James Schulman. All rights reserved.
//

import Foundation
import FirebaseAuth
import CoreLocation
import UserNotifications
import FirebaseDatabase

public class Fusion {
    
    var domain = "https://api.yelp.com/v3/businesses/search?term="
    var catParam = ""
    
    // Db reference
    var ref = Database.database().reference()
    
    //Structure to hold all businesses returned from the API
    struct POI: Decodable {
        let businesses: [Business]
    }
    
    //Struct for individual businesses
    struct Business: Decodable {
        let name: String?
        let distance: Float?
        
        init(json: [String: Any]) {
            name = json["name"] as? String ?? ""
            distance = json["distance"] as? Float
        }
    }
    
    // Collects arguments to pass along to the URL, and makes HTTP request to yelp API
    // Finally, triggers a notification with contents of first item in API response
    func goFusion(locationParam: String) {
        let ptvc = PreferencesTableViewController()
        ptvc.correctCaller = true
        var correct: Bool = true
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {didAllow, error in})
        self.getRadius{(radiusParam) -> () in
            
        
        self.getParam { (catParam) -> () in
           
            let ptvc = PreferencesTableViewController()
            if ptvc.correctCaller || correct {
                correct = false
                guard let url = URL(string:self.domain+"Food&radius="+radiusParam+"&categories="+catParam+locationParam) else { return }
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
                        
                        let Content = UNMutableNotificationContent()
                        if poi.businesses.isEmpty == false {
                            let dist: String = String(format: "%.1f", poi.businesses[0].distance!/1609.344)
                            Content.title = "Feeling hungry?"
                            Content.body = poi.businesses[0].name! + " is "+dist+" miles away, want to check it out?"
                            Content.badge = 1

                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                            let request = UNNotificationRequest.init(identifier: "poiFound", content: Content, trigger: trigger)
                            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                        }

                    } catch let jsonErr {
                        print("Error serializing json:", jsonErr)
                    }
                }.resume()
            }
        }
            
        }
    }
    
    func getParam(completion: @escaping (String) -> ()) {
        var categoryParam = [String]()
        var catParam: String = ""
        if let user = Auth.auth().currentUser {
            let hashedData: NSData = Hash.sha256(data: user.email!.data(using: String.Encoding.utf8)! as NSData)
            let hashedEmail: String = Hash.hexStringFromData(input: Hash.sha256(data: hashedData))
            _ = self.ref.child("users").child(hashedEmail).child("foodPreferences").ref.observe( .value, with: { (snapshot) -> Void in
                if snapshot.exists() {
                    for snap in snapshot.children.allObjects as! [DataSnapshot] {
                        let cat = snap.value
                        categoryParam.append(cat as! String)
                    }
                    let joiner = ","
                    catParam = categoryParam.joined(separator: joiner).lowercased()
                    categoryParam.removeAll()
                }
                completion(catParam)
            })
        }
    }
    
    // Database call to retrieve radius parameter
    func getRadius(completion: @escaping (String) -> ()) {
        var radiusParam: String = ""
        if let user = Auth.auth().currentUser {
            let hashedData: NSData = Hash.sha256(data: user.email!.data(using: String.Encoding.utf8)! as NSData)
            let hashedEmail: String = Hash.hexStringFromData(input: Hash.sha256(data: hashedData))
            _ = self.ref.child("users").child(hashedEmail).child("profile").ref.observe( .value, with: { (snapshot) -> Void in
                if snapshot.exists() {
                    for snap in snapshot.children.allObjects as! [DataSnapshot] {
                        if snap.key == "radius" {
                            let radius: Int = Int((snap.value as! Double) * 1609.344)
                            radiusParam = String(radius)
                        }
                    }                }
                completion(radiusParam)
            })
        }
    }
}

