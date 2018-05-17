//
//  LoginViewController.swift
//  PrevenT
//
//  Created by Beto Farias on 11/6/15.
//  Copyright © 2015 2 Geeks one Monkey. All rights reserved.
//

import UIKit
import Spring

class LoginViewController: UIViewController {

    @IBOutlet weak var txtEmail: DesignableTextField!
    
    @IBOutlet weak var txtPassword: DesignableTextField!
    
    
    var keyboardIsShowing = false
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector:  #selector(LoginViewController.keyboardWillShow), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        
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
        
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x:50, y:10, width:37, height:37)) as UIActivityIndicatorView
        loadingIndicator.center = self.view.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.setValue(loadingIndicator, forKey: "accessoryView")
        loadingIndicator.startAnimating()
        
        alert.show();
        
        
        //---------- PROCESO ASINCRONO ---------------
        DispatchQueue.main.async {
           
            
            let controller = Controller()
            let res = controller.login(user: self.txtEmail.text!, pass: self.txtPassword.text!)
            
            //Hilo principal
            //DispatchQueue.main.sync {
                alert.dismiss(withClickedButtonIndex: -1, animated: true)
                if(res == 1){
                    self.navigationController?.popToRootViewController(animated: true)
                }else if(res == 0){
                    self.view.makeToast(message: "Usuario y/o contraseña incorrectos");
                }else if(res == -1){
                    self.view.makeToast(message: "No hay conexión a internet");
                }
                
           // }
        }//Termina proceso
    }//Termina metodo
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        txtPassword.resignFirstResponder()
        txtEmail.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        print("keybord show");
        if  !keyboardIsShowing {
            
            if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                
                self.view.frame.origin.y -= keyboardSize.height;
            }else{
                self.view.frame.origin.y -= 180
            }
            keyboardIsShowing = true
        }
    }

    
    @objc func keyboardWillHide(sender: NSNotification) {
        print("keybord hide");
        if  keyboardIsShowing {
            self.view.frame.origin.y = 0
            keyboardIsShowing = false
        }
    }
    
    
}
