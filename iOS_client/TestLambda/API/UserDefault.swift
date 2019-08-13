//
//  UserDefault.swift
//  TestLambda
//
//  Created by Victor on 2019/7/25.
//  Copyright © 2019 Victor. All rights reserved.
//

import Foundation

let userDefaults = UserDefaults.standard

var isLogin: Bool {
    set {
        userDefaults.set(newValue, forKey: "isLogin")
    }
    get {
        return userDefaults.bool(forKey: "isLogin")
    }
}

var loginType: LoginType! = .facebook

var loginTypeName: String = "" {
    didSet {
        if loginTypeName == "facebook" {
            userDefaults.set(loginTypeName, forKey: "loginTypeName")
            loginType = LoginType(rawValue: 0)
        }else if loginTypeName == "google" {
            userDefaults.set(loginTypeName, forKey: "loginTypeName")
            loginType = LoginType(rawValue: 1)
        }
    }
}
