//
//  NavHomeController.swift
//  ConciergeApp
//
//  Created by James Schulman on 11/15/17.
//  Copyright © 2017 James Schulman. All rights reserved.
//

import UIKit
import FirebaseAuth
import CoreLocation
import UserNotifications
import FirebaseDatabase

class NavHomeController: UINavigationController,CLLocationManagerDelegate {
    
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
