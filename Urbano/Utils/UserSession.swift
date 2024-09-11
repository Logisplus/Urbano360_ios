//
//  UserSession.swift
//  Urbano
//
//  Created by Mick VE on 21/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import Foundation
import FacebookLogin
import GoogleSignIn

struct UserSession {
    
    struct Profile {
        var userSessionID: String
        var userSessionIDOfPlatform: String
        var userSessionPlatform: Platform
        var userSessionFullName: String
        var userSessionEmail: String
        var userSessionPhotoURL: String
        var userSessionStatus: Status
    }
    
    enum Platform: Int {
        case Facebook = 1
        case Google = 2
    }
    
    enum Status: Int {
        case Logged
        case Unlogged
    }
    
    public static func isUserLogged() -> Bool {
        if let status = UserDefaultsManager.shared.userSessionStatus, status == Status.Logged {
            return true
        }
        return false
    }
    
    public static func getUserSessionID() -> String {
        /*if UserSession.isUserLogged() {
         return UserDefaultsManager.shared.userSessionID!
         } else {
         return "0"
         }*/
        return UserDefaultsManager.shared.userSessionID ?? "0"
    }
    
    public static func saveUserData(userSessionProfile: Profile) {
        UserDefaultsManager.shared.userSessionID = userSessionProfile.userSessionID
        UserDefaultsManager.shared.userSessionIDOfPlatform = userSessionProfile.userSessionIDOfPlatform
        UserDefaultsManager.shared.userSessionPlatform = userSessionProfile.userSessionPlatform
        UserDefaultsManager.shared.userSessionFullName = userSessionProfile.userSessionFullName
        UserDefaultsManager.shared.userSessionEmail = userSessionProfile.userSessionEmail
        UserDefaultsManager.shared.userSessionPhotoURL = userSessionProfile.userSessionPhotoURL
        UserDefaultsManager.shared.userSessionStatus = userSessionProfile.userSessionStatus
    }
    
    public static func logout() {
        if isUserLogged() {
            switch UserDefaultsManager.shared.userSessionPlatform! {
            case .Facebook:
                let loginManager = LoginManager()
                loginManager.logOut()
            case .Google:
                GIDSignIn.sharedInstance().signOut()
            }
            
            UserSession.resetUserData()
            NotificationCenter.default.post(name: Constant.NotificationName.UserDidLogOut, object: nil)
        }
    }
    
    public static func resetUserData() {
        UserDefaultsManager.shared.userSessionID = "0"
        UserDefaultsManager.shared.userSessionIDOfPlatform = ""
        //UserDefaultsManager.shared.userSessionPlatform =
        UserDefaultsManager.shared.userSessionFullName = ""
        UserDefaultsManager.shared.userSessionEmail = ""
        UserDefaultsManager.shared.userSessionPhotoURL = ""
        UserDefaultsManager.shared.userSessionStatus = Status.Unlogged
    }

}
