//
//  LoginViewController.swift
//  PrevenT
//
//  Created by Beto Farias on 11/6/15.
//  Copyright © 2015 2 Geeks one Monkey. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    
    @IBOutlet weak var txtPassword: UITextField!
    
    
    var keyboardIsShowing = false
    
    
    override func viewWillAppear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func noTengoCuentaAction(sender: AnyObject) {
    }
    
    
    @IBAction func loginAction(sender: UIButton) {
        
        //--- VENTANA DE ESPERE ---------------
        let alert: UIAlertView = UIAlertView();
        alert.message = "Espere por favor";
        
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(50, 10, 37, 37)) as UIActivityIndicatorView
        loadingIndicator.center = self.view.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        loadingIndicator.startAnimating();
        
        alert.setValue(loadingIndicator, forKey: "accessoryView")
        loadingIndicator.startAnimating()
        
        alert.show();
        
        
        //---------- PROCESO ASINCRONO ---------------
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            
            let controller = Controller()
            let res = controller.login(self.txtEmail.text!, pass: self.txtPassword.text!)
            
            //Hilo principal
            dispatch_async(dispatch_get_main_queue()) {
                
                alert.dismissWithClickedButtonIndex(-1, animated: true)
                if(res == 1){
                    self.navigationController?.popToRootViewControllerAnimated(true)
                }else if(res == 0){
                    self.view.makeToast(message: "Usuario y/o contraseña incorrectos");
                }else if(res == -1){
                    self.view.makeToast(message: "No hay conexión a internet");
                }
                
            }
        }//Termina proceso
    }//Termina metodo
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        txtPassword.resignFirstResponder()
        txtEmail.resignFirstResponder()
    }
    
    func keyboardWillShow(sender: NSNotification) {
        
        if  !keyboardIsShowing {
            
            if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                
                self.view.frame.origin.y -= keyboardSize.height;
            }else{
                self.view.frame.origin.y -= 180
            }
            keyboardIsShowing = true
        }
    }

    
    func keyboardWillHide(sender: NSNotification) {
        if  keyboardIsShowing {
            self.view.frame.origin.y = 0
            keyboardIsShowing = false
        }
    }
    
    
}
