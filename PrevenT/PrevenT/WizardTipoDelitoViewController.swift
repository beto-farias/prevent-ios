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
        Controller.getDelitoStrByType(1),
        Controller.getDelitoStrByType(2),
       // Controller.getDelitoStrByType(3),
        Controller.getDelitoStrByType(4),
        Controller.getDelitoStrByType(5),
        Controller.getDelitoStrByType(6),
        Controller.getDelitoStrByType(7),
        Controller.getDelitoStrByType(8),
       // Controller.getDelitoStrByType(9),
        Controller.getDelitoStrByType(10),
        Controller.getDelitoStrByType(11),
        Controller.getDelitoStrByType(12)
    ]
    
    let delitosImageList = [
        Controller.getDelitoIco(1),
        Controller.getDelitoIco(2),
        //Controller.getDelitoIco(3),
        Controller.getDelitoIco(4),
        Controller.getDelitoIco(5),
        Controller.getDelitoIco(6),
        Controller.getDelitoIco(7),
        Controller.getDelitoIco(8),
        //Controller.getDelitoIco(9),
        Controller.getDelitoIco(10),
        Controller.getDelitoIco(11),
        Controller.getDelitoIco(12)
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
    
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.delitosList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("delitoCellSelector", forIndexPath: indexPath) as! DelitoSeleccionCollectionViewCell
        cell.text.text = delitosList[indexPath.row]
        cell.image.image = delitosImageList[indexPath.row]
        
        return cell
    }
    
    //boton de seleccionar un delito
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //Index path seleccionado
        //print("Elemento seleccionado \(indexPath.row)")
        
        delitoReporteTO.id_tipo_delito = idDelitosList[indexPath.row]
        delitoReporteTO.id_num_delito = 1
        
        let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("WizardReportarBase")
        self.showViewController(vc as! UIViewController, sender: vc)
    }


}