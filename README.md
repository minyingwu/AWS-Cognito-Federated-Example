# aws_cognito_federated_exmaple

This example code will help the beginners in SaaS on AWS development.   
You could follow the source code and this article to create a simple system including frontend iOS app and AWS backend. 

In client side, the iOS app import AWS SDK to handle API from server, and integrate third-party login service.  
In server side, we use Amazon Cognito Federated Identities to manage the login account(including Facebook and Google), Lambda and API Gateway provide RESTful API to client side, and access the user data in DynamoDB.  

## Contents
- [Learn](#learn)
- [Requirements](#requirements)
- [Usage](#usage)
- [Author](#author)
- [License](#license)

## Learn

iOS APP:
- [Facebook Login SDK](#facebook_login)
- [Google Login SDK](#google_login)
- [AWS iOS SDK](#aws_ios_sdk)

Golang backend:  
You need to deploy these service on AWS to finish the example. 
- Amazon Cognito Federated Identities
- IAM(Setup by AWS platform or CLI)
- [Lambda(Golang)](#lambda)
- API Gateway
- DynamoDB

## Requirements

Client:
- iOS 10.0+
- Xcode 8.0+
- Swift 3.0+

Server:
- AWS Lambda
- Golang 1.0+
- Framework Gin

## Usage

### Facebook_Login
Reference: [Facebook Developer Website](https://developers.facebook.com/docs/swift/getting-started)

#### MainViewController.swift
After login the FB account, we need to call syncLogin to trigger AWSIdentityProviderManager logins() callback.
```swift
fbLoginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self) { loginResult in
            DispatchQueue.main.async {
                switch loginResult {
                case .cancelled:
                    print("User cancelled login")
                case .failed(let error):
                    print(error)
                case .success( _, _, _):
                    print("Facebook logged in")
                    isLogin = true
                    loginTypeName = LoginType.facebook.name
                    
                    self.syncLogin()
                }
            }
}
```
### Google_Login
Reference: [Google Developer Website](https://developers.facebook.com/docs/swift/getting-started)

#### MainViewController.swift
After login the Google account, we need to call syncLogin as above.
```swift
GIDSignIn.sharedInstance().clientID = GOOGLE_CLIENT_ID
GIDSignIn.sharedInstance().delegate = self
GIDSignIn.sharedInstance()?.uiDelegate = self
GIDSignIn.sharedInstance().signIn()
```
```swift
extension MainViewController: GIDSignInDelegate, GIDSignInUIDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            print("Google login error: \(error.localizedDescription)")
        }else {
            print("Google login success")
            isLogin = true
            loginTypeName = LoginType.google.name
            APISession.shared.googleIdToken = user.authentication.idToken
            
            syncLogin()
            GIDSignIn.sharedInstance()?.signOut()
        }
    } 
}
```

### AWS_iOS_SDK

#### APISession.swift
Setup your AWS credentials provider at first, you must create a CognitoIdentityPoolId on AWS to manage your account system. 
```swift
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
```

Most important part!  
This delegate will automatic trigger logins() function when token not found or expired on AWS IAM.  
Therefore, in our system the authorization in API is IAM, we don't need to bring token in header field.  

```swift
class ThirdPartyLoginProvider: NSObject, AWSIdentityProviderManager {
    func logins() -> AWSTask<NSDictionary> {
        switch loginType! {
        case .facebook:
            if let token = AccessToken.current?.authenticationToken {
                return AWSTask(result: [AWSIdentityProviderFacebook: token])
            }else {
                return AWSTask(error:NSError(domain: "Facebook Login", code: -1 , userInfo: ["Facebook" : "No current Facebook access token"]))
            }
        case .google:
            if let token = APISession.shared.googleIdToken {
                return AWSTask(result: [AWSIdentityProviderGoogle: token])
            }else {
                return AWSTask(error:NSError(domain: "Google Login", code: -1 , userInfo: ["Google" : "No current Google access token"]))
            }
        }
    }
}
```

After function trigger return AWSTask, you can get the current logged in aws id.
```swift
let aws_id = APISession.shared.credentialsProvider.identityId ?? ""
```

### Lambda

#### router.go
In order to support AWS Lambda in Gin, we use this [reference]("github.com/apex/gateway") to overwrite default Gin Run.
```go
func RunServer() {
	// AWS server
	addr := ":" + os.Getenv("PORT")
	log.Fatal(gateway.ListenAndServe(addr, routerEngine()))
}
```

#### user.go
In our example, after iOS app login a newcomer on server and trigger POST method, we will create a new identity in User DynamoDB.  
You can see more detail about DynamoDB in our code.
```go
func CreateUser(c *gin.Context) {
	var u db.U
	......
	user := &db.User{
		ID: uuid.New(),
		U: u,
	}
	err := db.CreateUser(user)
	......
}
```

## Author

minyingwu, minyingwu123@gmail.com

## License

aws_cognito_federated_exmaple is available under the MIT license. See the LICENSE file for more info.







