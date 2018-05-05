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
        
        
        self.scroll.frame = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        let scrollViewWidth:CGFloat = self.scroll.frame.width
        let scrollViewHeight:CGFloat = self.scroll.frame.height
        
        
        let imgOne = UIImageView(frame: CGRectMake(0, 0,scrollViewWidth, scrollViewHeight))
        imgOne.image = UIImage(named: "Slide 1")
        let imgTwo = UIImageView(frame: CGRectMake(scrollViewWidth, 0,scrollViewWidth, scrollViewHeight))
        imgTwo.image = UIImage(named: "Slide 2")
        let imgThree = UIImageView(frame: CGRectMake(scrollViewWidth*2, 0,scrollViewWidth, scrollViewHeight))
        imgThree.image = UIImage(named: "Slide 3")
        let imgFour = UIImageView(frame: CGRectMake(scrollViewWidth*3, 0,scrollViewWidth, scrollViewHeight))
        imgFour.image = UIImage(named: "Slide 4")
        
        self.scroll.addSubview(imgOne)
        self.scroll.addSubview(imgTwo)
        self.scroll.addSubview(imgThree)
        self.scroll.addSubview(imgFour)
        
        self.scroll.contentSize = CGSizeMake(self.scroll.frame.width * 4, self.scroll.frame.height)
        self.scroll.delegate = self
        self.pageControl.currentPage = 0
        
        //Oculta la barra de navegación
        self.navigationController?.navigationBarHidden = true;
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.btnFinish.hidden = true;
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
    
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView){
        
        self.btnFinish.hidden = true;

        
        // Test the offset and calculate the current page after scrolling ends
        let pageWidth:CGFloat = CGRectGetWidth(scrollView.frame)
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
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                self.btnFinish.hidden = false;
            })
        }
    }

}
