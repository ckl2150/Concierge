//
//  ViewController2.swift
//  
//
//  Created by Conrad Liu on 10/26/17.
//

import UIKit
import FirebaseAuth
import CoreLocation

class ViewController2: UIViewController, CLLocationManagerDelegate {
   
    //Vars for the picker and label on screen
  
    @IBAction func settingsButton(_ sender: Any) {
        self.performSegue(withIdentifier: "preferencesSegue", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Auth.auth().currentUser?.email as Any)
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
