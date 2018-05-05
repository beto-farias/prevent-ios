//
//  GalleryViewController.swift
//  PrevenT
//
//  Created by Beto Farias on 12/29/15.
//  Copyright © 2015 2 Geeks one Monkey. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    //Este valor es enviado del home al controlador
    var multimedia:[MultimediaTO] = [];
    var numDelito:Int = 0;
    var idEvento:Int = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //Implementacion del CollectionView
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.multimedia.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("galleryCell", forIndexPath: indexPath) as! GalleryCollectionViewCell
        
        let mto = multimedia[indexPath.row]
        
        var newImgThumb : UIImageView
        newImgThumb = cell.galleryImage
        newImgThumb.contentMode = .ScaleAspectFit
        
        //cell.galleryImage.image = data[indexPath.row]
        
        
        
        let checkedUrl = "\(Controller.END_POINT_BASE)/multimedia/delitos/\(numDelito)\(idEvento)/\(mto.txt_archivo)";
        print(checkedUrl);
            
        cell.galleryImage.downloadedFrom(link: checkedUrl, contentMode: .ScaleAspectFit);
        return cell
    }
}


//http://stackoverflow.com/questions/24231680/loading-image-from-url
extension UIImageView {
    func downloadedFrom(link link:String, contentMode mode: UIViewContentMode) {
        guard
            let url = NSURL(string: link)
            else {return}
        contentMode = mode
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, _, error) -> Void in
            guard
                let data = data where error == nil,
                let image = UIImage(data: data)
                else { return }
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.image = image
            }
        }).resume()
    }
}
