//
//  NotificationHandlerDelegate.swift
//  Urbano
//
//  Created by Mick VE on 22/04/18.
//  Copyright © 2018 Urbano. All rights reserved.
//

import Foundation

@objc protocol NotificationHandlerDelegate {
    
    @objc optional func userDidLogInNotificationHandler(notification: Notification)
    
    @objc optional func userDidLogOutNotificationHandler(notification: Notification)
}
