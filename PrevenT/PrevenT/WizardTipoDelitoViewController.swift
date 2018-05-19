//
//  WizardTipoDelitoViewController.swift
//  PrevenT
//
//  Created by Beto Farias on 12/27/15.
//  Copyright © 2015 2 Geeks one Monkey. All rights reserved.
//

import UIKit

class WizardTipoDelitoViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet var collectionView: UICollectionView!
    
    let idDelitosList = [1,2,4,5,6,7,8,10,11,12]
    
    let delitosList:[String] = [
        Controller.getDelitoStrByType(tipo: 1),
        Controller.getDelitoStrByType(tipo: 2),
       // Controller.getDelitoStrByType(3),
        Controller.getDelitoStrByType(tipo: 4),
        Controller.getDelitoStrByType(tipo: 5),
        Controller.getDelitoStrByType(tipo: 6),
        Controller.getDelitoStrByType(tipo: 7),
        Controller.getDelitoStrByType(tipo: 8),
       // Controller.getDelitoStrByType(9),
        Controller.getDelitoStrByType(tipo: 10),
        Controller.getDelitoStrByType(tipo: 11),
        Controller.getDelitoStrByType(tipo: 12)
    ]
    
    let delitosImageList = [
        Controller.getDelitoIco(tipo: 1),
        Controller.getDelitoIco(tipo: 2),
        //Controller.getDelitoIco(3),
        Controller.getDelitoIco(tipo: 4),
        Controller.getDelitoIco(tipo: 5),
        Controller.getDelitoIco(tipo: 6),
        Controller.getDelitoIco(tipo: 7),
        Controller.getDelitoIco(tipo: 8),
        //Controller.getDelitoIco(9),
        Controller.getDelitoIco(tipo: 10),
        Controller.getDelitoIco(tipo: 11),
        Controller.getDelitoIco(tipo: 12)
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        collectionView.delegate = self;
        collectionView.dataSource = self;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.delitosList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "delitoCellSelector", for: indexPath) as! DelitoSeleccionCollectionViewCell
        cell.text.text = delitosList[indexPath.row]
        cell.image.image = delitosImageList[indexPath.row]
        
        return cell
    }
    
    //boton de seleccionar un delito
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        //Index path seleccionado
        print("Elemento seleccionado \(indexPath.row)")
        
        delitoReporteTO.id_tipo_delito = idDelitosList[indexPath.row]
        delitoReporteTO.id_num_delito = 1
        
        let vc : AnyObject! = self.storyboard!.instantiateViewController(withIdentifier: "WizardReportarBase")
        self.show(vc as! UIViewController, sender: vc)
    }
    
    


}
