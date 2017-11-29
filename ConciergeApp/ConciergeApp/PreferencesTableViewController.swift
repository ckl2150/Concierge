//
//  PreferencesTableViewController.swift
//  ConciergeApp
//
//  Created by James Schulman on 11/28/17.
//  Copyright © 2017 James Schulman. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseAuth
import FirebaseDatabase
import UserNotifications

class PreferencesTableViewController: UITableViewController ,CLLocationManagerDelegate {
    
    //Categories for the table view
    let category = ["American", "Italian", "Chinese", "Mexican", "Japanese", "Sushi", "Seafood","Breakfast", "Lunch","Dinner"]
    var checkedCategories = [String]()
    public var correctCaller = false
    
    // Db reference
    var ref = Database.database().reference()
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
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
    
    // Function for identfying check marked items and adding them to an array for api calling
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = Auth.auth().currentUser
        let hashedData: NSData = Hash.sha256(data: user!.email!.data(using: String.Encoding.utf8)! as NSData)
        let hashedEmail: String = Hash.hexStringFromData(input: Hash.sha256(data: hashedData))
        self.correctCaller = false
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == UITableViewCellAccessoryType.checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.none
            var itemRemoved:String = checkedCategories[checkedCategories.index(of: (tableView.cellForRow(at: indexPath)!.textLabel?.text!)!)!]
            checkedCategories.remove(at: checkedCategories.index(of: (tableView.cellForRow(at: indexPath)!.textLabel?.text!)!)!)
            
            self.getSnapDidSelect(completion: { (snapshot) -> () in
                for s in snapshot {
                    if s.value as! String == itemRemoved {
                        self.ref.child("users").child(hashedEmail).child("foodPreferences").child(s.key).removeValue()
                    }
                }
                itemRemoved = ""
            })
        }
        else {
            tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
            checkedCategories.append((tableView.cellForRow(at: indexPath)!.textLabel?.text!)!)
            if Auth.auth().currentUser != nil {
                self.ref.child("users").child(hashedEmail).child("foodPreferences").childByAutoId().setValue((tableView.cellForRow(at: indexPath)!.textLabel?.text!)!)
            }
            else {
                print("no user is logged in")
            }
        }
    }
    
    func getSnapCellRowAt(completion: @escaping ([DataSnapshot]) -> ()) {
        if let user = Auth.auth().currentUser {
            let hashedData: NSData = Hash.sha256(data: user.email!.data(using: String.Encoding.utf8)! as NSData)
            let hashedEmail: String = Hash.hexStringFromData(input: Hash.sha256(data: hashedData))
            self.ref.child("users").child(hashedEmail).child("foodPreferences").ref.observe( .value, with: { (snapshot) -> Void in
                if snapshot.exists() {
                    completion(snapshot.children.allObjects as! [DataSnapshot])
                }
            })
        }
    }
    
    func getSnapDidSelect(completion: @escaping ([DataSnapshot]) -> ()) {
        if let user = Auth.auth().currentUser {
            let hashedData: NSData = Hash.sha256(data: user.email!.data(using: String.Encoding.utf8)! as NSData)
            let hashedEmail: String = Hash.hexStringFromData(input: Hash.sha256(data: hashedData))
            self.ref.child("users").child(hashedEmail).child("foodPreferences").ref.observe( .value, with: { (snapshot) -> Void in
                if snapshot.exists() {
                    completion(snapshot.children.allObjects as! [DataSnapshot])
                }
            })
        }
    }
    
    // Showing the strings inside of the Category array in the table view cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        self.getSnapCellRowAt { (snapshot) -> () in
            for s in snapshot {
                if !self.checkedCategories.contains((tableView.cellForRow(at: indexPath)!.textLabel?.text!)!) {
                    self.checkedCategories.append((tableView.cellForRow(at: indexPath)!.textLabel?.text!)!)
                }
                if cell.textLabel?.text == (s.value as! String) {
                    tableView.cellForRow(at: indexPath)?.accessoryType = UITableViewCellAccessoryType.checkmark
                }
            }
        }
        
        cell.textLabel?.text = category[indexPath.row]
        return cell
    }
    
//    // Hashing functions for database retrieval and storage
//    func sha256(data : NSData) -> NSData {
//        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
//        CC_SHA256(data.bytes, CC_LONG(data.length), &hash)
//        let res = NSData(bytes: hash, length: Int(CC_SHA256_DIGEST_LENGTH))
//        return res
//    }
//
//    private func hexStringFromData(input: NSData) -> String {
//        var bytes = [UInt8](repeating: 0, count: input.length)
//        input.getBytes(&bytes, length: input.length)
//        var hexString = ""
//
//        for byte in bytes {
//            hexString += String(format:"%02x", UInt8(byte))
//        }
//
//        return hexString
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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
