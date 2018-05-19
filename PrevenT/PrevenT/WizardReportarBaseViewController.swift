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
    var delitoSeleccionado2Show:DelitoTO?;

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Asigna la fecha de hoy al delito
        let date:Date = Date();
        let styler = DateFormatter()
        styler.dateFormat = "yyyy-MM-dd"
        let dateString = styler.string(from: date )
        
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
            
            let controller:Controller = Controller();
            let netRes = controller.reporteDelito(delito:delitoReporteTO);
            
            //Hilo principal
            DispatchQueue.global().sync(execute: {
                alert.dismiss(withClickedButtonIndex: -1, animated: true)
                let delito:DelitoTO = DelitoTO(dataString: netRes.data!);
                
                self.delitoSeleccionado2Show = controller.getDelitoDetails(numDelito:"\(delito.id_num_delito!)", idDelito: "\(delito.id_evento!)");
                //Regresa al home usuando el hilo principal
              
                self.view.makeToast(message: "Su reporte ha sido almacenado correctamente");
                self.performSegue(withIdentifier: "delitoBase2Home", sender: self.name)
             
            }
        )};//Termina proceso
    }//Termina método
    
    func reporteDelitoCortoHandler(netRes:NetResponse){
        
        let delito:DelitoTO = DelitoTO(dataString: netRes.data!);
        let controller:Controller = Controller();
        delitoSeleccionado2Show = controller.getDelitoDetails(numDelito:"\(delito.id_num_delito)", idDelito: "\(delito.id_evento)");
        //Regresa al home usuando el hilo principal
        DispatchQueue.main.async(execute:  {
            self.view.makeToast(message: "Su reporte ha sido almacenado correctamente");
            self.performSegue(withIdentifier: "delitoBase2Home", sender: self.name)
        });
        
    }
    
   


    
    
    //--------------------------- SEGUES -----------------------
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //print(segue.identifier);
        if(segue.identifier == "delitoBase2Home"){
            let destino:ViewController = segue.destination as! ViewController;
            destino.delitoDetalles = delitoSeleccionado2Show!;
        }
    }
}
