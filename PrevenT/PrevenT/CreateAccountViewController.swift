// http://www.ioscreator.com/tutorials/activity-indicator-tutorial-ios8-swift
//
//  CreateAccountViewController.swift
//  PrevenT
//
//  Created by Beto Farias on 11/17/15.
//  Copyright © 2015 2 Geeks one Monkey. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var txtNombrePersona: UITextField!
    @IBOutlet weak var txtCorreoPersona: UITextField!
    @IBOutlet weak var txtPasswordPersona: UITextField!
    @IBOutlet weak var txtPasswordPersona2: UITextField!
    
    
    var keyboardIsShowing = false
    
    
    override func viewWillAppear(_ animated: Bool) {
        txtNombrePersona.delegate = self
        txtNombrePersona.tag = 0 //Increment accordingly
        
        txtCorreoPersona.delegate = self
        txtCorreoPersona.tag = 1 //Increment accordingly
        
        txtPasswordPersona.delegate = self
        txtPasswordPersona.tag = 2
        
        txtPasswordPersona2.delegate = self
        txtPasswordPersona2.tag = 3
        
        NotificationCenter.default.addObserver(self, selector: Selector("keyboardWillShow:"), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: Selector("keyboardWillHide:"), name:NSNotification.Name.UIKeyboardWillHide, object: nil);

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Do This For Each UITextField
            }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let nextTag: NSInteger = textField.tag + 1;
        // Try to find next responder
        if let nextResponder: UIResponder? = textField.superview!.viewWithTag(nextTag){
            nextResponder?.becomeFirstResponder()
        }
        else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        return false // We do not want UITextField to insert line-breaks.
    }
    
    
    @IBAction func crearCuentaAction(sender: UIButton) {
        if(txtNombrePersona.text?.characters.count == 0 ){
            self.view.makeToast(message: "El nombre no puede estar vacio")
            return
        }
        if(txtCorreoPersona.text?.characters.count == 0 ){
            self.view.makeToast(message: "El correo no puede estar vacio")
            return
        }
        
        if(!StringUtils.isValidEmail(testStr: txtCorreoPersona.text!)){
            self.view.makeToast(message: "El correo es incorrecto")
            return
        }
        
        
        if(txtPasswordPersona.text?.characters.count == 0 ){
            self.view.makeToast(message: "La contraseña no puede estar vacia")
            return
        }
        if(txtPasswordPersona2.text?.characters.count == 0 ){
            self.view.makeToast(message: "La validación de la contraseña no puede estar vacia")
            return
        }
        
        if(txtPasswordPersona.text == txtPasswordPersona2.text) {
        }else{
            self.view.makeToast(message: "Las contraseñas no coinciden")
            return
        }
        
        //CozyLoadingActivity.show("Creando cuenta...", disableUI: true)
        
       // let controller = Controller()
        
        //controller.registarNuevoUsuario(txtNombrePersona.text!, txtCorreoPersona: txtCorreoPersona.text!, txtPasswordPersona: txtPasswordPersona.text!, handler: createCuentaResultCallback)
        
        
        //--- VENTANA DE ESPERE ---------------
        let alert: UIAlertView = UIAlertView();
        alert.message = "Creando cuenta, espere por favor";
        
       
        
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x:50, y:10, width:37, height:37)) as UIActivityIndicatorView
        loadingIndicator.center = self.view.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.setValue(loadingIndicator, forKey: "accessoryView")
        loadingIndicator.startAnimating()
        
        alert.show();
        
        
        //---------- PROCESO ASINCRONO ---------------
        let priority = DispatchQueue.GlobalQueuePriority.default
        
        DispatchQueue.global(qos: .userInitiated).async() {
            
            let controller = Controller()
            let res = controller.registarNuevoUsuario(txtNombrePersona:self.txtNombrePersona.text!, txtCorreoPersona: self.txtCorreoPersona.text!, txtPasswordPersona: self.txtPasswordPersona.text!)
            
            if(res.code == 1){
                let resLogin = controller.login(user:self.txtCorreoPersona.text!, pass: self.txtPasswordPersona.text!);
            }
            
            //Hilo principal
            DispatchQueue.main.async() {
                
                //Quita la ventana de espera
                alert.dismiss(withClickedButtonIndex: -1, animated: true)
                
                if(res.code == 1){
                    //Si la creación del usuario es correcta hace el login
                    
                    self.navigationController?.popToRootViewController(animated: true)
                    self.view.makeToast(message: "Cuenta creada correctamente");
                }else {
                    self.view.makeToast(message: res.message!);
                }
                
            }
        }//Termina proceso
    }
    
    
    
    
    //MARK: ---- KEYBOARD
    
    var activeField: UITextField!
    
    func textFieldDidBeginEditing(textField: UITextField)
    {
        activeField = textField
    }
    
    func textFieldDidEndEditing(textField: UITextField)
    {
        activeField = nil
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        txtNombrePersona.resignFirstResponder()
        txtCorreoPersona.resignFirstResponder()
        txtPasswordPersona.resignFirstResponder()
        txtPasswordPersona2.resignFirstResponder()
    }
    

    
    func keyboardWillShow(sender: NSNotification) {
    
       // if  !keyboardIsShowing {
            
            //if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                
            //    self.view.frame.origin.y -= keyboardSize.height;
            //}else{
            //    self.view.frame.origin.y = -180
            //}
            
            
            var scrollSize:CGFloat = 0;
           // print(activeField.tag);
            
        if(activeField != nil){
            switch(activeField.tag){
            case 0:
                scrollSize = -50;
                break;
            case 1:
                scrollSize = -100;
                break;
            case 2:
                scrollSize = -150;
                break;
            case 3:
                scrollSize = -200;
                break;
            case 4:
                scrollSize = -250;
                break;
            default:
                scrollSize = -300;
            }
        }

            self.view.frame.origin.y = scrollSize;
            
            keyboardIsShowing = true
       // }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        if  keyboardIsShowing {
                self.view.frame.origin.y = 0
                keyboardIsShowing = false
        }
    }
    
}
