//
//  NetResponse.swift
//  PrevenT
//
//  Created by Beto Farias on 11/6/15.
//  Copyright © 2015 2 Geeks one Monkey. All rights reserved.
//

import Foundation

class NetResponse{
    
    var id: Int?
    var message:String?
    var code: Int?
    var token:String?
    var data:String?
    
    
    convenience init(dataString:String){
        do{
            let myDictionary: NSDictionary = try NSJSONSerialization.JSONObjectWithData(dataString.dataUsingEncoding(NSUTF8StringEncoding)!, options: .AllowFragments) as! NSDictionary
            self.init(data: myDictionary);
        }catch let error{
            print("got an error creating the request: \(error)")
            self.init();
        }
    }
    
    init(){}
    
    init(dataDictionary: Dictionary<String,AnyObject>){
        
        if let id = (dataDictionary["id"]){
            self.id = parseString2Int(id as! String);
        }
        
        if let code = (dataDictionary["code"]){
            self.code = parseString2Int(code as! String);
        }
        
        if let message = (dataDictionary["message"]){
            self.message = (message as! String);
        }
        
        if let token = (dataDictionary["token"]){
            self.token = (token as! String);
        }
        
        if let data = (dataDictionary["data"]){
            self.data = (data as! String);
        }
        
    }
    
    init (data: NSDictionary){
        
        if  let id = data["id"] as? Int {
            self.id = id;
        }
        
        if  let code = data["code"] as? Int {
            self.code = code;
        }
        
        if  let data = data["data"] as? String {
            self.data = data;
        }
        
        if  let token = data["token"] as? String {
            self.token = token;
        }
        
        if let message = (data["message"] as? String){
            self.message = message ;
        }
        
    }
    
    
    /*
    * Parsea la respuesta en un NetResponse
    */
    init(contentData:NSData){
        do{
            let jsonData : AnyObject! = try NSJSONSerialization.JSONObjectWithData(contentData, options: NSJSONReadingOptions());
            
            let jsonDictionary = jsonData as! NSDictionary;
            
            if  let id = jsonDictionary["id"] as? Int {
                self.id = id
            }
            
            if  let code = jsonDictionary["code"] as? Int {
                self.code = code
            }
            
            if  let data = jsonDictionary["data"] as? String {
                self.data = data
            }
            
            if  let token = jsonDictionary["token"] as? String {
                self.token = token
            }
            
        }catch{
            print(error)
        }
    }
    
    
    //Recupera el data como un arreglo de objetos JSon
    func getDataJsonArray()->Array<NSDictionary>{
        do{
            let data:NSData = self.data!.dataUsingEncoding(NSUTF8StringEncoding)!
            let jsonData : AnyObject! = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions());
            
            //Transforma la salida a un arreglo
            if let jsonArray = jsonData as? Array<NSDictionary>  {
                return jsonArray;
            }
            
        }catch{
            print(error)
        }
        
        return []; //arreglo vacio
    }
    
    func toString()->String{
        return "id : \(id) code: \(code) message: \(message) token: \(token) data: \(data)"
    }
    
    func getInt(key:String, data: NSDictionary)->Int{
        //print(key);
        if((data[key]) != nil){
            if let _ = data[key] as? String{
                return parseString2Int(data[key] as! String)
            }
        }
        return -1;
    }
    
    func parseString2Int(data:String)-> Int{
        return Int(data)!;
    }
}
