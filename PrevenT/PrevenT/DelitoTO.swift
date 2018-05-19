//
//  DelitoTO.swift
//  PrevenT
//
//  Created by Beto Farias on 11/6/15.
//  Copyright © 2015 2 Geeks one Monkey. All rights reserved.
//

import Foundation
import UIKit

public class DelitoTO{
    
    
    var id_num_delito: Int!;
    var id_evento: Int!;
    var id_tipo_delito: Int!;
    var id_tipo_sub_delito: Int!
    var txt_resumen: String = "";
    var fch_delito: Int!;
    var txt_fch_delito:String = "";
    var num_victimas: Int = 0;
    var num_delincuentes : Int = 0;
    var num_likes: Int!;
    var b_confirmado: Bool!;
    var num_latitud: Double!;
    var num_longitud: Double! ;
    var txt_descripcion_lugar: String!
    
    var txt_direccion:String!;
    
    var multimedia:[MultimediaTO] = [];
    var direccion:DireccionTO = DireccionTO();
    var logoImages: [UIImage] = [];
    
    
    
    init(){} //Constructor vacio
    
    convenience init(dataString:String){
        do{
            let myDictionary: NSDictionary = try JSONSerialization.jsonObject(with: dataString.data(using: String.Encoding.utf8)!, options: .allowFragments) as! NSDictionary
            self.init(data: myDictionary);
        }catch let error{
            print("got an error creating the request: \(error)")
            self.init();
        }
    }
    
    init (data: NSDictionary){
        self.id_num_delito      = parseString2Int(data: data["id_num_delito"] as! String);
        self.id_evento          = parseString2Int(data: data["id_evento"] as! String);
        self.id_tipo_delito     = parseString2Int(data: data["id_tipo_delito"] as! String);
        self.num_latitud        = parseString2Double(data: data["num_latitud"] as! String);
        self.num_longitud       = parseString2Double(data: data["num_longitud"] as! String);
        
        if((data["txt_resumen"]) != nil){
            self.txt_resumen        = (data["txt_resumen"] as? String)!
        }
        if((data["num_delincuentes"]) != nil){
            self.num_delincuentes   = parseString2Int(data: data["num_delincuentes"] as! String);
        }
        if((data["num_victimas"]) != nil){
            self.num_victimas       = parseString2Int(data: data["num_victimas"] as! String);
        }
        if((data["num_likes"]) != nil){
            self.num_likes          = parseString2Int(data: data["num_likes"] as! String);
        }
        if((data["fch_delito"]) != nil){
            self.fch_delito         = (data["fch_delito"] as! Int );
        }
        if((data["txt_descripcion_lugar"]) != nil){
            self.txt_descripcion_lugar = data["txt_descripcion_lugar"] as? String;
        }
        if((data["txt_direccion"]) != nil){
            self.txt_direccion = data["txt_direccion"] as? String;
        }
        
        
        
        if let _ = data["multimedia"]{
            let dataArray:NSArray = data["multimedia"] as! NSArray
            //print("Multimedia size:\(dataArray.count)");
            
            for item in dataArray { // loop through data items
                let obj = item as! NSDictionary
                let mto:MultimediaTO = MultimediaTO();
                mto.id_tipo_multimedia = parseString2Int(data: obj["id_tipo_multimedia"] as! String);
                mto.txt_archivo = obj["txt_archivo"] as! String;
                multimedia.append(mto);
            }
        }
        
        
        //toString();
    }
    
    func toString(){
        print("id_num_delito \(self.id_num_delito)");
        print("id_evento \(self.id_evento)");
        
        print("num_latitud \(self.num_latitud)");
        print("num_longitud \(self.num_longitud)");
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
