//
//  Hash.swift
//  ConciergeApp
//
//  Created by Conrad Liu on 11/29/17.
//  Copyright © 2017 James Schulman. All rights reserved.
//

import Foundation

public class Hash {
    // Hashing functions for database retrieval and storage
    public static func sha256(data : NSData) -> NSData {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256(data.bytes, CC_LONG(data.length), &hash)
        let res = NSData(bytes: hash, length: Int(CC_SHA256_DIGEST_LENGTH))
        return res
    }
    
    public static func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)
        var hexString = ""
        
        for byte in bytes {
            hexString += String(format:"%02x", UInt8(byte))
        }
        
        return hexString
    }
}
