//
//  NetworkUtils.swift
//  PrevenT
//
//  Created by Beto Farias on 11/6/15.
//  Copyright © 2015 2 Geeks one Monkey. All rights reserved.
//

import Foundation
import SwiftHTTP

class NetworkUtils{
    
    
    //"http://dl-8.one2up.com/onetwo/content/2015/6/15/9c3b51249fbbe20ca9d841401e276d97.php"
    
    //Funcion asincrona
    func doGetJsonStringArray(urlString:String)->Array<AnyObject> {
        
        //Descarga el contenido de la url
        if let url = NSURL(string:urlString){ //Valida que la url sea correcta
            //print("NetworkUtils:URL: \(url)");
            
            //Lee los datos
            let contentData = NSData(contentsOfURL:url)
            do{
                if(contentData != nil){
                    let jsonData : AnyObject! = try NSJSONSerialization.JSONObjectWithData(contentData!, options: NSJSONReadingOptions());
                
                    //Transforma la salida a un arreglo
                    if let jsonArray = jsonData as? Array<AnyObject>  {
                        return jsonArray;
                    }
                }
                
            }catch{
                print(error)
                return [String](); //arreglo vacio
            }
        }
        return [String](); //Arreglo vacio
    }
    
    
    
    /**
        Rupera un NSDirectory de internet

    */
    
    func doGetJsonString(urlString:String)->NSDictionary!{
        
        //Descarga el contenido de la url
        if let url = NSURL(string:urlString){ //Valida que la url sea correcta
            print("NetworkUtils:URL: \(url)");
            
           
            //Lee los datos
            let contentData = NSData(contentsOfURL:url);
            
            let datastring = NSString(data: contentData!, encoding: NSUTF8StringEncoding)
            
            print(datastring);
            
            if(datastring == "false"){
                return nil;
            }
            
            //let directory:NSDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(contentData!)! as! NSDictionary
            do{
                let boardsDictionary: NSDictionary = try NSJSONSerialization.JSONObjectWithData(contentData!, options: .AllowFragments) as! NSDictionary
                return boardsDictionary;
            }catch let error{
                 print("got an error creating the request: \(error)")
            }
        }
        
        return nil;
    }
    
    
    
    //Funcion sincrona
    func doGetJsonNetResponse(url:String)->NetResponse?{
        //Descarga el contenido de la url
        if let url = NSURL(string:url){ //Valida que la url sea correcta
            //print("NetworkUtils:URL: \(url)");
            
            //Lee los datos
            let contentData = NSData(contentsOfURL:url)
            if(contentData != nil){
                let netRes = self.parseNetResponse(contentData!);
                return netRes
            }
        }
        return nil; //Arreglo
    }
    
    //Funcion sincrona
    func doGetJsonNSData(url:String)->NSData?{
        //Descarga el contenido de la url
        if let url = NSURL(string:url){ //Valida que la url sea correcta
            //print("NetworkUtils:URL: \(url)");
            
            //Lee los datos
            let contentData = NSData(contentsOfURL:url)
            if( contentData != nil){
                return contentData!;
            }
        }
        
        //print("Content data null");
        return nil; //Arreglo vacio
    }
    
    
    /*
     *
     */
    func doPostJsonSyncParams(url:String, params:[String:String])->NetResponse{
        
        var data:String = "";
        for (key,value) in params{
            data += "\(key)=\(value)&";
        }
        
        print(url);
        print("post data: \(data)");
        
        let netRes:NetResponse = doPostSync(url,postString: data);
        return netRes;
    }
    
    
    
    //Funcion POST SINCRONA
    func doPostSync(url:String, postString:String)->NetResponse{
        
        let HTTPMethod: String = "POST"
        let timeoutInterval: NSTimeInterval = 60
        let HTTPShouldHandleCookies: Bool = false
        
        
        let request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: url)!);
        request.HTTPMethod = HTTPMethod
        request.timeoutInterval = timeoutInterval
        request.HTTPShouldHandleCookies = HTTPShouldHandleCookies
        request.HTTPBody = postString.dataUsingEncoding(NSUTF8StringEncoding)
        
        do{
            let responseData  = try NSURLConnection.sendSynchronousRequest(request,returningResponse: nil)
            let results = NSString(data:responseData, encoding:NSUTF8StringEncoding)!
            print("doPostSync Result: \(results)")
            
            let netRes:NetResponse = NetResponse(dataString: results as String);
            
            return netRes;
        }catch let error{
            print(error);
        }
        
        let netRes:NetResponse = NetResponse()
        netRes.id = -1;
        netRes.code = -1;
        netRes.message = "Error";
        
        return netRes;
    }
    
    //Funcion asincrona
    // https://github.com/daltoniam/SwiftHTTP
    func doPostJsonAsync(url:String, params:[String:String], handler:(NetResponse) -> Void){
        do {
            let opt = try HTTP.POST(url, parameters: params)
            opt.start { response in
                if let err = response.error {
                    print("error: \(err.localizedDescription)")
                    return//also notify app of failure as needed
                }
                //print("Respuesta server: \(response.description)")
                let netRes:NetResponse = self.parseNetResponse(response.data)!
                //Llama al callback
                handler(netRes)
                
            }
        } catch let error {
            print("got an error creating the request: \(error)")
        }
        
        
    }
    
    //Funcion asincrona
    func doGetJsonAsync(url:String, handler:(NetResponse) -> Void){
        do {
            let opt = try HTTP.GET(url)
            opt.start { response in
                if let err = response.error {
                    print("error: \(err.localizedDescription)")
                    return //also notify app of failure as needed
                }
                //print("opt finished: \(response.description)")
                let netRes:NetResponse = self.parseNetResponse(response.data)!
                //Llama al callback
                handler(netRes)

            }
        } catch let error {
            print("got an error creating the request: \(error)")
        }
    }
    
    
    //Funcion asincrona
    func doGetJsonAsync(url:String, handler:(NSData) -> Void){
        do {
            let opt = try HTTP.GET(url)
            opt.start { response in
                if let err = response.error {
                    print("error: \(err.localizedDescription)")
                    return //also notify app of failure as needed
                }
                //print("opt finished: \(response.description)")
                
                //Llama al callback
                handler(response.data)
                
            }
        } catch let error {
            print("got an error creating the request: \(error)")
        }
    }
    
    
    
    
    
    
    
    /*
    * Parsea la respuesta en un NetResponse
    */
    func parseNetResponse(contentData:NSData)->NetResponse?{
        do{
            let jsonData : AnyObject! = try NSJSONSerialization.JSONObjectWithData(contentData, options: NSJSONReadingOptions());
            
            //print (jsonData)
            
            let jsonDictionary = jsonData as! NSDictionary;
            
            let netRes = NetResponse()
            
            if  let id = jsonDictionary["id"] as? Int {
                netRes.id = id
            }
            
            if  let code = jsonDictionary["code"] as? Int {
                netRes.code = code
            }
            
            if  let data = jsonDictionary["data"] as? String {
                netRes.data = data
            }
            return netRes
        }catch{
            print(error)
            return nil; //arreglo vacio
        }

    }
    
    
}
