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

class TableViewController: UITableViewController,CLLocationManagerDelegate {
    
    let category = ["American", "Italian", "Chinese", "Mexican", "Japanese", "Sushi", "Seafood","Breakfast", "Lunch","Dinner"]
    var checkedCategories = [String]()
    
    //Parameters of the Yelp! Fusion API
    var domain = "https://api.yelp.com/v3/businesses/search?term="
    var locationParam = ""
    let locationManager = CLLocationManager()
    
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
        
        locationManager.requestAlwaysAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return category.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = category[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
            if let index = checkedCategories.index(of: (tableView.cellForRow(at: indexPath)!.textLabel?.text!)!) {
                checkedCategories.remove(at: index)
            }
        }
        else {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            print(tableView.cellForRow(at: indexPath)!.textLabel?.text)
            checkedCategories.append((tableView.cellForRow(at: indexPath)!.textLabel?.text!)!)
        }
    }
    
    
    @IBAction func onClickGet(_ sender: Any) {
        let joiner = ","
        let categoryParam = checkedCategories.joined(separator: joiner).lowercased()
        print(categoryParam.lowercased())
        guard let url = URL(string:domain+"Food&categories="+categoryParam+locationParam) else { return }
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

