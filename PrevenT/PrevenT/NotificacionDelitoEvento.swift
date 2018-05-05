//
//  NotificacionDelitoEvento.swift
//  PrevenT
//
//  Created by Beto Farias on 1/14/16.
//  Copyright © 2016 2 Geeks one Monkey. All rights reserved.
//

import Foundation

class NotificacionDelitoEvento{

    var id_evento:Int = -1;
    var id_num_delito:Int = -1;
    var id_tipo_delito = -1;
    var id_usuario = -1;

    init(){} //Constructor vacio
    
    convenience init(dataString:String){
        do{
            print("NotificacionDelitoEvento \(dataString)");
            let myDictionary: NSDictionary = try NSJSONSerialization.JSONObjectWithData(dataString.dataUsingEncoding(NSUTF8StringEncoding)!, options: .AllowFragments) as! NSDictionary
            self.init(data: myDictionary);
        }catch let error{
            print("got an error creating the request: \(error)")
            self.init();
        }
    }
    
    init (data: NSDictionary){
        
        self.id_num_delito      = parseString2Int(data["id_num_delito"] as! String);
        self.id_evento          = parseString2Int(data["id_evento"] as! String);
        self.id_tipo_delito     = parseString2Int(data["id_tipo_delito"] as! String);
        self.id_usuario         = parseString2Int(data["id_usuario"] as! String);
        self.id_usuario         = parseString2Int(data["id_usuario"] as! String);
    }
    
    func toString(){
        print("id_num_delito \(self.id_num_delito)");
        print("id_evento \(self.id_evento)");
        print("id_tipo_delito \(self.id_tipo_delito)");
        print("id_usuario \(self.id_usuario)");
    }
    
    
    func parseString2Int(data:String)-> Int{
        return Int(data)!;
    }
    func parseString2Int64(data:String)-> Int64{
        return Int64(data)!;
    }
    
    func parseString2Double(data:String)-> Double{
        return Double(data)!;
    }
    
    

}
