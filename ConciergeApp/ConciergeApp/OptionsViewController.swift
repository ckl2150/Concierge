//
//  OptionsViewController.swift
//  ConciergeApp
//
//  Created by James Schulman on 11/26/17.
//  Copyright © 2017 James Schulman. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class OptionsViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var notificationTimeSelection: UIPickerView!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    let timeOptions = ["5 min", "10 min","30 min","60 min"]
    var ref:DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        let user = Auth.auth().currentUser
        emailLabel.text = user!.email!
        self.getFullName { (snapshot) -> () in
            var firstName: String = ""
            var lastName: String = ""
            for s in snapshot {
                if s.key == "firstName" {
                    firstName = s.value as! String
                }
                if s.key == "lastName" {
                    lastName = s.value as! String
                }
            }
            self.name.text = firstName + " " + lastName
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func getFullName(completion: @escaping ([DataSnapshot]) -> ()) {
        if let user = Auth.auth().currentUser {
            let hashedData: NSData = Hash.sha256(data: user.email!.data(using: String.Encoding.utf8)! as NSData)
            let hashedEmail: String = Hash.hexStringFromData(input: Hash.sha256(data: hashedData))
            self.ref.child("users").child(hashedEmail).child("account").ref.observe( .value, with: { (snapshot) -> Void in
                if snapshot.exists() {
                    completion(snapshot.children.allObjects as! [DataSnapshot])
                }
            })
        }
    }
    
    @IBAction func radiusChanged(_ sender: UISlider) {
        let val:Float = round(sender.value * 4) / 4
        radiusLabel.text = String(val)
        let user = Auth.auth().currentUser
        let hashedData: NSData = Hash.sha256(data: user!.email!.data(using: String.Encoding.utf8)! as NSData)
        let hashedEmail: String = Hash.hexStringFromData(input: Hash.sha256(data: hashedData))
        
        if Auth.auth().currentUser != nil {
            self.ref.child("users").child(hashedEmail).child("profile").child("radius").setValue(val)
        }
        else {
            print("no user is logged in")
        }
    }
    @IBAction func done(_ sender: UIButton) {
        
        name.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
       
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Helvetica Neue",size: 14)
            pickerLabel?.textAlignment = .center
        }
        
        pickerLabel?.text = timeOptions[row]
        
        return pickerLabel!
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return timeOptions[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return timeOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let user = Auth.auth().currentUser
        let hashedData: NSData = Hash.sha256(data: user!.email!.data(using: String.Encoding.utf8)! as NSData)
        let hashedEmail: String = Hash.hexStringFromData(input: Hash.sha256(data: hashedData))
        
        if Auth.auth().currentUser != nil {
            self.ref.child("users").child(hashedEmail).child("profile").child("notificationFreq").setValue(Double(timeOptions[row].components(separatedBy: " ")[0]))
        }
        else {
            print("no user is logged in")
        }
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }
}
