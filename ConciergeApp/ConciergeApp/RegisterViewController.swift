//
//  RegisterViewController.swift
//  ConciergeApp
//
//  Created by James Schulman on 11/26/17.
//  Copyright © 2017 James Schulman. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegisterViewController: UIViewController {

    @IBOutlet weak var fName: UITextField!
    @IBOutlet weak var lName: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    
    var ref:DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()

        // Do any additional setup after loading the view.
    }
    @IBAction func registerClick(_ sender: UIButton) {
        //SignUp
        Auth.auth().createUser(withEmail: emailText.text!, password: passwordText.text!, completion: { (user, error) in
            if user != nil {
                self.updateDB()
                self.performSegue(withIdentifier: "regToHomeSegue", sender: self)
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateDB() {
        print(emailText.text!)
        print(passwordText.text!)
        let hashedData: NSData = sha256(data: emailText.text!.data(using: String.Encoding.utf8)! as NSData)
        let hashedEmail: String = hexStringFromData(input: sha256(data: hashedData))
         ref.child("users").child(hashedEmail).setValue(["username": emailText.text!, "password": passwordText.text!])
        ref.child("users").child(hashedEmail).child("account").child("firstName").setValue(fName.text)
        ref.child("users").child(hashedEmail).child("account").child("lastName").setValue(lName.text)
        ref.child("users").child(hashedEmail).child("account").child("userName").setValue(userName.text)
        
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
