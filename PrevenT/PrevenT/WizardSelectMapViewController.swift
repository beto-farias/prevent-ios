//
//  WizardSelectMapViewController.swift
//  PrevenT
//
//  Created by Beto Farias on 12/27/15.
//  Copyright © 2015 2 Geeks one Monkey. All rights reserved.
//

import UIKit
import GoogleMaps

//Variable Global para almacenar el delito
var delitoReporteTO:DelitoTO = DelitoTO();

class WizardSelectMapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    
    @IBOutlet var containerView: UIView!
    @IBOutlet var imgTarget: UIImageView!
    
    var latitud:Double = 0;
    var longitud:Double = 0;
    
    //Zoom del mapa al iniciar
    let zoomLevel:Float = 14;
    
    //Marcador
    var marker:GMSMarker!;

    
    //Posicion del usuario
    var userLocation:CLLocation?;
    
    var locationManager = CLLocationManager();
    
    //Variable del mapa
    var myMapView:GMSMapView!;


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //Servicios de localización
        self.locationManager.delegate = self;
        self.locationManager.requestWhenInUseAuthorization();
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.startUpdatingLocation();
        
        //Posicion inicial de la camara México
        //let camera = GMSCameraPosition.cameraWithLatitude(23.364303,longitude: -111.5866852, zoom: zoomLevel);
        let camera = GMSCameraPosition.camera(withLatitude: latitud,longitude: longitud, zoom: zoomLevel);
        
        myMapView = GMSMapView.map(withFrame: CGRect(x:0, y:0,  width:self.view.bounds.width, height:self.view.bounds.height-42), camera:camera)
        
        self.myMapView.animate(to: camera);
        myMapView.delegate = self;
        myMapView.isMyLocationEnabled = true
        myMapView.settings.myLocationButton = true;
        myMapView.settings.compassButton = true;
        
        
        //Agrega el mapa en el centro
        self.containerView.addSubview(myMapView);
        
        
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Inicializa el delito
        delitoReporteTO = DelitoTO();
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    Servicio de localización
    */
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print("locationManager Update");
        
        //Localización del usuario
        userLocation = locations[0] as CLLocation;
        
        locationManager.stopUpdatingLocation();
        
       
        //Posicion inicial de la camara donde esta el usuario
        //let camera = GMSCameraPosition.cameraWithLatitude(userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude, zoom: zoomLevel);
       // self.myMapView.animateToCameraPosition(camera);
        
    }
    
    

    
    @IBAction func siguienteAction(sender: AnyObject) {
        
        self.myMapView.clear();
        
        let center:CLLocationCoordinate2D = myMapView.camera.target;
        
        let marker = GMSMarker()
        marker.position = center;
        
        marker.icon = UIImage(named: "icon-reportar-delito")
        marker.appearAnimation = GMSMarkerAnimation.pop;
        marker.map = self.myMapView
        
        //Espera unos segundos antes de hacer el segue
        let seconds = 0.5
        
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.performSegue(withIdentifier: "puntoEvento2tipoEvento", sender: sender)
        }
        
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.myMapView.clear();
        
        let center:CLLocationCoordinate2D = myMapView.camera.target;
        
        reverseGeocodeCoordinate(coordinate: center);
        
        let marker = GMSMarker()
        marker.position = center;
        marker.map = self.myMapView
        marker.icon = UIImage(named: "icon-reportar-delito")
        
        
        //Asigna las coordenadas al delito reporte
        delitoReporteTO.num_longitud = center.longitude;
        delitoReporteTO.num_latitud = center.latitude;
    }
    
    
    //Recupera la direccion a partir de un punto específico
    //http://www.raywenderlich.com/109888/google-maps-ios-sdk-tutorial
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
        
        // 1
        let geocoder = GMSGeocoder()
        
        // 2
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            if let address = response?.firstResult() {
                
                if((address.country) != nil){
                    delitoReporteTO.direccion.txtPais = address.country!
                }
                
                if((address.thoroughfare) != nil){
                    delitoReporteTO.direccion.txtCalle = address.thoroughfare!
                }
                
                if((address.subLocality) != nil){
                    delitoReporteTO.direccion.txtColonia = address.subLocality!
                }
                
                if((address.administrativeArea) != nil){
                    delitoReporteTO.direccion.txtEstado = address.administrativeArea!
                }
                
               if((address.locality) != nil){
                    delitoReporteTO.direccion.txtMunicipio = address.locality!
                }
            }
        }
    }
    

}
