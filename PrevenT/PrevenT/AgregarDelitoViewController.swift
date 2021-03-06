//
//  AgregarDelitoViewController.swift
//  PrevenT
//
//  Created by Beto Farias on 11/23/15.
//  Copyright © 2015 2 Geeks one Monkey. All rights reserved.
//

import UIKit
import Spring

class AgregarDelitoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{

    @IBOutlet var collectionViewDelitos: UICollectionView!
    @IBOutlet var collectionViewDelitoDetails: UICollectionView!
    @IBOutlet var viewReporte: UIView!
  
    @IBOutlet var txtDetalles: UITextView!
    @IBOutlet var txtWizardTitle: UILabel!
    
    //Etapas del view
    @IBOutlet var reportarDelitoViewSelectMap: DesignableView!
    
    
    //Boton de Ok en el marcador que permite comenzar con el flujo
    @IBAction func ubicacionSeleccionadaDidTouch(sender: AnyObject) {
        
        // ALF -- Aqui debemos de escribir las coordenadas en una variable y pasar a seleccionar el tipo de delito
        
        //Mover ventana de Reporte hacia arriba
        //Guardar Coordenadas
        //Prender ventana de seleccion de delito
    }
    
    
    //ALF -- Agrege variables para cada pantalla para poder ocultarlas
    @IBOutlet weak var reportarDelitoView: DesignableView!
    @IBOutlet weak var addVictimsView: DesignableView!
    @IBOutlet weak var addCriminalsView: DesignableView!
    @IBOutlet weak var pickDateView: UIView!
    
    var estadoWizard : Int = 0
    var delitoReporte : DelitoTO = DelitoTO() //Delito paa guardar los datos seleccionados
    
    let delitosList = ["Homicidio","Cibernetico","Extorción", "Desapariciones", "Robo", "Enfrentamientos","Sexual","Mercado Negro","Secuestro", "Movimientos Sociales"]
    let delitosImageList = [Controller.getDelitoIco(tipo: 1),Controller.getDelitoIco(tipo: 9),Controller.getDelitoIco(tipo: 6),Controller.getDelitoIco(tipo: 3),Controller.getDelitoIco(tipo: 4),Controller.getDelitoIco(tipo: 8),Controller.getDelitoIco(tipo: 5),Controller.getDelitoIco(tipo: 7),Controller.getDelitoIco(tipo: 1),Controller.getDelitoIco(tipo: 10)]
    
    
    let subDelitosHomicidioList = ["a","b","c"]
  
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        
        reportarDelitoViewSelectMap.isHidden = true;
        
        NotificationCenter.default.addObserver(self, selector: Selector("keyboardWillShow:"), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        NotificationCenter.default.addObserver(self, selector: Selector("keyboardWillHide:"), name:NSNotification.Name.UIKeyboardWillHide, object: nil);

        
        hidePanels()
        
        // ALF -- Le damos un padding interno a la caja de captura
        txtDetalles.textContainerInset = UIEdgeInsetsMake(20, 20, 20, 20);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch(estadoWizard){
        case 1:
            return self.subDelitosHomicidioList.count
        default:
            return self.delitosList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "delitoCellSelector", for: indexPath) as! DelitoSeleccionCollectionViewCell
        cell.text.text = delitosList[indexPath.row]
        cell.image.image = delitosImageList[indexPath.row]
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //Index path seleccionado
        //print("Elemento seleccionado \(indexPath.row)")
        
        
        
        //ALF -- no creo debamos usar un wizard pues el reporte no es paso a paso y el cliente cambio la dinamica.
        
        switch(estadoWizard ){
        case 0:
            delitoSeleccionadoAction(index: indexPath.row)
            break
        case 1:
            subDelitoSeleccionadoAction(index: indexPath.row)
            break
        default:
            print ("Default collection view")
        }
        
        nextAction()
    }
    
    func nextAction(){
        estadoWizard += 1
        updateGUIWizard()
    }
    
    
    
    @IBAction func prevAction(sender: AnyObject) {
        regresarPasoPrevio()
    }
    
    func regresarPasoPrevio(){
        estadoWizard -= 1
        if(estadoWizard < 0){
           estadoWizard = 0
        }
        updateGUIWizard()
    }
    
    func hidePanels(){
        collectionViewDelitos.isHidden = true;
        viewReporte.isHidden = true
        addCriminalsView.isHidden = true
        addVictimsView.isHidden   = true
        collectionViewDelitoDetails.isHidden = true
        pickDateView.isHidden = true
    }
    
    func updateGUIWizard(){
        
        hidePanels()
    
        switch(estadoWizard){
        case 0:
            txtWizardTitle.text = "Tipo de delito"
            collectionViewDelitos.isHidden = false
            break
        case 1:
            txtWizardTitle.text = "Subtipo de delito"
            hidePanels()
            break
        case 2:
            txtWizardTitle.text = "Relato del delito"
            hidePanels()
            viewReporte.isHidden = false
            break
        case 3:
            txtWizardTitle.text = "Agregar Fotos"
            hidePanels()
            viewReporte.isHidden = false
            break
        case 4:
            txtWizardTitle.text = "Cuanto criminales"
            hidePanels()
            addCriminalsView.isHidden = false
            break
        case 5:
            txtWizardTitle.text = "Cuantas Victimas"
            hidePanels()
            addVictimsView.isHidden = false
            break
        case 5:
            txtWizardTitle.text = "Cambiar Fecha"
            hidePanels()
            pickDateView.isHidden = false
            break
            
        default:
            print("Case default prevAction")
            break;
        }
        
        
        
        collectionViewDelitos.reloadData()
    }
    
    func delitoSeleccionadoAction(index:Int){
    
        switch(index){
        case 1:
            delitoReporte.id_tipo_delito = Constantes.TIPO_DELITO_HOMICIDIO;
            break;
        case 2:
            delitoReporte.id_tipo_delito = 1;
            break;
        case 3:
            delitoReporte.id_tipo_delito = 1;
            break;
        case 4:
            delitoReporte.id_tipo_delito = 1;
            break;
        case 5:
            delitoReporte.id_tipo_delito = 1;
            break;
        case 6:
            delitoReporte.id_tipo_delito = 1;
            break;
        case 7:
            delitoReporte.id_tipo_delito = 1;
            break;
        case 8:
            delitoReporte.id_tipo_delito = 1;
            break;
        case 9:
            delitoReporte.id_tipo_delito = 1;
            break;
        case 10:
            delitoReporte.id_tipo_delito = 1;
            break;
        default:
            print ("Default delitoSeleccionadoAction")
            break
        }
    }
    
    func subDelitoSeleccionadoAction(index:Int){
        delitoReporte.id_tipo_sub_delito = index
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      
        txtDetalles.resignFirstResponder()  
    }
    
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y -= 200
    }
    func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y += 200
    }
}
