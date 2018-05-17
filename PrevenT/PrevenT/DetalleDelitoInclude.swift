//
//  DetalleDelitoInclude.swift
//  PrevenT
//
//  Created by Beto Farias on 11/19/15.
//  Copyright © 2015 2 Geeks one Monkey. All rights reserved.
//

import Foundation
import UIKit

class DetalleDelitoInclude :UIView{
    
    @IBOutlet weak var txtTituloDelito: UILabel!
    @IBOutlet weak var txtDias: UILabel!
    @IBOutlet weak var txtDistancia: UILabel!
    @IBOutlet weak var txtDescripcion: UITextView!
    @IBOutlet weak var txtNumDelincuentes: UILabel!
    @IBOutlet weak var txtNumVictimas: UILabel!
    @IBOutlet weak var txtNumLikes: UILabel!
    @IBOutlet weak var imgTipoDelito: UIImageView!
    @IBOutlet var txtNumMultimedia: UILabel!
    
    var idDelito:Int!;
    var numDelito:Int!;
    var numLike:Int = 0;
    
    
    @IBOutlet var likeButton: UIButton!
    
    
    //Click del boton
    func likeAction(sender: UIButton) {
        
        //print("Likebutton")
        
        let controller:Controller = Controller();
        
        let res = controller.addPoint(idEvento: idDelito,numDelito: numDelito,vhNetResponse: likeActionCallback);
        if(res == -1){
            //Mostar toast de que no está logeado el usuario
            //print("El suaurio no esta logeado");
        }
    }
    
    
    
    //Callback de like del boton
    func likeActionCallback(netRes:NetResponse){
        //print("likecallback");
        
        switch(netRes.code!){
        case 1:
            DispatchQueue.main.async(execute: {
                self.numLike = self.numLike+1;
                self.txtNumLikes.text = "\(self.numLike)";
            });
            //print("Se ha registrado su like correctamente");
            break;
        case 0:
            //print("No puede dar like al a sus reportes");
            break;
        case -1:
            //print("Ha ocurrido un error, intentelo más tarde");
            break;
        case -2:
            //print("Ya ha dado like a este reporte");
            break;
        default:
            break;
        }
    }

    
}
