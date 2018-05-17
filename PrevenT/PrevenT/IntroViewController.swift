//
//  IntroViewController.swift
//  PrevenT
//
//  Created by Beto Farias on 1/31/16.
//  Copyright © 2016 2 Geeks one Monkey. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController, UIScrollViewDelegate {
    
    
    @IBOutlet var scroll: UIScrollView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var btnFinish: UIButton!
    @IBOutlet var imagen: UIImageView!
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        self.scroll.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height)
        let scrollViewWidth:CGFloat = self.scroll.frame.width
        let scrollViewHeight:CGFloat = self.scroll.frame.height
        
        
        let imgOne = UIImageView(frame: CGRect(x:0, y:0,width:scrollViewWidth, height:scrollViewHeight))
        imgOne.image = UIImage(named: "Slide 1")
        let imgTwo = UIImageView(frame: CGRect(x:scrollViewWidth, y:0,width:scrollViewWidth, height:scrollViewHeight))
        imgTwo.image = UIImage(named: "Slide 2")
        let imgThree = UIImageView(frame: CGRect(x:scrollViewWidth*2, y:0,width:scrollViewWidth, height:scrollViewHeight))
        imgThree.image = UIImage(named: "Slide 3")
        let imgFour = UIImageView(frame: CGRect(x:scrollViewWidth*3, y:0,width:scrollViewWidth, height:scrollViewHeight))
        imgFour.image = UIImage(named: "Slide 4")
        
        self.scroll.addSubview(imgOne)
        self.scroll.addSubview(imgTwo)
        self.scroll.addSubview(imgThree)
        self.scroll.addSubview(imgFour)
        
        self.scroll.contentSize = CGSize(width:self.scroll.frame.width * 4, height:self.scroll.frame.height)
        self.scroll.delegate = self
        self.pageControl.currentPage = 0
        
        //Oculta la barra de navegación
        self.navigationController?.isNavigationBarHidden = true;
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.btnFinish.isHidden = true;
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
    
    
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        
        self.btnFinish.isHidden = true;

        
        // Test the offset and calculate the current page after scrolling ends
        let pageWidth:CGFloat = scrollView.frame.width
        
        let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1
        // Change the indicator
        self.pageControl.currentPage = Int(currentPage);
        
        // Change the text accordingly
        if Int(currentPage) == 0{
            imagen.image = UIImage(named: "slide1");
        }else if Int(currentPage) == 1{
            imagen.image = UIImage(named: "slide2");
        }else if Int(currentPage) == 2{
            imagen.image = UIImage(named: "slide3");
        }else{
            imagen.image = UIImage(named: "slide4");
            // Show the "Let's Start" button in the last slide (with a fade in animation)
            UIView.animate(withDuration: 1.0, animations: { () -> Void in
                self.btnFinish.isHidden = false;
            })
        }
    }

}
