//
//  WizardReportarCompletoViewController.swift
//  PrevenT
//
//  Created by Beto Farias on 12/27/15.
//  Copyright © 2015 2 Geeks one Monkey. All rights reserved.
//

import UIKit

class WizardReportarCompletoViewController: UIViewController {
    
    
    @IBOutlet var txtDate: UILabel!
    @IBOutlet var txtDelincuentes: UILabel!
    @IBOutlet var txtVictimas: UILabel!
    @IBOutlet var txtDescripcion: UITextView!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var dateView: UIView!
    
    
    var numDelincuentes:Int = 0;
    var numVictimas:Int = 0;
    
    var date:NSDate = NSDate();
    
    var keyboardIsShowing = false;

    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        txtVictimas.text = "\(numVictimas)";
        txtDelincuentes.text = "\(numDelincuentes)";
        
        dateView.hidden = true;
        //Actualiza la fecha
        updateDate();

    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
    }
    

    override func viewWillAppear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
        
    }
    
    
    //----------- MANEJO DEL TECLADO --------------
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        txtDescripcion.resignFirstResponder()
    }
    
    func keyboardWillShow(sender: NSNotification) {
        if  !keyboardIsShowing {
            self.view.frame.origin.y -= 100
            keyboardIsShowing = true
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        if  keyboardIsShowing {
            self.view.frame.origin.y += 100
            keyboardIsShowing = false
        }
    }
    
    //-------------------
    
    func updateDate(){
        let styler = NSDateFormatter()
        styler.dateFormat = "dd-MM-yyyy"
        let dateString = styler.stringFromDate(date)
        
        txtDate.text = dateString;
        
    
    }
    
    @IBAction func minDelincuentesAction(sender: AnyObject) {
        numDelincuentes -= 1;
        if(numDelincuentes < 0){
            numDelincuentes = 0;
        }
        txtDelincuentes.text = "\(numDelincuentes)";
    }
    
    
    @IBAction func addDelincuentesAction(sender: AnyObject) {
        numDelincuentes += 1;
        txtDelincuentes.text = "\(numDelincuentes)";
    }
   
    @IBAction func minVictimasAction(sender: AnyObject) {
        numVictimas -= 1;
        if(numVictimas < 0){
            numVictimas = 0;
        }
        txtVictimas.text = "\(numVictimas)";
    }
    
   
    @IBAction func addVictimasAction(sender: AnyObject) {
        numVictimas += 1;
        txtVictimas.text = "\(numVictimas)";
    }
    
    
    
    
    @IBAction func showDateAction(sender: AnyObject) {
        dateView.hidden = false;
    }
    
    @IBAction func aceptarDateAction(sender: AnyObject) {
        dateView.hidden = true;
        date = datePicker.date;
        updateDate();
    }
    
   
    @IBAction func publicarDelito(sender: UIButton) {
        
        //TODO validar si hay texto
        if( txtDescripcion.text.characters.count == 0){
            self.view.makeToast(message: "Debe indicar el relato del evento");
            return;
        }
        
        delitoReporteTO.txt_resumen = txtDescripcion.text
        delitoReporteTO.num_victimas = numVictimas
        delitoReporteTO.num_delincuentes = numDelincuentes
        
        
        //print(delitoReporteTO.toString())
        
       
        
        
        
        
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
            
            let controller:Controller = Controller();
            let netRes = controller.reporteDelito(delitoReporteTO);
            
            //Hilo principal
            dispatch_async(dispatch_get_main_queue()) {
                
                alert.dismissWithClickedButtonIndex(-1, animated: true)
                let delito:DelitoTO = DelitoTO(dataString: netRes.data!);
                
                self.delitoSeleccionado2Show = controller.getDelitoDetails("\(delito.id_num_delito)", idDelito: "\(delito.id_evento)");
                //Regresa al home usuando el hilo principal
               
                self.view.makeToast(message: "Su reporte ha sido almacenado correctamente");
                self.performSegueWithIdentifier("reportarDelito2Home", sender: self)
                
            }
        }//Termina proceso

    }//Termina método
    
    
    func publicarDelitoHandler(netRes:NetResponse){
        //print("NetResResponse code: \(netRes.code)");
        
        let delito:DelitoTO = DelitoTO(dataString: netRes.data!);
        
        let controller:Controller = Controller();
        self.delitoSeleccionado2Show = controller.getDelitoDetails("\(delito.id_num_delito)", idDelito: "\(delito.id_evento)");
        
        //Regresa al home usuando el hilo principal
        dispatch_async(dispatch_get_main_queue(), {
            self.view.makeToast(message: "Su reporte ha sido almacenado correctamente");
            self.performSegueWithIdentifier("reportarDelito2Home", sender: self)
            
        });
        
    }
    
    var delitoSeleccionado2Show:DelitoTO?;
   


//--------------------------- SEGUES -----------------------



override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    //print(segue.identifier);
    if(segue.identifier == "reportarCompeto2SeleccionarFotografias"){
        
    }
    
    if(segue.identifier == "reportarDelito2Home"){
        let destino:ViewController = segue.destinationViewController as! ViewController;
        destino.delitoDetalles = delitoSeleccionado2Show!;
    }
}


}
