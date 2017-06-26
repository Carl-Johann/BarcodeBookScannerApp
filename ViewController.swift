//
//  ViewController.swift
//  BarcodeBookScanner
//
//  Created by CarlJohan on 25/06/2017.
//  Copyright © 2017 Carl-Johan. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import GoogleSignIn

class ViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFBLoginButto()
        
        setupCustomFBButton()
        
        setupGoogleButton()
        
        setupCustomGoogleButtom()
    }

    
    fileprivate func setupFBLoginButto() {
        
        // Creating the standard Facebook login button
        let fbLoginButton = FBSDKLoginButton()
        fbLoginButton.frame = CGRect(x: 16, y: 50, width: view.frame.width - 32, height: 50)
        
        fbLoginButton.delegate = self
        fbLoginButton.readPermissions = ["email", "public_profile"]
        
        view.addSubview(fbLoginButton)

    }
    
    fileprivate func setupCustomFBButton() {
        
        // Creating the custom Facebook login button
        let customFBButton = UIButton(type: .system)
        customFBButton.backgroundColor = UIColor.blue
        customFBButton.frame = CGRect(x: 16, y: 116, width: view.frame.width - 32, height: 50)
        customFBButton.setTitle("Custom FB login button", for: .normal)
        
        customFBButton.addTarget(self, action: #selector(customFBButtonAction), for: .touchUpInside)
        
        view.addSubview(customFBButton)
    
    }
    
    fileprivate func setupGoogleButton() {
        
        // Creating the Google signin button
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: 16, y: 116 + 66, width: view.frame.width - 32, height: 50)
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        view.addSubview(googleButton)
        
    }
    
    fileprivate func setupCustomGoogleButtom() {
    
        // Creating the custom Google button
        let customGoogleButton = UIButton(type: .system)
        customGoogleButton.frame = CGRect(x: 16, y: 116 + 132, width: view.frame.width - 32, height: 50)
        customGoogleButton.backgroundColor = UIColor.darkGray
        customGoogleButton.setTitle("Google Button", for: .normal)
        
        
        customGoogleButton.addTarget(self, action: #selector(customGoogleButtonAction), for: .touchUpInside)
        view.addSubview(customGoogleButton)
        
    }
    
    
    func customGoogleButtonAction(_ button: UIButton) {
        if GIDSignIn.sharedInstance().currentUser != nil {
            // Not signed into Google
            GIDSignIn.sharedInstance().signOut()
            print(1)
            //button.setTitle("Sign Into Google", for: .normal)
        } else {
            // Signed into Google
            //button.setTitle("Sign Out of Google", for: .normal)
            print(2)
            GIDSignIn.sharedInstance().signIn()
        }
    }
    
    
    func customFBButtonAction() {
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, error) in
            if error != nil {
                print("Custom FB Button login failed", error)
                return
            }
            
            self.getFBUserInfo()
        
        }
    }
    
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out")
    }

    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print("error", error)
            return
        }
        
        print("Succesfully logged in with facebook")
        getFBUserInfo()
    }
    
    
    
    
    
    func getFBUserInfo() {
        guard let accessToken = FBSDKAccessToken.current() else { print("couldn't get current access token"); return }
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
        
        Auth.auth().signIn(with: credentials) { (user, error) in
            if error != nil { print("Couldn't sign in with credentials", error); return }
            
            print("Succesfully signed in with credentials", user)
        }
        
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, email, name"]).start { (connection, result, error) in
            if error != nil {
                print("Failed to start graph request \(error)")
                return
            }
            
            print(result!)
            
        }
    }
    
    
}
