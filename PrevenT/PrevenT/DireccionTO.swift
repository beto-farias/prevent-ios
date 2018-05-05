//
//  DoreccionTO.swift
//  PrevenT
//
//  Created by Beto Farias on 12/28/15.
//  Copyright © 2015 2 Geeks one Monkey. All rights reserved.
//

import Foundation

class DireccionTO{

    var txtPais:String = "sin pais";
    var txtCalle:String = "sin calle";
    var txtColonia:String = "sin colonia";
    var txtEstado:String = "sin estado";
    var txtMunicipio:String = "sin municipio";
    
    func toString()->String{
        return"\(txtCalle) \(txtColonia) \(txtMunicipio) \(txtEstado) \(txtPais)"
    }
}