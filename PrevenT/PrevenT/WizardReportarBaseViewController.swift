//
//  WizardReportarBaseViewController.swift
//  PrevenT
//
//  Created by Beto Farias on 12/27/15.
//  Copyright © 2015 2 Geeks one Monkey. All rights reserved.
//

import UIKit

class WizardReportarBaseViewController: UIViewController {
    
    
    let name:String = "";

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Asigna la fecha de hoy al delito
        let date:NSDate = NSDate();
        let styler = NSDateFormatter()
        styler.dateFormat = "yyyy-MM-dd"
        let dateString = styler.stringFromDate(date)
        
        delitoReporteTO.txt_fch_delito = dateString;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  

    @IBAction func reporteCortoAction(sender: AnyObject) {
        
        
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
                self.performSegueWithIdentifier("delitoBase2Home", sender: self.name)
             
            }
        }//Termina proceso
    }//Termina método
    
    func reporteDelitoCortoHandler(netRes:NetResponse){
        
        let delito:DelitoTO = DelitoTO(dataString: netRes.data!);
        let controller:Controller = Controller();
        delitoSeleccionado2Show = controller.getDelitoDetails("\(delito.id_num_delito)", idDelito: "\(delito.id_evento)");
        //Regresa al home usuando el hilo principal
        dispatch_async(dispatch_get_main_queue(), {
            self.view.makeToast(message: "Su reporte ha sido almacenado correctamente");
            self.performSegueWithIdentifier("delitoBase2Home", sender: self.name)
        });
        
    }
    
    var delitoSeleccionado2Show:DelitoTO?;

    
    @IBAction func masDetallesAction(sender: AnyObject) {
    }
    
    
    
    //--------------------------- SEGUES -----------------------
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //print(segue.identifier);
        if(segue.identifier == "delitoBase2Home"){
            let destino:ViewController = segue.destinationViewController as! ViewController;
            destino.delitoDetalles = delitoSeleccionado2Show!;
        }
    }
}
