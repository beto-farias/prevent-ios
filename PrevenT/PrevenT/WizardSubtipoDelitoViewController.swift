//
//  WizardSubtipoDelitoViewController.swift
//  PrevenT
//
//  Created by Beto Farias on 12/27/15.
//  Copyright © 2015 2 Geeks one Monkey. All rights reserved.
//

import UIKit

class WizardSubtipoDelitoViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var collectionView: UICollectionView!
    

    var subDelitosHomicidioList = ["a","b","c"]
    var iconImage:UIImage?;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Selecciona los subdelitos correspondientes
        
        subDelitosHomicidioList = Controller.getSubDelitosById(idTipoDelito: (delitoReporteTO.id_tipo_delito)!)
        iconImage = Controller.getDelitoIco( tipo: delitoReporteTO.id_tipo_delito )
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
        return self.subDelitosHomicidioList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "delitoCellSelector", for: indexPath) as! DelitoSeleccionCollectionViewCell
        cell.text.text = subDelitosHomicidioList[indexPath.row]
        //cell.image.image = delitosImageList[indexPath.row]
        cell.image.image = iconImage
        
        return cell
    }
    
   
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //Index path seleccionado
        print("Elemento seleccionado \(indexPath.row)")
        
        let vc : AnyObject! = self.storyboard!.instantiateViewController(withIdentifier: "WizardReportarCompleto")
        self.show(vc as! UIViewController, sender: vc)
    }

}
