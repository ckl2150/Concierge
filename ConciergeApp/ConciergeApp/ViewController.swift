//
//  ViewController.swift
//  ConciergeApp
//
//  Created by James Schulman on 10/26/17.
//  Copyright © 2017 James Schulman. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class ViewController: UIViewController {

    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var loginButton: UIButton!
    
    var ref:DatabaseReference!
    
    @IBAction func loginClick(_ sender: UIButton) {
        if emailText.text != "" && passwordText.text != "" {
            
            if segmentControl.selectedSegmentIndex == 0 {
                //Login
                Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!, completion: { (user, error) in
                    if user != nil {
                        //success
                        self.performSegue(withIdentifier: "segue", sender: self)
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
                    let email: String = self.emailText.text!
                    if user != nil {
                        self.ref.child("user").setValue(email)
                        self.ref.child(email).setValue("hello?")
//                        ref!.child("user/\(self.emailText.text)/email").setValue([self.emailText.text])
//                        ref.child("user\(email)").setValue(self.passwordText.text)
                        // success
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
        ref = Database.database().reference()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

