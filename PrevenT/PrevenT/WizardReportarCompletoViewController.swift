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
    
    var date:Date = Date();
    
    var keyboardIsShowing = false;

    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        txtVictimas.text = "\(numVictimas)";
        txtDelincuentes.text = "\(numDelincuentes)";
        
        dateView.isHidden = true;
        //Actualiza la fecha
        updateDate();

    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
        
    }
    

    override func viewWillAppear(_ animated: Bool) {
        
//        NotificationCenter.default.addObserver(self, selector: Selector(("keyboardWillShow:")), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
//        NotificationCenter.default.addObserver(self, selector: Selector(("keyboardWillHide:")), name:NSNotification.Name.UIKeyboardWillHide, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        
    }
    
    
    //----------- MANEJO DEL TECLADO --------------
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        txtDescripcion.resignFirstResponder()
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        if  !keyboardIsShowing {
            self.view.frame.origin.y -= 100
            keyboardIsShowing = true
        }
    }
    
    @objc func keyboardWillHide(sender: NSNotification) {
        if  keyboardIsShowing {
            self.view.frame.origin.y += 100
            keyboardIsShowing = false
        }
    }
    
    //-------------------
    
    func updateDate(){
        let styler = DateFormatter()
        styler.dateFormat = "dd-MM-yyyy"
        let dateString = styler.string(from: date)
        
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
        dateView.isHidden = false;
    }
    
    @IBAction func aceptarDateAction(sender: AnyObject) {
        dateView.isHidden = true;
        date = datePicker.date;
        updateDate();
    }
    
   
    @IBAction func publicarDelito(sender: UIButton) {
        
        //TODO validar si hay texto
        if( txtDescripcion.text.count == 0){
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
        
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x:50, y:10, width:37, height:37)) as UIActivityIndicatorView
        loadingIndicator.center = self.view.center;
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.setValue(loadingIndicator, forKey: "accessoryView")
        loadingIndicator.startAnimating()
        
        alert.show();
        
        
        //---------- PROCESO ASINCRONO ---------------
        DispatchQueue.main.async(execute:
        {
            
            let controller:Controller = Controller();
            let netRes = controller.reporteDelito(delito: delitoReporteTO);
            
            //Hilo principal
            DispatchQueue.global().sync(execute: {
            
                alert.dismiss(withClickedButtonIndex: -1, animated: true)
                let delito:DelitoTO = DelitoTO(dataString: netRes.data!);
                
                self.delitoSeleccionado2Show = controller.getDelitoDetails(numDelito: "\(delito.id_num_delito!)", idDelito: "\(delito.id_evento!)");
                //Regresa al home usuando el hilo principal
               
                self.view.makeToast(message: "Su reporte ha sido almacenado correctamente");
                self.performSegue(withIdentifier: "reportarDelito2Home", sender: self)
                
            })
        });//Termina proceso

    }//Termina método
    
    
    func publicarDelitoHandler(netRes:NetResponse){
        //print("NetResResponse code: \(netRes.code)");
        
        let delito:DelitoTO = DelitoTO(dataString: netRes.data!);
        
        let controller:Controller = Controller();
        self.delitoSeleccionado2Show = controller.getDelitoDetails(numDelito: "\(delito.id_num_delito)", idDelito: "\(delito.id_evento)");
        
        //Regresa al home usuando el hilo principal
        DispatchQueue.main.async(execute: {
            self.view.makeToast(message: "Su reporte ha sido almacenado correctamente");
            self.performSegue(withIdentifier: "reportarDelito2Home", sender: self)
            
        });
        
    }
    
    var delitoSeleccionado2Show:DelitoTO?;
   


//--------------------------- SEGUES -----------------------

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //print(segue.identifier);
        if(segue.identifier == "reportarCompeto2SeleccionarFotografias"){
            
        }
        
        if(segue.identifier == "reportarDelito2Home"){
            let destino:ViewController = segue.destination as! ViewController;
            destino.delitoDetalles = delitoSeleccionado2Show!;
        }
    }


}
