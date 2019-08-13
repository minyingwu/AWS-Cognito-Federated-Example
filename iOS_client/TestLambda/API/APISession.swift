//
//  APISession.swift
//  TestLambda
//
//  Created by Victor on 2019/7/1.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation
import AWSCognitoIdentityProvider
import FacebookCore

fileprivate let client = AwsLambdaApiClient.default()

class APISession: NSObject {
    static let shared: APISession = APISession()
    
    let CognitoIdentityUserPoolRegion: AWSRegionType = "[YOUR REGION]"
    
    let CognitoIdentityPoolId = "[YOUR COGNITO FEDERATED ID]"
    let AWSCognitoUserPoolsSignInProviderKey = "[YOUR CUSTOM KEY NAME]"
    
    var credentialsProvider: AWSCognitoCredentialsProvider!
    var googleIdToken: String?
    
    
    private override init() {}
    
    func setConfiguration() {
        credentialsProvider = AWSCognitoCredentialsProvider(
            regionType: CognitoIdentityUserPoolRegion,
            identityPoolId: CognitoIdentityPoolId,
            identityProviderManager: ThirdPartyLoginProvider())
        let configuration = AWSServiceConfiguration(
            region: CognitoIdentityUserPoolRegion,
            credentialsProvider: credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    
    // Using AWS service client to trigger HTTP GET
    func get(by action: APIAction.GET, completionHandler: @escaping (AWSTask<AnyObject>) -> ()) {
        switch action {
        case .loginSync:
            client.loginGet().continueWith() { task in
                completionHandler(task)
                // Testing
                print("current identityId: \(String(describing: self.credentialsProvider.identityId))")
                return nil
            }
        case .queryUser(let aws_id):
            client.userGet(aws_id: aws_id).continueWith() { task in
                completionHandler(task)
                return nil
            }
        }
    }
    
    // Using AWS service client to trigger HTTP POST
    func post(by action: APIAction.POST, completionHandler: @escaping (AWSTask<AnyObject>) -> ()) {
        switch action {
        case .createUser(let user):
            client.userPost(body: user).continueWith() { task in
                completionHandler(task)
                return nil
            }
        }
    }
    
    // Using AWS service client to trigger HTTP PATCH
    func patch(by action: APIAction.PATCH, completionHandler: @escaping (AWSTask<AnyObject>) -> ()) {
        switch action {
        case .updateUser(let user):
            client.userPatch(body: user).continueWith() { task in
                completionHandler(task)
                return nil
            }
        }
    }
    
    // Using AWS service client to trigger HTTP DELETE
    func delete(by action: APIAction.DELETE, completionHandler: @escaping (AWSTask<AnyObject>) -> ()) {
        switch action {
        case .deleteUser(let aws_id):
            client.userDelete(aws_id: aws_id).continueWith() { task in
                completionHandler(task)
                return nil
            }
        }
    }
    
    // Forced refresh identity in keychain when identity existed in keychain
    func updateIdentity(completionHandler: @escaping (Error?) -> ()) {
        // // Check if a cognito identity exists
        if credentialsProvider.identityId != nil {
            credentialsProvider.clearKeychain()
            assert(credentialsProvider.identityId == nil)
        }
        // Get a new cognito identity
        credentialsProvider.getIdentityId().continueWith { task in
            if let error = task.error {
                completionHandler(error)
            } else {
                // The new cognito identity token is now stored in the keychain.
                completionHandler(nil)
            }
            return nil
        }
    }
    
}

class ThirdPartyLoginProvider: NSObject, AWSIdentityProviderManager {
    // Automatic trigger login function when local keychain not find
    // Facebook access token will be refresh and mapping to the original AWS identityId
    func logins() -> AWSTask<NSDictionary> {
        switch loginType! {
        case .facebook:
            if let token = AccessToken.current?.authenticationToken {
                print("Facebook Token: \(token)")
                return AWSTask(result: [AWSIdentityProviderFacebook: token])
            }else {
                return AWSTask(error:NSError(domain: "Facebook Login", code: -1 , userInfo: ["Facebook" : "No current Facebook access token"]))
            }
        case .google:
            if let token = APISession.shared.googleIdToken {
                print("Google Token: \(token)")
                return AWSTask(result: [AWSIdentityProviderGoogle: token])
            }else {
                return AWSTask(error:NSError(domain: "Google Login", code: -1 , userInfo: ["Google" : "No current Google access token"]))
            }
        }
    }
}

enum LoginType: Int {
    case facebook
    case google
}

extension LoginType {
    var name: String {
        switch self {
        case .facebook:
            return "facebook"
        case .google:
            return "google"
        }
    }
}

enum APIAction {
    enum GET {
        case loginSync
        case queryUser(aws_id: String)
    }
    enum POST {
        case createUser(user: User)
    }
    enum PATCH {
        case updateUser(user: User)
    }
    enum DELETE {
        case deleteUser(aws_id: String)
    }
}
