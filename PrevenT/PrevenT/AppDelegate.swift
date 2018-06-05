//
//  AppDelegate.swift
//  PushBaseApp
//
//  Created by Beto Farias on 4/7/16.
//  Copyright © 2016 2 Geeks one Monkey. All rights reserved.
//

import UIKit;
import GoogleMaps;
import GooglePlaces;
import Firebase;
import FirebaseInstanceID;
import UserNotifications;


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate ,UNUserNotificationCenterDelegate, MessagingDelegate{
    
    
    
    var window: UIWindow?
    let gcmMessageIDKey = "gcm.message_id"
    
    
    
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
        //Quita la notificación del badge
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        //=================== GOOGLE MAPS =====================================================================
        
        GMSServices.provideAPIKey("AIzaSyDUNzmV_EFNPYewlSF462xYYmY-eNdOaUc");
        GMSPlacesClient.provideAPIKey("AIzaSyDUNzmV_EFNPYewlSF462xYYmY-eNdOaUc")
        
        
        //==================== PUSH FIREBASE =========================
        
        FirebaseApp.configure()
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (success, error) in
                if error == nil {
                    print ("Success authorization")
                }
            }
        } else {
            // Fallback on earlier versions
        }
        
        application.registerForRemoteNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshToken(notification:)), name: NSNotification.Name.InstanceIDTokenRefresh, object: nil)
        
        Messaging.messaging().delegate = self
        
        
        return true
    }

    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("didRegisterForRemoteNotificationsWithDeviceToken ")
        //Messaging.messaging().apnsToken = deviceToken
        //FBHandler()

    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Registration failed!")
    }
    
    
    func application(_ application: UIApplication,didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("userinfo in background mode on-\(userInfo)")
        
        completionHandler(UIBackgroundFetchResult.newData)
        
        
        let state = UIApplication.shared.applicationState
        
        if state == .background {
            
            // background
            showMessageRecived(dataStr:userInfo["data"]! as! String);
        }
        else if state == .active {
            
            // foreground
            print(userInfo);
            print(userInfo["data"]);
            
            showMessageRecived(dataStr:userInfo["data"]! as! String);
        }
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        Messaging.messaging().shouldEstablishDirectChannel = false;
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {}
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")
        FBHandler();
    }
    
    func applicationWillTerminate(_ application: UIApplication) {}
    
    @objc func refreshToken(notification:NSNotification){
        let refreshToken = InstanceID.instanceID().token()!;
        print("*** \(refreshToken) ****");
        
        let controller:Controller = Controller();
        controller.registrarDispositivo(idDevice: refreshToken);
        
        
        FBHandler();
    }
    
    
    func FBHandler(){
        Messaging.messaging().shouldEstablishDirectChannel = true;
    }
    
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Message recived ", messaging)
        print("Remote " , remoteMessage.appData);
        print("->" , remoteMessage.appData["data"]);
        
        let dataStr:String = remoteMessage.appData["data"]! as! String
        
        
        if(dataStr == nil){
            return;
        }
        
        showMessageRecived(dataStr:dataStr);
    }
    
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void){
        print("userNotificationCenter");
    }
    
    
    func showMessageRecived(dataStr:String){
        var delitoSeleccionado2Show:DelitoTO = DelitoTO();
        let controller:Controller = Controller();
        var id_evento:String  = "-1";
        var num_delito:String = "-1";
        var id_usuario:String;
        //var id_tipo_delito:String;
        
        if let data = dataStr.data(using: .utf8) {
            do {
                if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:String]{
                    id_evento       = jsonArray["id_evento"]!;
                    num_delito      = jsonArray["id_num_delito"]!;
                    //id_tipo_delito  = jsonArray["id_tipo_delito"];
                    id_usuario      = jsonArray["id_usuario"]!;
                    
                    if(controller.getUserId() == Int(id_usuario)!){
                        //El push es del usuario
                        return;
                    }
                } else {
                    print("bad json")
                    
                    return;
                }
            } catch let error as NSError {
                print(error)
                return;
            }
        }
        
        
        
        let refreshAlert = UIAlertController(title: "Nuevo reporte", message: "¿Desea ver el reporte de delito?", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Si", style: .default, handler: { (action: UIAlertAction!) in
            //print("Handle Ok logic here")
            //Carga el delito solo si puso ver
            delitoSeleccionado2Show = controller.getDelitoDetails(numDelito:"\(num_delito)", idDelito: "\(id_evento)");
            
            // Access the storyboard and fetch an instance of the view controller
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let viewController: ViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController;
            
            viewController.delitoDetalles = delitoSeleccionado2Show
            
            // Then push that view controller onto the navigation stack
            let rootViewController = self.window!.rootViewController as! UINavigationController;
            rootViewController.pushViewController(viewController, animated: true);
        }));
        
        refreshAlert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (action: UIAlertAction!) in
            //No hace nada
        }));
        
        
        //Despliega el alert
        self.window?.rootViewController?.present(refreshAlert, animated: true, completion: nil)
    }
    
}





 

