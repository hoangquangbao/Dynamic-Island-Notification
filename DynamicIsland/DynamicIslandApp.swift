//
//  DynamicIslandApp.swift
//  DynamicIsland
//
//  Created by Quang Bao on 12/09/2022.
//

import SwiftUI
import UserNotifications

// MARK: Creating APNs Files
// Simple Create a new File with format .apns
// And Paste the Following Code
@main
struct DynamicIslandApp: App {
    // MARK: Linking App Delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    // MARK: All Notifications
    @State var notifications: [NotificationValue] = []
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .top) {
                    GeometryReader { proxy in
                        let size = proxy.size
                        
                        ForEach(notifications) { notification in
                            NotificationPreview(size: size, value: notification, notifications: $notifications)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        }
                    }
                    .ignoresSafeArea()
                }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("NOTIFY"))) { output in
                    if let content = output.userInfo?["content"] as? UNNotificationContent {
                        // MARK: Creating New Notification
                        let newNotification = NotificationValue(content: content)
                        notifications.append(newNotification)
                    }
                }
        }
    }
}

// MARK: Creating Custom Notification View
// Which Will Be Looking like it's Extracting From Dynamic Island
struct NotificationPreview: View {
    
    var size: CGSize
    var value: NotificationValue
    @Binding var notifications: [NotificationValue]
    var body: some View {
        HStack {
            // MARK: UI
            // NOTE: App icon file can be accessed with this String "AppIcon60x60"
            if let image = UIImage(named: "Applcon60x60") {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            }
                
            VStack(alignment: .leading, spacing: 8) {
                Text(value.content.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(value.content.body)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .padding(.horizontal, 12)
        // MARK: If your Text goes more than one line
        // Then it's recommend to give padding as the height of the Dynamic Island
        .padding(.vertical, 18)
        // MARK: Adding some blur
        .blur(radius: value.showNotification ? 0 : 30)
        .opacity(value.showNotification ? 1 : 0)
        .scaleEffect(value.showNotification ? 1 : 0.5, anchor: .top)
        // It's Not Matching the Curve
        // So Giving padding as the same amount of top offset
        // 11 * 2 = 22
        .frame(width: value.showNotification ? size.width - 22 : 126, height: value.showNotification ? nil : 37.33)
        .background {
            // RADIUS = 126 / 2 = 63
            RoundedRectangle(cornerRadius: value.showNotification  ?  50 : 63, style: .continuous)
                .fill(.black)
        }
        .clipped()
        .offset(y: 11)
        .animation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7), value: value.showNotification)
        // MARK: Auto Close After Some Time
        // Then Removing Notification from the Array
        .onChange(of: value.showNotification, perform: { newValue in
            if newValue && notifications.indices.contains(index){
                // Your custom value goes here
                
                // MARK: Adding multiple notifications as overlay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    if notifications.indices.contains(index + 1) {
                        notifications[index + 1].showNotification = true
                    }
                    
                    // 1.5 + 1.3 = 2.8
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                        notifications[index].showNotification = false
                        
                        // MARK: SAFE CHECK GOES HERE
                        // BEFORE REMOVING ITEM FROM THE ARRAY
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if notifications.indices.contains(index + 1) {
                                notifications[index + 1].showNotification = true
                            }
                        }
                        
                        // Our max animation timing is 0.7
                        // So after that removing notification from the array
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            notifications.remove(at: index)
                        }
                    }
                }
            }
        })
        .onAppear {
            // MARK: Animating When A New Notification is Added
            if index == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    notifications[index].showNotification = true
                }
            }
        }
    }
                   
    //MARK: Index
    var index: Int {
        return notifications.firstIndex { CValue in
            CValue.id == value.id
        } ?? 0
    }
}

// MARK: App Delegate to Listen for In App Notifications
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        if UIApplication.shared.haveDynamicIsland{
            // MARK: Do Animation
            // MARK: Observing Notifications
            NotificationCenter.default.post(name: NSNotification.Name("NOTIFY"), object: nil,userInfo: ["content" : notification.request.content])
            return [.sound]
        } else {
            // MARK: Normal Notification
            return [.sound, .banner]
        }
    }
}

// MARK: There has been no API for Dynamic until now, so I'm going to create a completely custom notification animation
// API Usage Will Be Improved Begining with iOS 16.1
// So for now, we can easily detect the Dynamic Island Enable phones (because it has only two models: iPhone 14 Pro & Pro Max)
extension UIApplication {
    var haveDynamicIsland: Bool {
        return deviceName == "iPhone 14 Pro" || deviceName == "iPhone 14 Pro Max"
    }
    var deviceName: String{
        return UIDevice.current.name
    }
}
