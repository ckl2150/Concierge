//
//  ConciergeAppTests.swift
//  ConciergeAppTests
//
//  Created by James Schulman on 10/26/17.
//  Copyright © 2017 James Schulman. All rights reserved.
//

import XCTest
@testable import ConciergeApp
import FirebaseAuth
import FirebaseDatabase

class ConciergeAppTests: XCTestCase {
    
    var sessionUnderTest: URLSession!
    var ref:DatabaseReference!
    
    override func setUp() {
        super.setUp()
        sessionUnderTest = URLSession.shared
        ref = Database.database().reference()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sessionUnderTest = nil
        super.tearDown()
    }
    
    func testFusionAPI() {
        let url = URL(string: "https://api.yelp.com/v3/businesses/search?term=Food&categories=italian%2Cmexican%2Cjapanese&radius=20000&latitude=37.33067157&longitude=-122.0302499")

        var request = URLRequest(url:url!)
        request.httpMethod = "GET"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer -Cfy-cCnWTY1HVJAb6ISQcj5bS3Q4R8tNZn7nM0u98lemdk5jos9H8Wvce5ZdQbAG7fCVwZ_aOXtvf7ynjcMwH41TKIbghjFb5_E9DHevRGpX8TZOoA-WobdOVb3WXYx", forHTTPHeaderField: "Authorization")

        let promise = expectation(description: "Status code: 200")

        sessionUnderTest.dataTask(with: request) { data, response, error in
            if let error = error {
                XCTFail("Error: \(error.localizedDescription)")
                return
            }
            else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if statusCode == 200 {
                    promise.fulfill()
                } else {
                    XCTFail("Status code: \(statusCode)")
                }
            }
        }.resume()
        
        waitForExpectations(timeout: 5, handler: nil)
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testFireAuthDelete() {
        let emailText:String = "test@unittest.com"
        let passwordText:String = "123456"
        Auth.auth().createUser(withEmail: emailText, password: "123456", completion: { (user, error) in
            if user != nil {
                let hashedData: NSData = Hash.sha256(data: emailText.data(using: String.Encoding.utf8)! as NSData)
                let hashedEmail: String = Hash.hexStringFromData(input: Hash.sha256(data: hashedData))
                self.ref.child("users").child(hashedEmail).setValue(["username": emailText, "password": passwordText])
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
        let user = Auth.auth().currentUser
        user?.delete { error in
            if error != nil {
                // An error happened.
            } else {
                XCTAssert(error == nil)
            }
        }
    }
    
    func testDatabase() {
        let emailText:String = "test@unittest.com"
        let passwordText:String = "123456"
        Auth.auth().createUser(withEmail: emailText, password: "123456", completion: { (user, error) in
            if user != nil {
                let hashedData: NSData = Hash.sha256(data: emailText.data(using: String.Encoding.utf8)! as NSData)
                let hashedEmail: String = Hash.hexStringFromData(input: Hash.sha256(data: hashedData))
                self.ref.child("users").child(hashedEmail).setValue(["username": emailText, "password": passwordText])
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
        
        let hashedData: NSData = Hash.sha256(data: emailText.data(using: String.Encoding.utf8)! as NSData)
        let hashedEmail: String = Hash.hexStringFromData(input: Hash.sha256(data: hashedData))
        ref.child("users").child(hashedEmail).child("unittest").setValue(["username": emailText, "password": passwordText])
        
        
        
        let user = Auth.auth().currentUser
        user?.delete { error in
            if error != nil {
                // An error happened.
            } else {
                XCTAssert(error == nil)
            }
        }
    }
    
    
    func getSnapCellRowAt(completion: @escaping ([DataSnapshot]) -> ()) {
        if let user = Auth.auth().currentUser {
            let hashedData: NSData = Hash.sha256(data: user.email!.data(using: String.Encoding.utf8)! as NSData)
            let hashedEmail: String = Hash.hexStringFromData(input: Hash.sha256(data: hashedData))
            self.ref.child("users").child(hashedEmail).child("unittest").ref.observe( .value, with: { (snapshot) -> Void in
                if snapshot.exists() {
                    completion(snapshot.children.allObjects as! [DataSnapshot])
                }
            })
        }
    }
    
    func helperDatabase() {
        self.getSnapCellRowAt { (snapshot) -> () in
            for s in snapshot {
                s.value
            }
        }
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
