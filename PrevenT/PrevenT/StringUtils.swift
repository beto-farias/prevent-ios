//
//  StringUtils.swift
//  PrevenT
//
//  Created by Beto Farias on 11/17/15.
//  Copyright © 2015 2 Geeks one Monkey. All rights reserved.
//

import Foundation

class StringUtils {
    
    static func  convertStringToDictionary(text: String) -> [String:String]? {
        if let data = text.data(using: String.Encoding.utf8) {
            do{
                let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String:String]
                return json
            }catch let error {
                print(error)
                return nil;
            }
        }
        return nil
    }
    
    static func getDistance(distance:Double)->String{
        if(distance/1000 >= 1.0){
            
            return "\(Double(distance/1000).rounded(toPlaces: 2)) km";
            //return "\(Double(distance/1000)) km";
        }else{
            
            return "\(Double(distance).rounded(toPlaces: 2)) m";
            //return "\(Double(distance)) m";
        }
    
    }
    
    static func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    
    static func long2Date(time:Double)-> NSDate{
        let date = NSDate(timeIntervalSince1970: time);
        return date;
    }
    
    static func getNumberOfDays(time:Int)->String{
        
        let nowDouble = NSDate().timeIntervalSince1970
        
        let currentTime = Int64(nowDouble);
        
        let elapsedTime = currentTime - Int64(time);
        let numberDays = elapsedTime / (60 * 60 * 24);
        
        //print("elapsedTime \(elapsedTime)");
        //print("Dias \(numberDays)");
        
        let numberOfDays = Int(numberDays);
        
        //print("Dias \(numberOfDays)");
        
        if(numberOfDays < 0){
            return "Dentro de \(abs(numberOfDays)) días";
        }
        
        switch(numberOfDays){
        case 0:
            return "Hoy";
        case 1:
            return "Ayer"
        case 2,3,4,5,6,7:
            return "En esta semana";
        default:
            return "Hace \(numberOfDays) días";

        }
    }
    
    
   
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

//extension Double {
//    /// Rounds the double to decimal places value
//    func roundToPlaces(places:Int) -> Double {
//        let divisor = pow(10.0, Double(places))
//        return round(self * divisor) / divisor
//    }
//}

