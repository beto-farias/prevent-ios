//
//  PhotoManagerViewController.swift
//  PrevenT
//
//  Created by Beto Farias on 12/27/15.
//  Copyright © 2015 2 Geeks one Monkey. All rights reserved.
//

import UIKit
import Photos

class PhotoManagerViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource,UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    
    @IBOutlet var photoCollectionView: UICollectionView!
    @IBOutlet var txtNoHayImagen: UILabel!
    
    var imagePicker = UIImagePickerController()
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func viewWillAppear(animated: Bool) {
        if( delitoReporteTO.logoImages.count > 0 ){
            txtNoHayImagen.hidden = true;
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //print("Size \(delitoReporteTO.logoImages.count)")
        return delitoReporteTO.logoImages.count;
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("pictureCellSelector", forIndexPath: indexPath) as! PhotoGaleryCollectionViewCell
        
        cell.imgThumnail.image = delitoReporteTO.logoImages[indexPath.row]
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //Index path seleccionado
        //print("Elemento seleccionado \(indexPath.row)")
        
    }

    
    @IBAction func addPictureAction(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            //print("Button capture")
            
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
        
        //print("Image Selected")
        
        delitoReporteTO.logoImages.append(image);
        
        self.photoCollectionView.reloadData()
    }
    
}
