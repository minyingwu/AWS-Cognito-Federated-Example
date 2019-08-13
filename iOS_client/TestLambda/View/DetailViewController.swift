//
//  DetailViewController.swift
//  TestLambda
//
//  Created by Victor on 2019/7/1.
//  Copyright © 2019 Victor. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class DetailViewController: UIViewController {
    
    @IBOutlet weak var responseTextView: UITextView!
    
    var aws_id: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        responseTextView.text = "Response:"
    }
    
    @IBAction func getDataAction(_ sender: UIButton) {
        let aws_id = APISession.shared.credentialsProvider.identityId ?? ""
        
        APISession.shared.get(by: .queryUser(aws_id: aws_id)) { task in
            DispatchQueue.main.async {
                if let error = task.error {
                    print("Error: \(error)")
                    self.responseTextView.text = String(describing: error)
                } else if let result = task.result {
                    print("Result: \(result)")
                    self.responseTextView.text = String(describing: result)
                }
            }
        }
    }
    
    @IBAction func postDataAction(_ sender: UIButton) {
        let user = User()
        user?.aws_id = APISession.shared.credentialsProvider.identityId ?? ""
        user?.name = "QOO"
        
        APISession.shared.post(by: .createUser(user: user!)) { task in
            DispatchQueue.main.async {
                if let error = task.error {
                    print("Error: \(error)")
                    self.responseTextView.text = String(describing: error)
                } else if let result = task.result {
                    print("Result: \(result)")
                    self.responseTextView.text = String(describing: result)
                }
            }
        }
    }
    
    @IBAction func patchDataAction(_ sender: Any) {
        let user = User()
        user?.aws_id = APISession.shared.credentialsProvider.identityId ?? ""
        user?.name = "CCLEMON"
        
        APISession.shared.patch(by: .updateUser(user: user!)) { task in
            DispatchQueue.main.async {
                if let error = task.error {
                    print("Error: \(error)")
                    self.responseTextView.text = String(describing: error)
                } else if let result = task.result {
                    print("Result: \(result)")
                    self.responseTextView.text = String(describing: result)
                }
            }
        }
    }
    
    @IBAction func deleteDataAction(_ sender: Any) {
        let aws_id = APISession.shared.credentialsProvider.identityId ?? ""
        
        APISession.shared.delete(by: .deleteUser(aws_id: aws_id)) { task in
            DispatchQueue.main.async {
                if let error = task.error {
                    print("Error: \(error)")
                    self.responseTextView.text = String(describing: error)
                } else if let result = task.result {
                    print("Result: \(result)")
                    self.responseTextView.text = String(describing: result)
                }
            }
        }
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        APISession.shared.credentialsProvider.clearCredentials()
        isLogin = false
        self.dismiss(animated: true)
    }
    
    private func updateKeyChain() {
        APISession.shared.updateIdentity() { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Update keychain error: \(error)")
                    self.responseTextView.text = String(describing: error)
                }else {
                    print("Update keychain success")
                    self.responseTextView.text = String(describing: "Update keychain success")
                }
            }
        }
    }
    
}
