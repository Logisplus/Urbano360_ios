//
//  UserDefaultsManager.swift
//  Urbano
//
//  Created by Mick VE on 16/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import Foundation

class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    
    // Initialization
    private init() {}
    
    var environment: API.Environment? {
        get {
            guard let environment = UserDefaults.standard.value(forKey: "kEnvironmentKey") as? Int else {
                return nil
            }
            return API.Environment(rawValue: environment)
        }
        set (environment) {
            UserDefaults.standard.set(environment?.rawValue, forKey: "kEnvironmentKey")
        }
    }
    
    var country: API.Country? {
        get {
            guard let country = UserDefaults.standard.value(forKey: "kCountryKey") as? Int else {
                return nil
            }
            return API.Country(rawValue: country)
        }
        set (country) {
            UserDefaults.standard.set(country?.rawValue, forKey: "kCountryKey")
        }
    }
    
    var userSessionID: String? {
        get {
            guard let id = UserDefaults.standard.value(forKey: "kUserSessionIDKey") as? String else {
                return nil
            }
            return id
        }
        
        set (id) {
            UserDefaults.standard.set(id, forKey: "kUserSessionIDKey")
        }
    }
    
    var userSessionIDOfPlatform: String? {
        get {
            guard let id = UserDefaults.standard.value(forKey: "kUserSessionIDOfPlatformKey") as? String else {
                return nil
            }
            return id
        }
        
        set (id) {
            UserDefaults.standard.set(id, forKey: "kUserSessionIDOfPlatformKey")
        }
    }
    
    var userSessionPlatform: UserSession.Platform? {
        get {
            guard let platform = UserDefaults.standard.value(forKey: "kUserSessionPlatformKey") as? Int else {
                return nil
            }
            return UserSession.Platform(rawValue: platform)
        }
        
        set (platform) {
            UserDefaults.standard.set(platform?.rawValue, forKey: "kUserSessionPlatformKey")
        }
    }
    
    var userSessionFullName: String? {
        get {
            guard let fullName = UserDefaults.standard.value(forKey: "kUserSessionFullNameKey") as? String else {
                return nil
            }
            return fullName
        }
        
        set (fullName) {
            UserDefaults.standard.set(fullName, forKey: "kUserSessionFullNameKey")
        }
    }
    
    var userSessionEmail: String? {
        get {
            guard let email = UserDefaults.standard.value(forKey: "kUserSessionEmailKey") as? String else {
                return nil
            }
            return email
        }
        
        set (email) {
            UserDefaults.standard.set(email, forKey: "kUserSessionEmailKey")
        }
    }
    
    var userSessionPhotoURL: String? {
        get {
            guard let photoURL = UserDefaults.standard.value(forKey: "kUserSessionPhotoURLKey") as? String else {
                return nil
            }
            return photoURL
        }
        
        set (photoURL) {
            UserDefaults.standard.set(photoURL, forKey: "kUserSessionPhotoURLKey")
        }
    }
    
    var userSessionStatus: UserSession.Status? {
        get {
            guard let status = UserDefaults.standard.value(forKey: "kUserSessionStatusKey") as? Int else {
                return nil
            }
            return UserSession.Status(rawValue: status)
        }
        
        set (status) {
            UserDefaults.standard.set(status?.rawValue, forKey: "kUserSessionStatusKey")
        }
    }
    
    var searchTrackingRecord: [String]? {
        get {
            guard let record = UserDefaults.standard.value(forKey: "kSearchTrackingRecordKey") as? [String] else {
                return nil
            }
            return record
        }
        
        set (record) {
            UserDefaults.standard.set(record, forKey: "kSearchTrackingRecordKey")
        }
    }
}
