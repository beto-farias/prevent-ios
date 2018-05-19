//
//  LeftDrawerItem.swift
//  PrevenT
//
//  Created by Beto Farias on 11/9/15.
//  Copyright © 2015 2 Geeks one Monkey. All rights reserved.
//

import Foundation
import UIKit

class LeftDrawerItem{
    
    static let    MENU_LOGIN:Int                        = 1; //Solo texto
    static let    MENU_LOGOUT:Int                       = 2; //Solo texto
    static let    MENU_REPORTAR_DELITO:Int              = 3; //Solo texto
    static let    MENU_HELP:Int                         = 4; //Solo texto
    
    static let    MENU_CHECK_SECUESTRO:Int              = 1001; // texto con check box
    static let    MENU_CHECK_HOMICIDIO:Int              = 1002; // texto con check box
    static let    MENU_CHECK_DESAPARICONES:Int          = 1003; // texto con check box
    static let    MENU_CHECK_CIBERNETICO:Int            = 1004; // texto con check box
    static let    MENU_CHECK_ENFRENTAMIENTOS:Int        = 1005; // texto con check box
    static let    MENU_CHECK_EXTORCION: Int             = 1006; // texto con check box
    static let    MENU_CHECK_MOVIMIENTOS_SOCIALES:Int   = 1007; // texto con check box
    static let    MENU_CHECK_MERCADO_NEGRO: Int         = 1008; // texto con check box
    static let    MENU_CHECK_ROBO:Int                   = 1009; // texto con check box
    static let    MENU_CHECK_SEXUAL:Int                 = 1010; // texto con check box
    static let    MENU_CHECK_SOCIALES:Int               = 1011; // texto con check box
    static let    MENU_CHECK_PREVENCION:Int             = 1012; // texto con check box
    
    
    
    var  title: String;
    var  selected: Bool;
    var type: Int;
    var hasSelectableItem: Bool;
    var icon:UIImage!;
    
    init(type:Int, hasSelectableItem: Bool){
        self.type = type;
        self.hasSelectableItem = hasSelectableItem;
        self.title = "";
        self.selected = false;
    }
    
    init(type:Int, hasSelectableItem: Bool, title: String){
        self.type = type;
        self.hasSelectableItem = hasSelectableItem;
        self.title = title;
        self.selected = false;
    }
    
    init(type:Int, hasSelectableItem: Bool, title: String, icon:UIImage){
        self.type = type;
        self.hasSelectableItem = hasSelectableItem;
        self.title = title;
        self.selected = false;
        self.icon = icon;
    }
    
    init(type:Int, hasSelectableItem: Bool, title: String, selected: Bool){
        self.type = type;
        self.hasSelectableItem = hasSelectableItem;
        self.title = title;
        self.selected = selected;
    }
    
    init(type:Int, hasSelectableItem: Bool, title: String, selected: Bool, icon:UIImage){
        self.type = type;
        self.hasSelectableItem = hasSelectableItem;
        self.title = title;
        self.selected = selected;
        self.icon = icon;
    }
}
