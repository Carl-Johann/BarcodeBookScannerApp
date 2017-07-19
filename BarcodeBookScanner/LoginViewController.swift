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
import FirebaseDatabase
import FirebaseStorage


class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate, GIDSignInDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GIDSignIn.sharedInstance().scopes.append("https://www.googleapis.com/auth/books")
        GIDSignIn.sharedInstance().delegate = self
        
        
        setupFBLoginButtons()
        setupGoogleButtoms()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        
        GIDSignIn.sharedInstance().signIn()
        signIntoFirebase()
    }
    
    func signIntoFirebase() {
     
        let user = GIDSignIn.sharedInstance().currentUser
        
        guard let idToken = user?.authentication.idToken else { print("Couldn't get idToken from user"); return }
        guard let accessToken = user?.authentication.accessToken else { print("Couldn't get 'accessToken' from user"); return }
        
        let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        Auth.auth().signIn(with: credentials) { (firebaseUser, error) in
            
            if error != nil { print("Failed to sign into Firebase with Google"); return
            }
            // user authenticated at Firebase
            
            guard let currentUser = GIDSignIn.sharedInstance().currentUser.profile else {
                print("Couldn't acccess current user"); return
            }
            
            guard let user = firebaseUser else { print("Signed in user == nil"); return }
            
            let ref = Database.database().reference(fromURL: "https://barcodebookscanner.firebaseio.com/")
            let userRef = ref.child("Users").child(user.uid)
            let values = ["name": currentUser.name, "email": currentUser.email] as [AnyHashable: Any]
            
            userRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
                if error != nil {
                    print("An error occurred updating users childValues", error!); return
                }
            })
            print("Successfully signed/updated user into Firebase")
            
            self.performSegue(withIdentifier: "loginSegue", sender: self)
            
        }

    
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            print("Failed to log into Google", error); return
        }
        // user authenticated at Google
        
        guard let idToken = user.authentication.idToken else { print("Couldn't get idToken from user"); return }
        guard let accessToken = user.authentication.accessToken else { print("Couldn't get 'accessToken' from user"); return }
        
        let credentials = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        Auth.auth().signIn(with: credentials) { (firebaseUser, error) in
            
            if error != nil { print("Failed to sign into Firebase with Google"); return
            }
            // user authenticated at Firebase
            
            guard let currentUser = GIDSignIn.sharedInstance().currentUser.profile else {
                print("Couldn't acccess current user"); return
            }
            
            guard let user = firebaseUser else { print("Signed in user == nil"); return }
            
            let ref = Database.database().reference(fromURL: "https://barcodebookscanner.firebaseio.com/")
            let userRef = ref.child("Users").child(user.uid)
            let values = ["name": currentUser.name, "email": currentUser.email] as [AnyHashable: Any]
            
            userRef.updateChildValues(values, withCompletionBlock: { (error, ref) in
                if error != nil {
                    print("An error occurred updating users childValues", error!); return
                }
            })
            print("Successfully signed/updated user into Firebase")
            
            self.performSegue(withIdentifier: "loginSegue", sender: self)
            
        }
    }

    fileprivate func setupFBLoginButtons() {
        
        // Creating the standard Facebook login button
        let fbLoginButton = FBSDKLoginButton()
        fbLoginButton.frame = CGRect(x: 16, y: 50, width: view.frame.width - 32, height: 50)
        
        fbLoginButton.delegate = self
        fbLoginButton.readPermissions = ["email", "public_profile"]
        
        view.addSubview(fbLoginButton)
        
        // Creating the custom Facebook login button
        let customFBButton = UIButton(type: .system)
        customFBButton.backgroundColor = UIColor.blue
        customFBButton.frame = CGRect(x: 16, y: 116, width: view.frame.width - 32, height: 50)
        customFBButton.setTitle("Custom FB login button", for: .normal)
        
        customFBButton.addTarget(self, action: #selector(customFBButtonAction), for: .touchUpInside)
        
        view.addSubview(customFBButton)
        
    }
    
    
    
    fileprivate func setupGoogleButtoms() {
        
        // Creating the Google signin button
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: 16, y: 116 + 66, width: view.frame.width - 32, height: 50)
        
        GIDSignIn.sharedInstance().uiDelegate = self
        
        view.addSubview(googleButton)
        
        
        // Creating the custom Google button
        let customGoogleButton = UIButton(type: .system)
        customGoogleButton.frame = CGRect(x: 16, y: 116 + 132, width: view.frame.width - 32, height: 50)
        customGoogleButton.backgroundColor = UIColor.darkGray
        customGoogleButton.setTitle("Log out of Google", for: .normal)
        
        
        customGoogleButton.addTarget(self, action: #selector(customGoogleButtonAction), for: .touchUpInside)
        view.addSubview(customGoogleButton)
        
    }
    
    
    
    
    
    
    func customGoogleButtonAction(_ sender: UIButton) {
        GIDSignIn.sharedInstance().signOut()
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out")
    }
    
    
    
    func customFBButtonAction() {
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, error) in
            if error != nil { print("Custom FB Button login failed", error!); return
            }
            
            self.getFBUserInfo()
        }
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
            if error != nil { print("Couldn't sign in with credentials", error!); return
            }
            
            print("Succesfully signed in to Firebase with credentials", user!.uid)
        }
        
//        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, email, name"]).start { (connection, result, error) in
//            if error != nil { print("Failed to start graph request \(error!)"); return
//            }
//            
//            print(result!)
//            
//        }
    }
    
    
    
    
}
