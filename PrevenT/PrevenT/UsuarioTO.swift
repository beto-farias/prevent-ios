//
//  UsuarioTO.swift
//  PrevenT
//
//  Created by Beto Farias on 11/6/15.
//  Copyright © 2015 2 Geeks one Monkey. All rights reserved.
//

import Foundation

class UsuarioTO{
    
    var idUsuario:Int?;
    var txtUsuario:String?;
    var txtEmail:String?;
    var uriPicImageStr:String?;
    var fbUser:Int?;
    var usuarioPro:Int = 0;
    
    
    init(){}
    
    //Inicializa el usuario apartir de un string de json
    init (text:String){
        
        
        let jsonDictionary = StringUtils.convertStringToDictionary(text)
        
    
        
        if  let id = Int(jsonDictionary!["idUsuario"]!)  {
            self.idUsuario = id
        }
        
        if  let txtUsr = jsonDictionary!["txtUsuario"] {
            self.txtUsuario = txtUsr;
        }
        
        if  let txtMail = jsonDictionary!["txtEmail"]  {
            self.txtEmail = txtMail;
        }
        
        if let up = Int(jsonDictionary!["usuarioPro"]!)  {
            self.usuarioPro = up
        }


        
    }
    
    init (txtUsuario:String, txtEmail:String , uriPicImageStr:String , fbUser:Int){
        self.txtUsuario = txtUsuario
        self.txtEmail = txtEmail
        self.uriPicImageStr = uriPicImageStr
        self.fbUser = fbUser
    }
}
