//
//  UserNotifications.swift
//  DynamicIsland
//
//  Created by Quang Bao on 12/09/2022.
//

import SwiftUI
import UserNotifications

// MARK: Model Holder all Notification Data
struct NotificationValue: Identifiable {
    var id: String = UUID().uuidString
    var content: UNNotificationContent
    var dateCreated: Date = Date()
    var showNotification: Bool = false
}
