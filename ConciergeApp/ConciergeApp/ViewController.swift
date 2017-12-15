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
    @IBOutlet weak var loginBut: UIButton!
    @IBOutlet weak var loginBox: UIImageView!
    
    
    var ref:DatabaseReference!
    
    // Button which takes you to RegisterViewController
    @IBAction func registerClick(_ sender: Any) {
        self.performSegue(withIdentifier: "regSegue", sender: self)
    }
    
    // If login is correct, takes you to dashboard (ViewController2)
    @IBAction func loginAction(_ sender: UIButton) {
        if emailText.text != "" && passwordText.text != "" {
            //Login
            Auth.auth().signIn(withEmail: emailText.text!, password: passwordText.text!, completion: { (user, error) in
                if user != nil {
                    //success
                    self.performSegue(withIdentifier: "loginSegue", sender: self)
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
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        loginBox.layer.cornerRadius = 10
        loginBox.clipsToBounds = true
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Registration calls this function to update DB
    func updateDB() {
        let hashedData: NSData = Hash.sha256(data: emailText.text!.data(using: String.Encoding.utf8)! as NSData)
        let hashedEmail: String = Hash.hexStringFromData(input: Hash.sha256(data: hashedData))
        ref.child("users").child(hashedEmail).setValue(["username": emailText.text!, "password": passwordText.text!])
    }
        
}
