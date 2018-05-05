//
//  LeftDrawerViewController.swift
//  PrevenT
//
//  Created by Beto Farias on 11/6/15.
//  Copyright © 2015 2 Geeks one Monkey. All rights reserved.
//

import UIKit

class LeftDrawerViewController: UIViewController, UITableViewDataSource,UITableViewDelegate {
    
    
    var data:[LeftDrawerItem] = [];
    
    @IBOutlet weak var tblListaItems: UITableView!
    @IBOutlet weak var txtNombreUsuario: UILabel!
    
    //Variable para controlar los delitos maximos seleccionados
    var cantidadDelitosSeleccionados:Int = 0;
    


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initLeftDrawerItems();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        updateUserNameGUI();
    }
    
    
    func updateUserNameGUI(){
        let controller: Controller = Controller();
        let userName = controller.getUserName();
        txtNombreUsuario.text =  userName;
    }
    
    
    func initLeftDrawerItems(){
        let  controller:Controller = Controller();
        
        data = [
            getLeftDrawerDelitoItem(LeftDrawerItem.MENU_CHECK_ROBO, tipoDelito: Constantes.TIPO_DELITO_ROBO),
            getLeftDrawerDelitoItem(LeftDrawerItem.MENU_CHECK_HOMICIDIO, tipoDelito: Constantes.TIPO_DELITO_HOMICIDIO),
            getLeftDrawerDelitoItem(LeftDrawerItem.MENU_CHECK_SEXUAL, tipoDelito: Constantes.TIPO_DELITO_SEXUAL),
            getLeftDrawerDelitoItem(LeftDrawerItem.MENU_CHECK_ENFRENTAMIENTOS, tipoDelito: Constantes.TIPO_DELITO_ENFRENTAMIENTOS),
            getLeftDrawerDelitoItem(LeftDrawerItem.MENU_CHECK_EXTORCION, tipoDelito: Constantes.TIPO_DELITO_EXTORCION),
            getLeftDrawerDelitoItem(LeftDrawerItem.MENU_CHECK_PREVENCION, tipoDelito: Constantes.TIPO_DELITO_PREVENCION),
            getLeftDrawerDelitoItem(LeftDrawerItem.MENU_CHECK_SECUESTRO, tipoDelito: Constantes.TIPO_DELITO_SECUESTRO),
            getLeftDrawerDelitoItem(LeftDrawerItem.MENU_CHECK_SOCIALES, tipoDelito: Constantes.TIPO_DELITO_SOCIALES),
            //getLeftDrawerDelitoItem(LeftDrawerItem.MENU_CHECK_MOVIMIENTOS_SOCIALES, tipoDelito: Constantes.TIPO_DELITO_MOVIMIENTOS_SOCIALES),
            getLeftDrawerDelitoItem(LeftDrawerItem.MENU_CHECK_MERCADO_NEGRO, tipoDelito: Constantes.TIPO_DELITO_MERCADO_NEGRO),
            
            
            //getLeftDrawerDelitoItem(LeftDrawerItem.MENU_CHECK_CIBERNETICO, tipoDelito: Constantes.TIPO_DELITO_CIBERNETICOS),
            //getLeftDrawerDelitoItem(LeftDrawerItem.MENU_CHECK_DESAPARICONES, tipoDelito: Constantes.TIPO_DELITO_DESAPARICIONES),
        ];
        
        
        
        
        if(controller.isUsuaioLogeado()){
            let item = LeftDrawerItem(type: LeftDrawerItem.MENU_LOGOUT,   hasSelectableItem: false, title: "Cerrar sesión");
            data.append(item);
        }else{
            let item = LeftDrawerItem(type: LeftDrawerItem.MENU_LOGIN,   hasSelectableItem: false, title: "Iniciar sesión");
            data.insert(item, atIndex: 0);
        }
        
        
        
        let item = LeftDrawerItem(type: LeftDrawerItem.MENU_HELP,   hasSelectableItem: false, title: "Ayuda");
        data.append(item);
    }
    
    
    func getLeftDrawerDelitoItem(type:Int, tipoDelito:Int) -> LeftDrawerItem{
        let  controller:Controller = Controller();
        let delitoNombre:String = Controller.getDelitoStrByType(tipoDelito);
        let isSelected:Bool = controller.isDelitoSelected(tipoDelito);
        let delitoIcon:UIImage = Controller.getDelitoIco(tipoDelito);
        
        //Cuenta la cantidad de delitos seleccionados
        if(isSelected){
            cantidadDelitosSeleccionados += 1;
        }
        
        return LeftDrawerItem(type: type,   hasSelectableItem: true,  title: delitoNombre,   selected: isSelected, icon: delitoIcon);
    }
    
    
    //------------------ INTERFACE DE TABLEVIEW ----------------------
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return data.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        //let cell:UITableViewCell = UITableViewCell()
        let cell:LeftDrawerTableViewCell   = tableView.dequeueReusableCellWithIdentifier("leftRowCell", forIndexPath: indexPath) as! LeftDrawerTableViewCell
        
        let item:LeftDrawerItem = data[indexPath.row];
        
        //print(item.title);
        
        cell.txtMenuOpcion.text =  item.title;
        cell.sideMenuItemIcon.image = item.icon;
        if(item.hasSelectableItem){
            cell.imgCheck.hidden = false;
            
            if(item.selected){
                cell.imgCheck.image = UIImage(named: "checkBox_checked");
            }else{
                cell.imgCheck.image = UIImage(named: "checkBox_notChecked");
            }
        }else{
            cell.imgCheck.hidden = true;
        }
        
        return cell;
    }
    
    
    //Seleccion de una celda
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //print("Renglon seleccionado \(indexPath.item)");
        let controller : Controller  = Controller();
        
        let item:LeftDrawerItem = data[indexPath.row];
        
        switch(item.type){
        case LeftDrawerItem.MENU_LOGIN:
            let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController")
            self.showViewController(vc as! UIViewController, sender: vc)
            break;
        case LeftDrawerItem.MENU_HELP:
            controller.forceShowHelp();
            navigationController?.popViewControllerAnimated(true);
            break;
        case LeftDrawerItem.MENU_LOGOUT:
            
            controller.logoutUser()
            initLeftDrawerItems()
            updateUserNameGUI()
            navigationController?.popToRootViewControllerAnimated(true)
            break;
        case LeftDrawerItem.MENU_CHECK_HOMICIDIO:
            delitoClicked(item, idDelito: Constantes.TIPO_DELITO_HOMICIDIO);
            break;
        case LeftDrawerItem.MENU_CHECK_DESAPARICONES:
            delitoClicked(item, idDelito: Constantes.TIPO_DELITO_DESAPARICIONES);
            break;
        case LeftDrawerItem.MENU_CHECK_SECUESTRO:
            delitoClicked(item, idDelito: Constantes.TIPO_DELITO_SECUESTRO);
            break;
        case LeftDrawerItem.MENU_CHECK_MOVIMIENTOS_SOCIALES:
            delitoClicked(item, idDelito: Constantes.TIPO_DELITO_MOVIMIENTOS_SOCIALES);
            break;
        case LeftDrawerItem.MENU_CHECK_CIBERNETICO:
            delitoClicked(item, idDelito: Constantes.TIPO_DELITO_CIBERNETICOS);
            break;
        case LeftDrawerItem.MENU_CHECK_ENFRENTAMIENTOS:
            delitoClicked(item, idDelito: Constantes.TIPO_DELITO_ENFRENTAMIENTOS);
            break;
        case LeftDrawerItem.MENU_CHECK_EXTORCION:
            delitoClicked(item, idDelito: Constantes.TIPO_DELITO_EXTORCION);
            break;
        case LeftDrawerItem.MENU_CHECK_MERCADO_NEGRO:
            delitoClicked(item, idDelito: Constantes.TIPO_DELITO_MERCADO_NEGRO);
            break;
        case LeftDrawerItem.MENU_CHECK_ROBO:
            delitoClicked(item, idDelito: Constantes.TIPO_DELITO_ROBO);
        case LeftDrawerItem.MENU_CHECK_SEXUAL:
            delitoClicked(item, idDelito: Constantes.TIPO_DELITO_SEXUAL);
            break;
        case LeftDrawerItem.MENU_CHECK_SOCIALES:
            delitoClicked(item, idDelito: Constantes.TIPO_DELITO_SOCIALES);
            break;
        case LeftDrawerItem.MENU_CHECK_PREVENCION:
            delitoClicked(item, idDelito: Constantes.TIPO_DELITO_PREVENCION);
            break;
            
        default:
            print(indexPath.row);
        }
        
        
        tblListaItems.reloadData();
    }
    
    
    //------------------ termina implementacion de la tabla -----------------------------
   
    @IBAction func closeLeftDrawer(sender: UIBarButtonItem) {
        //Toggle left bar
        //let appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        //appDelegate.centerContainer?.toggleDrawerSide(MMDrawerSide.Left,animated:true, completion:nil)
    }
    
    
    
    
    
    /* FUncion que se llama al seleccionar algun delito --------------
    */
    func delitoClicked(item: LeftDrawerItem, idDelito: Int){
        let controller:Controller = Controller();
        
        if(item.selected){
            //Deseleccina el delito
            controller.setDelitoSelected(idDelito, estado: false);
            cantidadDelitosSeleccionados -= 1;
            if(cantidadDelitosSeleccionados < 0){
                cantidadDelitosSeleccionados = 0;
            }
            item.selected = false;
        }else{
            //Seleccina el delito
            var puedeAgregar = false;
            
            //Cantidad para usuarios no registrados
            if(cantidadDelitosSeleccionados < Constantes.CANTIDAD_DELITOS_USUARIO_ANONIMO){
                puedeAgregar = true;
            }
            
            //Cantidad para usuarios registrados no pro
            if(controller.getUserId() > 0 && cantidadDelitosSeleccionados < Constantes.CANTIDAD_DELITOS_USUARIO_LOGEADO_NO_PRO){
                puedeAgregar = true;
            }
            
            //Cantidad para usuarios registrados pro
            if(controller.getUserPro() > 0 ){
                puedeAgregar = true;
            }
            if(puedeAgregar){
                controller.setDelitoSelected(idDelito, estado: true);
                cantidadDelitosSeleccionados += 1;
                item.selected = true;
            }else{
                self.view.makeToast(message: "Para agregar más eventos, debe estar registrado o tener una cuenta pro");
            }
        }
        
        //print("cantidadDelitosSeleccionados: \(cantidadDelitosSeleccionados)");
    }
}








