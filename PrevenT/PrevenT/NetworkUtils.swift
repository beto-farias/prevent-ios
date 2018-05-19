//
//  NetworkUtils.swift
//  PrevenT
//
//  Created by Beto Farias on 11/6/15.
//  Copyright © 2015 2 Geeks one Monkey. All rights reserved.
//

import Foundation
//import SwiftHTTP

class NetworkUtils{
    
    
    //"http://dl-8.one2up.com/onetwo/content/2015/6/15/9c3b51249fbbe20ca9d841401e276d97.php"
    
    //Funcion asincrona
    func doGetJsonStringArray(urlString:String)->Array<AnyObject> {
        
        //Descarga el contenido de la url
        if let url = URL(string:urlString){ //Valida que la url sea correcta
            print("NetworkUtils:URL: \(url)");
            
            //Lee los datos
            let contentData = NSData(contentsOf:url)
            do{
                if(contentData != nil){
                    let jsonData : AnyObject! = try JSONSerialization.jsonObject(with: contentData! as Data, options: JSONSerialization.ReadingOptions()) as AnyObject;
                
                    //Transforma la salida a un arreglo
                    if let jsonArray = jsonData as? Array<AnyObject>  {
                        return jsonArray;
                    }
                }
                
            }catch{
                print(error)
                return [String]() as Array<AnyObject>; //arreglo vacio
            }
        }
        return [String]() as Array<AnyObject>; //Arreglo vacio
    }
    
    
    
    /**
        Rupera un NSDirectory de internet

    */
    
    func doGetJsonString(urlString:String)->NSDictionary!{
        
        //Descarga el contenido de la url
        if let url = URL(string:urlString){ //Valida que la url sea correcta
            print("NetworkUtils:URL: \(url)");
            
           
            //Lee los datos
            let contentData = NSData(contentsOf:url);
            
            let datastring = NSString(data: contentData! as Data, encoding: String.Encoding.utf8.rawValue)
            
            print(datastring);
            
            if(datastring == "false"){
                return nil;
            }
            
            //let directory:NSDictionary = NSKeyedUnarchiver.unarchiveObjectWithData(contentData!)! as! NSDictionary
            do{
                let boardsDictionary: NSDictionary = try JSONSerialization.jsonObject(with: contentData! as Data, options: .allowFragments) as! NSDictionary
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
        if let url = URL(string:url){ //Valida que la url sea correcta
            //print("NetworkUtils:URL: \(url)");
            
            //Lee los datos
            let contentData = NSData(contentsOf:url)
            if(contentData != nil){
                let netRes = self.parseNetResponse(contentData: Data(referencing: contentData!));
                return netRes
            }
        }
        return nil; //Arreglo
    }
    
    
    
    //Funcion sincrona
    func doGetJsonNSData(url:String)->NSData?{
        //Descarga el contenido de la url
        if let url = URL(string:url){ //Valida que la url sea correcta
            //print("NetworkUtils:URL: \(url)");
            
            //Lee los datos
            let contentData = NSData(contentsOf:url)
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
        
        let netRes:NetResponse = doPostSync(url: url,postString: data);
        return netRes;
    }
    
    
    
    //Funcion POST SINCRONA
    func doPostSync(url:String, postString:String)->NetResponse{
        
        let HTTPMethod: String = "POST"
        let timeoutInterval: TimeInterval = 60
        let HTTPShouldHandleCookies: Bool = false
        
        
        let request: NSMutableURLRequest = NSMutableURLRequest(url: URL(string: url)!);
        request.httpMethod = HTTPMethod
        request.timeoutInterval = timeoutInterval
        request.httpShouldHandleCookies = HTTPShouldHandleCookies
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
        do{
            let responseData  = try NSURLConnection.sendSynchronousRequest(request as URLRequest,returning: nil)
            let results = NSString(data:responseData, encoding:String.Encoding.utf8.rawValue)!
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
    func doPostJsonAsync(url:String, params:[String:String], handler:@escaping (NetResponse) -> Void){
        
        print("doPostJsonAsync, url: ", url);
        print("Comentado asdf")
        
        let jsonBody:[String:Any] = params;
        
        guard let mUrl = URL(string: url)
            else {
                return;
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
            
            var request = URLRequest(url: mUrl);
            request.httpMethod = "POST";
            request.httpBody = data;
            request.addValue("application/json", forHTTPHeaderField: "Content-Type");
            request.addValue("application/json", forHTTPHeaderField: "Accept");
            
            
            URLSession.shared.dataTask(with: request) { (data, response, err) in
                guard let data = data
                    else{
                        return;
                }
                
                if let httpResponse = response as? HTTPURLResponse{
                    //delegate.didNetworkFinishedHeaders(headers: httpResponse, option: option);
                }
                

                let netRes:NetResponse = self.parseNetResponse(contentData: data)!
                
                //Llama al callback
                handler(netRes)
                }.resume();
            
        }catch let Err{
            //delegate.didNetworkFinishedWithError(err:Err,option: option);
        }
        
        
        
//        do {
//            let opt = try HTTP.POST(url, parameters: params)
//            opt.start { response in
//                if let err = response.error {
//                    print("error: \(err.localizedDescription)")
//                    return//also notify app of failure as needed
//                }
//                //print("Respuesta server: \(response.description)")
//                let netRes:NetResponse = self.parseNetResponse(response.data)!
//                //Llama al callback
//                handler(netRes)
//                
//            }
//        } catch let error {
//            print("got an error creating the request: \(error)")
//        }
        
        
    }
    
    //Funcion asincrona
    func doGetJsonAsync(url:String, handler:(NetResponse) -> Void){
        
        print("comentada");
        
//        do {
//            let opt = try HTTP.GET(url)
//            opt.start { response in
//                if let err = response.error {
//                    print("error: \(err.localizedDescription)")
//                    return //also notify app of failure as needed
//                }
//                //print("opt finished: \(response.description)")
//                let netRes:NetResponse = self.parseNetResponse(response.data)!
//                //Llama al callback
//                handler(netRes)
//
//            }
//        } catch let error {
//            print("got an error creating the request: \(error)")
//        }
    }
    
    
    //Funcion asincrona
    func doGetJsonAsync(url:String, handler:@escaping (Data) -> Void){
        
        print("comentada: " , url);
        var jsonBody:[String:Any]=[:];
        
        
        guard let mUrl = URL(string: url)
            else {
                return;
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: jsonBody, options: [])
            
            var request = URLRequest(url: mUrl);
            request.httpMethod = "POST";
            request.httpBody = data;
            request.addValue("application/json", forHTTPHeaderField: "Content-Type");
            request.addValue("application/json", forHTTPHeaderField: "Accept");
            //request.addValue(AppData.authToken, forHTTPHeaderField: "Authentication-Token");
            
            
            
            URLSession.shared.dataTask(with: request) { (data, response, err) in
                guard let data = data
                    else{
                        return;
                }
                
                if let httpResponse = response as? HTTPURLResponse{
                    //delegate.didNetworkFinishedHeaders(headers: httpResponse, option: option);
                }
                
                //delegate.didNetworkFinished(data: data, option: option);
                handler(data)
                
                }.resume();
            
        }catch let Err{
            //delegate.didNetworkFinishedWithError(err:Err,option: option);
        }
        
        
        
//        do {
//            let opt = try HTTP.GET(url)
//            opt.start { response in
//                if let err = response.error {
//                    print("error: \(err.localizedDescription)")
//                    return //also notify app of failure as needed
//                }
//                //print("opt finished: \(response.description)")
//
//                //Llama al callback
//                handler(response.data)
//
//            }
//        } catch let error {
//            print("got an error creating the request: \(error)")
//        }
    }
    
    
    
    
    
    
    
    /*
    * Parsea la respuesta en un NetResponse
    */
    func parseNetResponse(contentData:Data)->NetResponse?{
        do{
            let jsonData : AnyObject! = try JSONSerialization.jsonObject(with: contentData as Data, options: JSONSerialization.ReadingOptions()) as AnyObject;
            
            print (jsonData)
            
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
