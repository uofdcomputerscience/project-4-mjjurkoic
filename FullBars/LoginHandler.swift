//
//  LoginHandler.swift
//  FullBars
//
//  Created by Michael Jurkoic on 12/13/19.
//  Copyright © 2019 Michael Jurkoic. All rights reserved.
//

import BackgroundTasks
import Foundation
import UIKit
import KeychainAccess
import Reachability

class LoginHandler {
    
    // Captive login page for UDAIR-Hotspot network
    let loginPage = "http://udair2.udallas.edu/cgi-bin/login"
    
    let keychain = Keychain()
    let reachability = try! Reachability(hostname: "https://www.apple.com")
    
    // This is known to work:
    // curl --data "user=mjurkoic&password=900878077&cmd-authenticate&Login=Log+In" -X POST http://udair2.udallas.edu/cgi-bin/login
    func attemptToConnect(completionHandler: @escaping (Bool, Bool) -> Void) {
        var success = false
        var alreadyOnWifi = false
        
        let username: String? = "mjurkoic"
        let password: String? = "900878077"
        
        // If there is already a wifi connection, there is no need to go through all the login shenanigans.
        if reachability.connection == .wifi {
            alreadyOnWifi = true
            completionHandler(success, alreadyOnWifi)
        } else {
            alreadyOnWifi = false
            
            let loginURLString = "\(loginPage)"
            let loginURL = URL(string: loginURLString)!
            let loginRequestBody = "user=\(username ?? "")&password=\(password ?? "")&cmd-authenticate&Login=Log+In"
            
            var loginRequest = URLRequest(url: loginURL)
            
            loginRequest.httpMethod = "POST"
            loginRequest.httpBody = loginRequestBody.data(using: .utf8)
            loginRequest.timeoutInterval = 5.0
            
            print(loginRequest)
            
            let task = URLSession(configuration: .ephemeral).dataTask(with: loginRequest) { (data, response, error) in
                if error != nil {
                    print(error ?? "No error")
                    success = false
                } else {
                    success = true
                    print(data ?? "No data")
                }
                completionHandler(success, alreadyOnWifi)
            }
            task.resume()
        }
    }
    
}
