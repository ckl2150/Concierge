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
                    if user != nil {
                        self.updateDB()
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

    func updateDB() {
        let hashedData: NSData = sha256(data: emailText.text!.data(using: String.Encoding.utf8)! as NSData)
        let hashedEmail: String = hexStringFromData(input: sha256(data: hashedData))
        ref.child("users").child(hashedEmail).setValue(["username": emailText.text!, "password": passwordText.text!])
    }
    
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

}

