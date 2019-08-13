//
//  MainViewController.swift
//  TestLambda
//
//  Created by Victor on 2019/7/26.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import GoogleSignIn

class MainViewController: UIViewController {
    
    let GOOGLE_CLIENT_ID = "[YOUR APP GOOGLE SIGNIN ID]"
    
    @IBOutlet weak var responseTextView: UITextView!
    
    private lazy var fbLoginManager: LoginManager = {
        var manager = LoginManager()
        manager.loginBehavior = .browser
        manager.logOut()
        return manager
    }()
    
    private lazy var detailViewController: UIViewController = {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "DetailViewController")
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Google signin settings
        GIDSignIn.sharedInstance().clientID = GOOGLE_CLIENT_ID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.uiDelegate = self
    }
    
    @IBAction func fbLoginAction(_ sender: Any) {
        fbLoginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self) { loginResult in
            DispatchQueue.main.async {
                switch loginResult {
                case .cancelled:
                    print("User cancelled login")
                    self.responseTextView.text = String(describing: "User cancelled login")
                case .failed(let error):
                    print(error)
                    self.responseTextView.text = String(describing: error)
                case .success( _, _, _):
                    print("Facebook logged in")
                    isLogin = true
                    loginTypeName = LoginType.facebook.name
                    
                    self.syncLogin()
                }
            }
        }
    }
    
    @IBAction func googleLoginAction(_ sender: Any) {
         GIDSignIn.sharedInstance().signIn()
    }
    
    // Sync AWS current matching identity id
    private func syncLogin() {
        APISession.shared.get(by: .loginSync) { task in
            DispatchQueue.main.async {
                if let error = task.error {
                    print("Error: \(error)")
                    self.responseTextView.text = String(describing: error)
                } else if let result = task.result {
                    print("Result: \(result)")
                    self.responseTextView.text = String(describing: result)
                    self.present(self.detailViewController, animated: true)
                }
            }
        }
    }
    
}

extension MainViewController: GIDSignInDelegate, GIDSignInUIDelegate{
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            print("Google login error: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.responseTextView.text = String(describing: "Google login error: \(error.localizedDescription)")
            }
        }else {
            print("Google login success")
            isLogin = true
            loginTypeName = LoginType.google.name
            APISession.shared.googleIdToken = user.authentication.idToken
//            APISession.shared.credentialsProvider.identityProvider.logins()
            
            syncLogin()
            GIDSignIn.sharedInstance()?.signOut()
        }
    }
    
}
