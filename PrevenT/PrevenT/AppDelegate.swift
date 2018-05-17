//
//  AppDelegate.swift
//  PushBaseApp
//
//  Created by Beto Farias on 4/7/16.
//  Copyright © 2016 2 Geeks one Monkey. All rights reserved.
//

import UIKit
import GoogleMaps


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    //VARIABLES PARA PUSH
    var connectedToGCM = false
    var subscribedToTopic = false
    var gcmSenderID: String?
    var registrationToken: String?
    var registrationOptions = [String: AnyObject]()
    
    let registrationKey = "onRegistrationCompleted"
    let messageKey = "onMessageReceived"
    let subscriptionTopic = "/topics/prevent_2016"
    
    let useSandBox:Bool = false;
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
    
        // Override point for customization after application launch.
        
        
        
        //======================= IOS APN PUSH NOTIFICATIONS ==============================================
   //     registerForPushNotifications(application: application);
        
        // Check if launched from notification
        // 1
//        if let notification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? [String: AnyObject] {
//            //Se notifica al liginController del mensaje
//            NotificationCenter.defaultCenter().postNotificationName(messageKey, object: nil, userInfo: notification);
//        }
        
        //Quita la notificación del badge
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        //=================== GOOGLE MAPS =====================================================================
        
        GMSServices.provideAPIKey("AIzaSyDUNzmV_EFNPYewlSF462xYYmY-eNdOaUc");
        //GMSServices.provideAPIKey("AIzaSyAAqDx52Qgdu-o_7Qta9JFsXga3kObYxwo");
        
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    
    //======================= IOS APN PUSH NOTIFICATIONS ==============================================
    
    //------------------------------------------------------------------------------------------------------------------------------------------
    //----------------------------------- FUNCIONES AGREGADAS PARA EL PUSH ---------------------------------------------------------------------
    //------------------------------------------------------------------------------------------------------------------------------------------

    
    func registerForPushNotifications(application: UIApplication) {
//        let notificationSettings = UIUserNotificationSettings(forTypes: [.badge, .Sound, .Alert], categories: nil)
//        application.registerUserNotificationSettings(notificationSettings)
    }
    
    
    
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .none {
            application.registerForRemoteNotifications()
        }
    }
    
    
    //------------------------------------------------------------
    // ---------------- Recepcion de registro del GCM ------------
    //------------------------------------------------------------

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
//        var tokenString = ""
//
//        for i in 0..<deviceToken.length {
//            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
//        }
//
//        print("Device Token:", tokenString)
//
//        let userInfo = ["registrationToken": tokenString]
//        NotificationCenter.defaultCenter.postNotificationName(self.registrationKey, object: nil, userInfo: userInfo)
    }
    
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register:", error)
    }
    
    
    //------------------------------------------------------------
    // --------------- Recepcion de mensajes PUSH ----------------
    //------------------------------------------------------------
    
    private func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print("Notification received: \(userInfo)")
        // This works only if the app started the GCM service
        GCMService.sharedInstance().appDidReceiveMessage(userInfo);
        // Handle the received message
        
        //Se notifica al liginController del mensaje
        //NotificationCenter.defaultCenter().postNotificationName(messageKey, object: nil, userInfo: userInfo)
    }
    
    //TERMINAN LAS FUNCIONES AGREGADAS PARA EL PUSH -------------------------------
    
}

