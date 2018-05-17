//
//  Constantes.swift
//  PrevenT
//
//  Created by Beto Farias on 11/7/15.
//  Copyright © 2015 2 Geeks one Monkey. All rights reserved.
//

import Foundation

class Constantes{
    
    
    //CANTIDAD DE DELITOS MAXIMOS DEL SISTEMA
    static let CANT_MAXIMA_DELITOS:Int = 12;
    
    //Distancia maxima para mostrar una notificacion en metros
    static let MAX_DISTANCIA_NOTIFICACION:Double = 1000;
    
    //Version 1 todo abierto
    //static let CANTIDAD_DELITOS_USUARIO_ANONIMO:Int = 3;
    //static let CANTIDAD_DELITOS_USUARIO_LOGEADO_NO_PRO:Int = 5;
    
    static let CANTIDAD_DELITOS_USUARIO_ANONIMO:Int = CANT_MAXIMA_DELITOS;
    static let CANTIDAD_DELITOS_USUARIO_LOGEADO_NO_PRO:Int = CANT_MAXIMA_DELITOS;
    static let CANTIDAD_DELITOS_USUARIO_LOGEADO_PRO:Int = CANT_MAXIMA_DELITOS;
    
    static let PREFS_NAME: String = "prevent_t_preferences";
    static let PREFS_USER_ID: String = "PREFS_USER_ID";
    static let PREFS_TIPO_LOGIN: String = "PREFS_TIPO_LOGIN";
    static let PREFS_USER_NAME :String = "PREFS_USER_NAME";
    static let PREFS_USER_PIC_URL :String = "PREFS_USER_PIC_URL";
    static let PREFS_USER_FB_ID :String = "PREFS_USER_FB_ID";
    static let PREFS_USER_PRO:String = "PREFS_USER_PRO";
    static let PREFS_SHOW_HELP:String = "PREFS_SHOW_HELP";
    
    static let PREFS_TIPO_DELITO_: String = "PREFS_TIPO_DELITO_";
    
    static let PREFS_FIRST_TIME_RUN:String = "PREFS_FIRST_TIME_RUN";
    
    
    static let TIPO_DELITO_SECUESTRO:Int = 1;
    static let TIPO_DELITO_HOMICIDIO:Int = 2;
    static let TIPO_DELITO_DESAPARICIONES:Int = 3;
    static let TIPO_DELITO_ROBO:Int = 4;
    static let TIPO_DELITO_SEXUAL:Int = 5;
    static let TIPO_DELITO_EXTORCION:Int = 6;
    static let TIPO_DELITO_MERCADO_NEGRO:Int = 7;
    static let TIPO_DELITO_ENFRENTAMIENTOS:Int = 8;
    static let TIPO_DELITO_CIBERNETICOS:Int = 9;
    static let TIPO_DELITO_MOVIMIENTOS_SOCIALES:Int = 10;
    static let TIPO_DELITO_SOCIALES:Int = 11;
    static let TIPO_DELITO_PREVENCION:Int = 12;
}
