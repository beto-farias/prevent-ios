//
//  SegueLeft2Right.swift
//  PrevenT
//
//  Created by Beto Farias on 12/29/15.
//  Copyright © 2015 2 Geeks one Monkey. All rights reserved.
//

import Foundation
import UIKit

class SegueLeft2Right:UIStoryboardSegue{

    override func perform() {
        // Assign the source and destination views to local variables.
        let firstVCView = self.source.view as UIView!
        let secondVCView = self.destination.view as UIView!
        
        // Get the screen width and height.
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        // Specify the initial position of the destination view.
        secondVCView?.frame = CGRect(x:0.0, y:screenHeight, width:screenWidth, height:screenHeight)
        
        // Access the app's key window and insert the destination view above the current (source) one.
        let window = UIApplication.shared.keyWindow
        window?.insertSubview(secondVCView!, aboveSubview: firstVCView!)
        
        // Animate the transition.
        UIView.animate(withDuration: 0.4, animations: { () -> Void in
            
            print("Cometnad asdf");
            //firstVCView?.frame = CGRect.offsetBy(firstVCView?.frame, 0.0, -screenHeight)
            //secondVCView?.frame = CGRect.offsetBy(secondVCView?.frame, 0.0, -screenHeight)
            
            }) { (Finished) -> Void in
                self.source.present(self.destination as UIViewController,
                    animated: false,
                    completion: nil)
        }
        
    }

}
