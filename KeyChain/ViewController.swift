//
//  ViewController.swift
//  KeyChain
//
//  Created by Bakare Waris on 25/02/2022.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
       
       getPassword()
    }
    
    func getPassword() {
        guard let data = KeyChainManager.get(service: "facebook.com", account: "waris") else {
            print("failed")
            return
        }
        
        let password = String(decoding: data, as: UTF8.self)
        print("the password is \(password)")
    }
    
    func save() {
        do {
            try KeyChainManager.save(service: "facebook.com",
                                     account: "waris",
                                     password: "something".data(using: .utf8) ?? Data()
            )
        }
        catch {
            print(error)
        }
    }


}


class KeyChainManager {
    enum KeychainError: Error {
        case duplicateEntry
        case unknown(OSStatus)
        
        var errorDescription: AnyObject {
            switch self {
            case .duplicateEntry:
                return "password already exists" as AnyObject
            case .unknown(let error):
                return error as AnyObject
            }
        }
    }
    
    static func save(service: String,
                     account: String,
                     password: Data) throws {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecValueData as String: password as AnyObject,
        ]
        
        let status = SecItemAdd(
            query as CFDictionary,
            nil
        )
        
        guard status != errSecDuplicateItem else {
            throw KeychainError.duplicateEntry
        }
        guard status == errSecSuccess else {
            throw KeychainError.unknown(status)
        }
        
        print("saved")
    }
    
    static func get(service: String,
                    account: String
                 ) -> Data? {
        let query: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
       var result: AnyObject?
        let status = SecItemCopyMatching(
            query as CFDictionary,
            &result)
        
        print("Result read \(status)")
        
        return result as? Data
    }
    
}
