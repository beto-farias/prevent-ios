//
//  TimeLineController.swift
//  PrevenT
//
//  Created by Beto Farias on 11/6/15.
//  Copyright © 2015 2 Geeks one Monkey. All rights reserved.
//

import Foundation
import UIKit

class TimeLineController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var data:[DelitoTO] = []
    let cont = Controller();
    
    var delitoSeleccionado2Show:DelitoTO?;
    
    //Tabla con scroll
    @IBOutlet var timeLineTableView: UITableView!
    
    override func viewDidLoad() {
        timeLineTableView.delegate = self;
        timeLineTableView.dataSource = self;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
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
        DispatchQueue.main.async(execute: {
            
            let controller = Controller();
            //Carga los primeros delitos a partir del 0
            self.data = controller.getDelitosTimeLine(index: 0);
            
            //Hilo principal
           // DispatchQueue.main.sync(execute:  {
                alert.dismiss(withClickedButtonIndex: -1, animated: true)
                //print("TimeLineController \(self.data.count)");
                self.timeLineTableView.reloadData();
                if(self.data.count == 0){
                    self.view.makeToast(message: "No se encontraron eventos para mostrar, verifique su conexión a internet");
                }
           // });
            
        });//Cieera proceso asincrono
    }
    
    
   //------------------- INTERFACE DE LA TABLA ----------------------------
    
    
    //Cantidad de renglones
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        let count = data.count;
        return count;
    }
    
    
    //Recupera un renglon
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TimeLineTableViewCell = tableView.dequeueReusableCell(withIdentifier: "timeLineCell", for: indexPath) as! TimeLineTableViewCell
        
        //Obtiene el delito del arreglo
        let delito = data[indexPath.item];
        
        //Busca el icono
        let icoStr = Controller.getDelitoIcoName(tipo: delito.id_tipo_delito);
        let ico = UIImage(named: icoStr);
        
        //Busca el nombre del delito
        let delitoStr = Controller.getDelitoStrByType(tipo: delito.id_tipo_delito);
        
        //Arma la celda
        cell.imgIco.image = ico;
        cell.txtTitulo.text = delitoStr;
        cell.txtDireccion.text = delito.txt_direccion;
        cell.txtFecha.text="\(StringUtils.getNumberOfDays(time: delito.fch_delito))";
        cell.txtNumLikes.text = "\(delito.num_likes!)";
        
        //print("Row \(indexPath.row) \(data.count)")
        
        let row = indexPath.row;
        
        if( row+1 == data.count ){
            //print("LastRow \(data.count)")
            getMoreData(row: data.count);
        }
        
        return cell;
    }
    
    
    // Seleccion del renglon
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //CODE TO BE RUN ON CELL TOUCH
        print("Renglon seleccionado \(indexPath.item)");
        
        let delito:DelitoTO = data[indexPath.row];
        
        let controller:Controller = Controller();
        delitoSeleccionado2Show = controller.getDelitoDetails(numDelito:"\(delito.id_num_delito!)", idDelito: "\(delito.id_evento!)");
        performSegue(withIdentifier: "timeLine2Home", sender: tableView)
    }
    
    //--------------------------- SEGUES -----------------------
    
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //print(segue.identifier);
        let destino:ViewController = segue.destination as! ViewController;
        destino.delitoDetalles = delitoSeleccionado2Show!;
    }
    
    
    //-------------------------- FUNCIONES --------------------
    
    var indexLikeSelected: Int = -1;
    
    @IBAction func likeAction(sender: UIButton) {
        let controller:Controller = Controller();
        
        let buttonPosition = sender.convert(CGPoint.zero, to: self.timeLineTableView)
        let indexPath = self.timeLineTableView.indexPathForRow(at: buttonPosition)
        if indexPath != nil {
            //print("Indexpath: \(indexPath?.row)");
            indexLikeSelected = indexPath!.row;
            let delito:DelitoTO = data[(indexPath!.row)];
            let res = controller.addPoint(idEvento: delito.id_evento!,numDelito: delito.id_num_delito!,vhNetResponse: likeActionCallback);
            if(res == -1){
                //Mostar toast de que no está logeado el usuario
                //print("El suaurio no esta logeado");
                self.view.makeToast(message: "Debe estar registrado para poder dar like");
            }
        }
    }
    
    
    //Agrega likes a los delitos
    func likeActionCallback(netRes:NetResponse){
        //print("likecallback");
        
        //Mensaje a mostar en el toast
        var message:String = ""
        
        switch(netRes.code!){
        case 1:
            let delito:DelitoTO = data[indexLikeSelected];
            delito.num_likes = delito.num_likes + 1;
            DispatchQueue.main.async(execute:  {
                // code here
                self.timeLineTableView.reloadData();
                self.timeLineTableView.setNeedsDisplay();
            });
            //print("Se ha registrado su like correctamente");
            message = "Se ha registrado su like correctamente"
            
            break;
        case 0:
            //print("No puede dar like al a sus reportes");
            message = "No puede dar like al a sus reportes"
            break;
        case -1:
            //print("Ha ocurrido un error, intentelo más tarde");
            message = "Ha ocurrido un error, intentelo más tarde"
            break;
        case -2:
            //print("Ya ha dado like a este reporte");
            message = "Ya ha dado like a este reporte"
            break;
        default:
            break;
        }
        
        DispatchQueue.main.sync { [unowned self] in
            self.view.makeToast(message: message);
       }
    }
    
    
    // Recuepera más datos para mostrar
    func getMoreData(row: Int){
        let controller : Controller = Controller();
        let newRows: [DelitoTO] = controller.getDelitosTimeLine(index: row);
        
        //print("Traer rows desde \(row)");
        
        //print("new size \(newRows.count))");
        
        if(newRows.count > 0){
            data += newRows;
            self.timeLineTableView.reloadData();
        }
    }
}

