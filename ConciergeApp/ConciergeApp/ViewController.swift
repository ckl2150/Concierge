//
//  ViewController.swift
//  ConciergeApp
//
//  Created by James Schulman on 10/26/17.
//  Copyright © 2017 James Schulman. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var loginButton: UIButton!
    
    @IBAction func loginClick(_ sender: UIButton) {
        if emailText.text != "" && passwordText.text != "" {
            
            if segmentControl.selectedSegmentIndex == 0 {
                //Login
                Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!, completion: { (user, error) in
                    if user != nil {
                        //success
                        print("wooooo")
                    }
                    else {
                        if let myError = error?.localizedDescription {
                            print(myError)
                        }
                        else {
                            print("ERROR")
                        }
                    }
                })
            }
            else {
                //SignUp
                Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!, completion: { (user, error) in
                    if user != nil {
                        
                    }
                    else {
                        if let myError = error?.localizedDescription {
                            print(myError)
                        }
                        else {
                            print("ERROR")
                        }
                    }
                })
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

