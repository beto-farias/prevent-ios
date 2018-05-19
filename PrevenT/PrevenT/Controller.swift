//
//  Controller.swift
//  PrevenT
//
//  Created by Beto Farias on 11/6/15.
//  Copyright © 2015 2 Geeks one Monkey. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Alamofire_Synchronous



class Controller{
    
    
    //let END_POINT: String                   = "http://notei.com.mx/test/wwwPrevenT/preventServices/";
    static let END_POINT_BASE:String        = "https://prevent-delito.com";
    let END_POINT: String                   = "http://app.prevent-delito.com/preventServices/";
    let END_POINT_LIKE_DELITO:String        = "points/";
    let END_POINT_DELITO_BY_TIPO: String    = "getAllDelitos/";
    let END_POINT_DELITO_TIMELINE : String  = "getAllDelitosFull";
    let END_POINT_LOGIN_USER:String         = "loginUser/";
    let END_POINT_CREATE_USER:String        = "saveUsuario/";
    let END_POINT_DETALLE_DELITO:String     = "getDetallesDelito/";
    let END_POINT_REPORTAR_DELITO:String    = "saveDelito/";
    let END_POINT_ADD_DELITO_MULTIMEDIA     = "saveMultimedia/";
    let END_POINT_REGISTER_DEVICE           = "registerDevice/";
    
    
    //Handlers de peticiones
    var viewHandler:(Bool)->Void = {(arg:Bool) -> Void in}
    var viewHandlerDeltosArray:([DelitoTO])->Void = {(arg:[DelitoTO]) -> Void in}
    var viewHandlerNetResponse:((NetResponse)->Void) = {(arg:NetResponse) -> Void in} //handlers para NetResponse
    
    
    
    //MARK:: Delitos -----------------
    
    func getDelitosByTipo(idTipo: Int, tiempoDias: Int , lat: Double, lon : Double, viewHandlerDelitos:@escaping ([DelitoTO])->Void){
        viewHandlerDeltosArray = viewHandlerDelitos //Handler para la respuesta
        
        let url = "\(END_POINT)\(END_POINT_DELITO_BY_TIPO)tipoDelito/\(idTipo)/idUsuario/\(getUserId())/time/\(tiempoDias)/lat/\(lat)/lon/\(lon)";
        
        //print("getDelitosByTipo \(url)")
        
        let net = NetworkUtils();
        net.doGetJsonAsync(url:url, handler:getDelitosByTipoCallback)
    }
    
    
    
    //Recuoera los delitos en un arreglo de manera sincrona
    func getDelitosByTipoSync(idTipo: Int, tiempoDias: Int , lat: Double, lon : Double)->[DelitoTO]{
        
        
        let url = "\(END_POINT)\(END_POINT_DELITO_BY_TIPO)tipoDelito/\(idTipo)/idUsuario/\(getUserId())/time/\(tiempoDias)/lat/\(lat)/lon/\(lon)";
        
        //print("getDelitosByTipo \(url)")
        
        let net = NetworkUtils();
        let contentData:NSData = net.doGetJsonNSData(url: url)!;
        
         let delitosList = [DelitoTO]();
        
        do{
            let jsonData : AnyObject! = try JSONSerialization.jsonObject(with: contentData as Data, options: JSONSerialization.ReadingOptions()) as AnyObject;
            
            //Transforma la salida a un arreglo
            if let jsonArray = jsonData as? Array<AnyObject>  {
                var delitosList = [DelitoTO]();
                
                for delito in jsonArray {
                    let delito = DelitoTO(data: delito as! NSDictionary);
                    delitosList.append(delito);
                }
                viewHandlerDeltosArray(delitosList)
            }
            
        }catch{
            print(error)
            viewHandlerDeltosArray([DelitoTO]()); //arreglo vacio
        }
        
        return delitosList;
    }
    
    
    //Callback de carga de delitos
    func getDelitosByTipoCallback(contentData:Data){
        do{
            let jsonData : AnyObject! = try JSONSerialization.jsonObject(with: contentData as Data, options: JSONSerialization.ReadingOptions()) as AnyObject;
            
            //Transforma la salida a un arreglo
            if let jsonArray = jsonData as? Array<AnyObject>  {
                var delitosList = [DelitoTO]();
                
                for delito in jsonArray {
                    let delito = DelitoTO(data: delito as! NSDictionary);
                    delitosList.append(delito);
                }
                viewHandlerDeltosArray(delitosList)
            }
        
        }catch{
            print(error)
            viewHandlerDeltosArray([DelitoTO]()); //arreglo vacio
        }
    }
    
    
    
    func getDelitoDetails(numDelito:Int, idDelito:Int)->DelitoTO{
        return getDelitoDetails( numDelito:"\(numDelito)", idDelito: "\(idDelito)");
    }
    
    //Recupera el detalle de un delito especifico, de manera sincrona
    //
    func getDelitoDetails(numDelito:String, idDelito:String)->DelitoTO{

        let url: String = "\(END_POINT)\(END_POINT_DETALLE_DELITO)idNumDelito/\(numDelito)/idEvento/\(idDelito)";
        print(url);
        let net = NetworkUtils();
        let jsonData:NSDictionary = net.doGetJsonString(urlString: url);
        let delito = DelitoTO(data: jsonData);
       
        return delito;
    }
    
    
    /**
        Recuoera los siguentes N renglones a partir del indice
    */
    func getDelitosTimeLine(index: Int) ->[DelitoTO]{
        let url = "\(END_POINT)\(END_POINT_DELITO_TIMELINE)/limitMin/\(index)/numberRow/50";
        
        print(url);
        
        let net = NetworkUtils();
        let dataJson = net.doGetJsonStringArray(urlString: url);
        
        
        var delitosList = [DelitoTO]();
        
        for delito in dataJson {
            let delito = DelitoTO(data: delito as! NSDictionary);
            delitosList.append(delito);
        }
        
        return delitosList;
        
    }
    
    
    
    
    //MARK:: Registro de usaurio -----------------
    
    func registarNuevoUsuario(txtNombrePersona : String, txtCorreoPersona:String, txtPasswordPersona:String)->NetResponse{
        //viewHandler = handler
        
        let url = "\(END_POINT)\(END_POINT_CREATE_USER)";
        //print(url);
        
        let params = ["nombre":txtNombrePersona,"email":txtCorreoPersona,"password":txtPasswordPersona, "repeatPassword":txtPasswordPersona ]

        let net = NetworkUtils();
        
        //Llamada a crear usuario con callback
        //net.doPostJsonAsync(url, params: params, handler: self.registraUsarioHandler)
        let netRes = net.doPostJsonSyncParams(url: url, params: params);
        return netRes;
    }
    
    
    
    
    /*
        Callback de crear usuario
    */
    func registraUsarioHandler(netRes:NetResponse){
        //print(netRes);
        
        if(netRes.code == 1){
            //print(netRes.data);
            let dataString = netRes.data!.replacingOccurrences(of:" ", with: "+")
            //print (dataString)
            
            let usuarioTO: UsuarioTO = UsuarioTO.init(text:dataString);
            
            
            //print("Usuario creado y logeado correctamente ")
            saveUsuarioLocal(usuario: usuarioTO, tipoLogin: 1)
            
            viewHandler(true)
        }else{
            viewHandler(false)
        }
    }
    
    
    //MARK:: Like de delitos ----------------------------------------
    
    /**
    * Método que agrega un like al delito
    */
    func addPoint( idEvento:Int, numDelito:Int,vhNetResponse:@escaping ((NetResponse)->Void) ) ->Int {
        self.viewHandlerNetResponse = vhNetResponse;
    
        let idUser =  getUserId();
        if (idUser < 1) {
            return -1; //No está logeado el usuario
        }
        
        let url = "\(END_POINT)\(END_POINT_LIKE_DELITO)";
    
        //print(url);
        
        let params = ["idNumDelito":"\(numDelito)","idEvento":"\(idEvento)","idUsuario":"\(idUser)" ];
        
        //print(params);
        let net = NetworkUtils();
        
        //Llamada a like con callback
        net.doPostJsonAsync(url: url, params: params, handler: self.addPointHandler);
        return 0;
    }
    
    func addPointHandler(netRes:NetResponse){
        //print(netRes);
        //print("NetResResponse code: \(netRes.code)");
        viewHandlerNetResponse(netRes);//Llama al handler con la respuesta
    }
    
    
    
    //MARK:: Reportar delitos -------------------------------------
    
    var delito:DelitoTO = DelitoTO();
    
    
    func reporteDelito(delito:DelitoTO)->NetResponse{
        
        let url = "\(END_POINT)\(END_POINT_REPORTAR_DELITO)";
        print(url);
        
        
        let params = [
            "idTipoDelito":"\(delito.id_tipo_delito!)", //
            "idSubTipoDelito":"\(delito.id_num_delito!)", //
            "fchEvento":delito.txt_fch_delito,
            "txtDescripcion": delito.txt_resumen,
            "numVictimas":"\(delito.num_victimas)",
            "numDelincuentes":"\(delito.num_delincuentes)",
            
            "txtPais":delito.direccion.txtPais,
            "txtEstado":delito.direccion.txtEstado,
            "txtMunicipio":delito.direccion.txtMunicipio,
            "txtColonia":delito.direccion.txtColonia,
            "txtCalle":delito.direccion.txtCalle,
            "txtNumero":"s/n",
            "txtNumeroInterior":"s/n",
            
            "numLatitud":"\(delito.num_latitud!)",
            "numLongitud":"\(delito.num_longitud!)",
            
            "txtDescripcionLugar":delito.direccion.toString(),
            
            "idTipoMultimedia":"",
            "txtArchivo":"",
            "txtNombreArchivo":"",
            "idUsuario":"\(getUserId())",
            "bAnonimo":"1"
        ];
        
        //print(params);
        
        let net = NetworkUtils();
        
        var images:[UIImage] = []
        
        print("Numero de imagenes: \(delito.logoImages.count)")
        for img in delito.logoImages {
            images.append(img);
        }
        
        //Llamada a publicar reporte corto con callback
        let netRes:NetResponse = net.doPostJsonSyncParams(url: url,params:params);
        print("NetRes: \(netRes)")
        
        if(netRes.code == 1){
            let delitoRes:DelitoTO = DelitoTO(dataString: netRes.data!);
            
            //print(images.count);
            
            reporteDelitoImagen(images: images ,idNumDelito: delitoRes.id_num_delito,idEvento: delitoRes.id_evento);
        }
        return netRes;
    }
    

    
    //Funcion que sube la foto al servidor!
    func reporteDelitoImagen(images:[UIImage],idNumDelito:Int,idEvento:Int){
        print("agregando fotografias \(images.count)");
        
        
        for image in images {
            let url = "\(END_POINT)saveMultimediaMultiPart";
            
            print(url);
            let image : Data = UIImageJPEGRepresentation(image, 0.3)!
       
            let params = [
                "idNumDelito": "\(idNumDelito)",
                "idEvento": "\(idEvento)",
                "idTipoMultimedia": "1", //1 es imagen
                "txtBase64": "base64String",
                "file_upload": NetData(data: image, mimeType: .ImageJpeg, filename: "customName.jpg"),
                ] as [String : Any];
 
            
            
            
            print("FALTA SUBIR LA IMAGEN");
            
            //let urlRequest = self.urlRequestWithComponents(urlString: url, parameters: params)
            
            
            /*
            
            //let response = Alamofire.upload(urlRequest.0, data: urlRequest.1)
            let response = Alamofire.upload(data:params, to: url).response { response in // method defaults to `.post`
                .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                    print("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
                }
                .responseString()
            print("Response: \(response)")
            */
        }
    }
    
    
    
    //this function to help upload photo
    
//    func urlRequestWithComponents(urlString:String, parameters:Dictionary<String, Any>) -> (URLRequestConvertible, Data) {
//        
//        
//        // create url request to send
//        let mutableURLRequest = NSMutableURLRequest(url: URL(string: urlString)!)
//        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
//        //let boundaryConstant = "myRandomBoundary12345"
//        let boundaryConstant = "NET-POST-boundary-\(arc4random())-\(arc4random())"
//        let contentType = "multipart/form-data;boundary="+boundaryConstant
//        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
//        
//        
//        // create upload data to send
//        let uploadData = NSMutableData()
//        
//        // add parameters
//        for (key, value) in parameters {
//            
//            uploadData.append("\r\n--\(boundaryConstant)\r\n".data(using: String.Encoding.utf8)!)
//            
//            if value is NetData {
//                // add image
//                let postData = value as! NetData
//                
//                
//                //uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(postData.filename)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
//                
//                // append content disposition
//                let filenameClause = " filename=\"\(postData.filename)\""
//                let contentDispositionString = "Content-Disposition: form-data; name=\"\(key)\";\(filenameClause)\r\n"
//                let contentDispositionData = contentDispositionString.data(using: String.Encoding.utf8)
//                uploadData.append(contentDispositionData!)
//                
//                
//                // append content type
//                //uploadData.appendData("Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!) // mark this.
//                let contentTypeString = "Content-Type: \(postData.mimeType.getString())\r\n\r\n"
//                let contentTypeData = contentTypeString.data(using: String.Encoding.utf8)
//                uploadData.append(contentTypeData!)
//                uploadData.append(postData.data)
//                
//            }else{
//                uploadData.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".data(using: String.Encoding.utf8)!)
//            }
//        }
//        uploadData.append("\r\n--\(boundaryConstant)--\r\n".data(using: String.Encoding.utf8)!)
//        
//        
//        
//        // return URLRequestConvertible and NSData
//        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
//    }
    
    
    
    
    
    
    
    func reporteDelitoImagenHandler(netRes:NetResponse){
       // print("reporteDelitoImagenHandler netres: \(netRes)");
    }
    
    
    //MARK:: Login de usaurio -----------------
    
    //1 logeado correctamente
    //0 error con el usuario
    //-1 no hay internet
    
    func login(user:String, pass:String)->Int{
        
        let url = "\(END_POINT)\(END_POINT_LOGIN_USER)username/\(user)/password/\(pass)";
        //print(url);
        let net = NetworkUtils();
        let netRes = net.doGetJsonNetResponse(  url: url );
        //print(netRes);
        
        if(netRes == nil){
            return -1;
        }
    
        if(netRes?.code == 1){
            //print(netRes!.data);
            let dataString = netRes!.data!.replacingOccurrences(of:" ", with: "+")
            //print (dataString)
            
            let usuarioTO: UsuarioTO = UsuarioTO.init(text:dataString);

            //print("Usuario logeado correctamente ")
            saveUsuarioLocal(usuario: usuarioTO, tipoLogin: 1)
            return 1;
        }
        return 0;
    }
    
    
    /**
     *
    */
    func logoutUser(){
        let preferences = UserDefaults.standard
        
        preferences.removeObject(forKey: Constantes.PREFS_TIPO_LOGIN) //Tipo de login (local FB o TW)
        preferences.removeObject(forKey: Constantes.PREFS_USER_ID) //Id del usaurio
        preferences.removeObject(forKey: Constantes.PREFS_USER_NAME) //Nombre del usuario
        preferences.removeObject(forKey: Constantes.PREFS_USER_PIC_URL) //Imagen
        preferences.removeObject(forKey: Constantes.PREFS_USER_FB_ID) //Si esta logeado cn FBs
        
        preferences.synchronize();
        //print("Borrando usuario \(didSave)");
    }
    
    
    func saveUsuarioLocal(usuario: UsuarioTO, tipoLogin:Int){
        //print(usuario);
        
        let preferences = UserDefaults.standard
        
        preferences.set(tipoLogin, forKey: Constantes.PREFS_TIPO_LOGIN)
        preferences.set(usuario.idUsuario!, forKey: Constantes.PREFS_USER_ID)
        preferences.set(usuario.txtEmail!, forKey: Constantes.PREFS_USER_NAME)
        preferences.set(usuario.usuarioPro, forKey: Constantes.PREFS_USER_PRO)
        
        //preferences.setObject(usuario.uriPicImageStr!, forKey: Constantes.PREFS_USER_PIC_URL)
        //preferences.setInteger(usuario.fbUser!, forKey: Constantes.PREFS_USER_FB_ID)
        
        //  Save to disk
        preferences.synchronize();
    }
    
    
    //MARK:: --------------------Preferencias de usuario ------------------
    
    /**
     Marca los delitos seleccionados
     **/
    func setDelitoSelected(idDelito: Int, estado: Bool){
        let preferences = UserDefaults.standard
        let delito : String = Constantes.PREFS_TIPO_DELITO_ + String(idDelito);
        preferences.set(estado, forKey: delito)
        preferences.synchronize();
        //print(didSave);
    }
    
    
    /**
     Cuenta cuantos delitos seleccionados hay
    **/
    func getCountDelitosSeleccionados()->Int{
        var count = 0;
        
        for i in 0...Constantes.CANT_MAXIMA_DELITOS {
            if(isDelitoSelected(idDelito: i)){
                count += 1;
            }
        }
        return count;
    }
    
    
    /**
     Verifica si un delito esta marcado
     */
    func isDelitoSelected(idDelito: Int)->Bool{
        let preferences = UserDefaults.standard;
        let delito : String = Constantes.PREFS_TIPO_DELITO_ + String(idDelito);
        if preferences.object(forKey: delito) != nil{
            return preferences.bool(forKey: delito);
        }
        return false;
    }
    
    /*
    Valida si el usuario está logeado en el sistema
    */
    func isUsuaioLogeado()->Bool{
        let preferences = UserDefaults.standard;
        return preferences.object(forKey: Constantes.PREFS_TIPO_LOGIN) != nil;
    }
    
    
    func firstTimeRun()->Bool{
        let preferences = UserDefaults.standard;
        if(preferences.object(forKey: Constantes.PREFS_FIRST_TIME_RUN) != nil){
            return preferences.bool(forKey: Constantes.PREFS_FIRST_TIME_RUN);
        }else{
            return false;
        }
    }
    
    func setFirstTimeRun(estado:Bool){
        let preferences = UserDefaults.standard
        preferences.set(estado, forKey: Constantes.PREFS_FIRST_TIME_RUN)
        //  Save to disk
        preferences.synchronize();
    }
    
    /*
    Rcupera el nombre del usuario
    */
    func getUserName()->String{
        let preferences = UserDefaults.standard;
        if( preferences.object(forKey: Constantes.PREFS_USER_NAME) == nil){
            return "Sin registrar";
        }else{
            return preferences.string(forKey: Constantes.PREFS_USER_NAME)!;
        }
    }
    
    /*
    Rcupera el id del usuario
    */
    func getUserId()->Int{
        let preferences = UserDefaults.standard;
        if( preferences.object(forKey: Constantes.PREFS_USER_ID) == nil){
            return -1;
        }else{
            return preferences.integer(forKey: Constantes.PREFS_USER_ID);
        }
    }
    
    /*
    Rcupera el si el usuario es pro
    */
    func getUserPro()->Int{
        let preferences = UserDefaults.standard;
        if( preferences.object(forKey: Constantes.PREFS_USER_PRO) == nil){
            return -1;
        }else{
            return preferences.integer(forKey: Constantes.PREFS_USER_PRO);
        }
    }
   
    /*
    Rcupera el la imagen del usuario
    */
    func getUserPic()->String{
        let preferences = UserDefaults.standard;
        if( preferences.object(forKey: Constantes.PREFS_USER_PIC_URL) == nil){
            return "";
        }else{
            return preferences.string(forKey: Constantes.PREFS_USER_PIC_URL)!;
        }
    }
    
    /*
    Rcupera el la imagen del usuario
    */
    func getUserFBId()->Int{
        let preferences = UserDefaults.standard;
        if( preferences.object(forKey: Constantes.PREFS_USER_FB_ID) == nil){
            return -1;
        }else{
            return preferences.integer(forKey: Constantes.PREFS_USER_FB_ID);
        }
    }
    
    
    static func getDelitoIco(tipo:Int)->UIImage{
        return UIImage(named: getDelitoIcoName(tipo: tipo))!
    }
    
    static func getDelitoIcoName(tipo:Int)->String{
        switch(tipo){
        case 1:
            return "icon_crimen_secuestro";
        case 2:
            return "icon_crimen_homicidio";
        case 3:
            return "icon_crimen_desapariciones";
        case 4:
            return "icon_crimen_robo";
        case 5:
            return "icon_crimen_sexual";
        case 6:
            return "icon_crimen_extorsion";
        case 7:
            return "icon_crimen_mercado_negro";
        case 8:
            return "icon_crimen_enfrentamiento";
        case 9:
            return "icon_crimen_ciberneticos";
        case 10:
            return "icon_crimen_movilizacion_social";
        case 11:
            return "icon_crimen_violencia";
        case 12:
            return "icon_crimen_prevencion";
        default:
            return "";
        }
    }
    
    func getMarkerIcoByType(tipo:Int) -> String{
        switch(tipo){
        case 1:
            return "icon_marker_secuestro.png";
        case 2:
            return "icon_marker_homicidio.png";
        case 3:
            return "icon_marker_desapariciones.png";
        case 4:
            return "icon_marker_robo.png";
        case 5:
            return "icon_marker_sexual.png";
        case 6:
            return "icon_marker_extorsion.png";
        case 7:
            return "icon_marker_mercado_negro.png";
        case 8:
            return "icon_marker_enfrentamiento.png";
        case 9:
            return "icon_marker_ciberneticos.png";
        case 10:
            return "icon_marker_movimientos_sociales.png";
        case 11:
            return "icon_marker_violencia.png";
        case 12:
            return "icon_marker_prevencion.png";
        default:
            return "";
        }
    }
    
    
    static func getDelitoStrByType(tipo:Int) -> String{
        switch(tipo){
        case 1:
            return "Secuestro";
        case 2:
            return "Homicidio";
        case 3:
            return "Desapariciones";
        case 4:
            return "Robo";
        case 5:
            return "Delitos Sexuales";
        case 6:
            return "Extorsión";
        case 7:
            return "Mercado ilegal";
        case 8:
            return "Enfrentamiento";
        case 9:
            return "Delitos ciberneticos";
        case 10:
            return "Movimientos sociales";
        case 11:
            return "Violencia";
        case 12:
            return "Prevención";
        default:
            return "";
        }
        
    }
    
    static func  getSubDelitosById(idTipoDelito:Int)->[String]{
        switch (idTipoDelito) {
            case Constantes.TIPO_DELITO_CIBERNETICOS:
                return ["Clonación tarjetas","Robo de identidad","Hacking","Robo de información"];
            case Constantes.TIPO_DELITO_DESAPARICIONES:
                return ["Forzada"];
            case Constantes.TIPO_DELITO_ENFRENTAMIENTOS:
                return ["Gobierno - Delincuentes", "Delicuentes - Delincuentes", "Sociedad - Delincuentes"];
            case Constantes.TIPO_DELITO_EXTORCION:
                return ["Servidor público","Grupo delictivo", "Telefónica","Cibernética","Franelero"];
            case Constantes.TIPO_DELITO_HOMICIDIO:
                return ["Arma blanca","Arma fuego","Involuntario"];
            case Constantes.TIPO_DELITO_MERCADO_NEGRO:
                return ["Drogas","Armas","Pirateria","Organos","Animales"];
            case Constantes.TIPO_DELITO_ROBO:
                return ["Vehículo","Transeunte","Casa","Negocio","Automovilista","Cibernetico"];
            case Constantes.TIPO_DELITO_SECUESTRO:
                return ["Simple",  "Grupo delictivo","Virtual","Desapariciones forzadas"];
            case Constantes.TIPO_DELITO_SEXUAL:
                return ["Violación","Trata de blancas","Acoso sexual","Pornografía infantil"];
            case Constantes.TIPO_DELITO_MOVIMIENTOS_SOCIALES:
                return ["Marcha","Plantones","Bloqueos"];
            case Constantes.TIPO_DELITO_SOCIALES:
                return ["Violencia intrafamiliar","Alteración del orden público"];
        case Constantes.TIPO_DELITO_PREVENCION:
            return ["Persona sospechosos","Vehículo abandonado"];
        default:
                return [];
        }
    
    }
    
    
    //MARK: ==================== HELP ===========================
    
    func showHelp()->Bool{
        let preferences = UserDefaults.standard;
        if( preferences.object(forKey: Constantes.PREFS_SHOW_HELP) == nil){
            return true;
        }else{
            return preferences.bool(forKey: Constantes.PREFS_SHOW_HELP);
        }
    }
    
    func forceShowHelp(){
        let preferences = UserDefaults.standard
        preferences.set(true, forKey: Constantes.PREFS_SHOW_HELP);
        
        //  Save to disk
        preferences.synchronize();
    }
    
    func hideHelp(){
        let preferences = UserDefaults.standard
        preferences.set(false, forKey: Constantes.PREFS_SHOW_HELP);
        
        //  Save to disk
        preferences.synchronize();
    }
    
    
    //MARK: ===================== PUSH ==========================
    
    func registrarDispositivo(idDevice:String){
        
        //print("============== REGISTRANDO DEVICE ======================")
        let url = "\(END_POINT)\(END_POINT_REGISTER_DEVICE)";
        //print(url);
        
        let params = ["regId":idDevice,"tipoDispositivo":"IOS","version":"1.0" ]
        
        let net = NetworkUtils();
        
        //Llamada a crear usuario con callback
        net.doPostJsonSyncParams(url: url, params: params);
        
        //print("============== TERMINA REGISTRANDO DEVICE ======================")
    }
    
}


//http://stackoverflow.com/questions/29137488/how-do-i-resize-the-uiimage-to-reduce-upload-image-size
extension UIImage {
    
    func resize(scale:CGFloat)-> UIImage {
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: size.width*scale, height: size.height*scale)))
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
    func resizeToWidth(width:CGFloat)-> UIImage {
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
}

