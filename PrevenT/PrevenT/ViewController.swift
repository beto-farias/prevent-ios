//Mapas de Google
//https://developers.google.com/maps/documentation/ios-sdk/start
//
//  ViewController.swift
//  PrevenT
//
//  Created by Beto Farias on 11/6/15.
//  Copyright © 2015 2 Geeks one Monkey. All rights reserved.
//

import UIKit
import GoogleMaps;
import GooglePlaces;

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    let controller:Controller = Controller();
    let btnTiempoColorSelected = UIColor(netHex: 0xE2652A);
    
    
    @IBOutlet var viewContainer: UIView!
    
    //Esta variable debe cambiar segun la seleccion del usuaro
    var tiempoDias = 1;
    
     var loadDelitosCount = 0
    
    @IBOutlet var btnOneDay: UIButton!
    @IBOutlet var btnTwoDays: UIButton!
    @IBOutlet var btnOneWeek: UIButton!
    @IBOutlet var btnOneMonth: UIButton!
    @IBOutlet var btnTreeMonths: UIButton!
    @IBOutlet var viewCargaDatos: UIView!
    @IBOutlet var viewNoHaseleccionadoEventos: UIView!
    
    
    
    //Posicion del usuario
    var userLocation:CLLocation?;
    
    var locationManager = CLLocationManager();
    //var mapView : GMSMapView!;
    
    //Zoom del mapa al iniciar
    let zoomLevel:Float = 14;
    
    //Zoom del mapa al moverse a un lugar
    let zoomLevelPlace:Float = 12;
    
    //Zoom del mapa al mostrar detalles de los delitos
    let zoomLevelDelitoDetalle:Float = 20;
    
    var myMapView: GMSMapView!
    
    //-------------- Detalle de delito -------------------
    
    var delitoDetalles:DelitoTO = DelitoTO();
    
    @IBOutlet var viewDelitoDetail: UIView!
    @IBOutlet var imgBadge: UIImageView!
    @IBOutlet var txtTituloDelito: UILabel!
    @IBOutlet var txtTiempoDelito: UILabel!
    @IBOutlet var txtDistanciaDelito: UILabel!
    @IBOutlet var txtDetalleDelito: UITextView!
    @IBOutlet var txtNumVictimas: UILabel!
    @IBOutlet var txtNumDelincuentes: UILabel!
    @IBOutlet var txtNumLikes: UILabel!
    @IBOutlet var txtNumMultimedia: UILabel!
    @IBOutlet var btnMultimedia: UIButton!
    var numLikes:Int = 0;
    
    //------- PUSH --------------
    var gcmId:String!; //Id del dispositivo
    
    //---------HELP ------------------
    
    @IBOutlet var helpViewContainer: UIView!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //navigationController?.isNavigationBarHidden = false;
        
        //Inicializa la localizacion
        initLocalizacion();
        
        //Inicializa los mapas
        initGoogleMaps();
        
        btnOneDay.backgroundColor = btnTiempoColorSelected;
        
        //Inicializa el PUSH
        initPushGCM();
        
    }
    
    
    //MARK: Funciones de push para usuario
    
    
    //Existio un error al registrar al dispositivo
    func errorDesconocidoAlRegistrarDispositivo(){
        print("Error desconocido al registrar al dispositivo");
    }
    
    //Existio un error al registrar al dispositivo
    func errorAlRegistrarDispositivo(error:String){
        print("Error al registrar al dispositivo \(error)");
    }
    
    func registroCorrectoDispositivo(registrationToken:String){
        print("Registro del dispositivo correcto \(registrationToken)");
        
        //Asigna gcm del dispositivo
        self.gcmId = registrationToken;
        
        //Registra el dispositivo en el servidor
        let controller:Controller = Controller();
        controller.registrarDispositivo(idDevice: gcmId);
    }
    
    func mensajePushRecibido(info:Dictionary<String,AnyObject>){
        print("Mensaje recibido correctamente \(info)");
        
        
        let netRes:NetResponse = NetResponse(dataDictionary: info);
        print(netRes.toString());
        
        if(netRes.code == 1){
            manageNotificationPushRecibida(netRes: netRes);
        }
    }
    
    
    //Se solicita se muestre una notificacion al usuario
    func manageNotificationPushRecibida(netRes:NetResponse){
        
        if(netRes.data == nil){
            print("Data es nulo");
            return;
        }
        
        let controller:Controller = Controller();
        
        //let settings = UIApplication.sharedApplication().currentUserNotificationSettings();
        
        let delitoNotificacion:NotificacionDelitoEvento = NotificacionDelitoEvento(dataString: netRes.data!);
        
        if(delitoNotificacion.id_usuario == controller.getUserId()){
            print("Notificacion del usuario local, no mostrar notificacion");
            return;
        }
        
        //Obtiene el delito numDelito:Int, idDelito:Int
        
        let delito:DelitoTO = controller.getDelitoDetails(numDelito:delitoNotificacion.id_num_delito, idDelito: delitoNotificacion.id_evento);
        
        
        delitoDetalles = delito;
        
        let pinLocation:CLLocation = CLLocation(latitude: delito.num_latitud, longitude: delito.num_longitud);
        let distance:CLLocationDistance = (userLocation?.distance(from: pinLocation))!;
        
        if(distance > Constantes.MAX_DISTANCIA_NOTIFICACION && netRes.id != -999){
            print("El evento ha ocurrido a mas de 1,000 metros (\(distance)), no se notifica")
            return;
        }
        
       
        
        let nombreDelito:String = Controller.getDelitoStrByType(tipo: delito.id_tipo_delito);
        let distanciaDelito:String = StringUtils.getDistance(distance: distance);
        //Crea la notificacion
        let messageBody:String = "\(netRes.message!), \(nombreDelito) a \(distanciaDelito) de ti";
        showNotification( messageBody: messageBody );
        
        //Crea la alerta en la ventana para ver el delito
        let alert = UIAlertController(title: "PrevenT", message: messageBody, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ver", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in self.showDelitoDetails(delito: delito)}));
        
        
        alert.addAction(UIAlertAction(title: "Cerrar", style: UIAlertActionStyle.default, handler: nil ))
        self.present(alert, animated: true, completion: nil);
    }
    
    
    
    //====================== TERMINAN FUNCIONES PUSH ====================================================================
    
    
    override func viewWillAppear(_ animated: Bool) {
        let controller:Controller = Controller();
        
        if(!controller.firstTimeRun()){
            //marca como seleccionados todos los delitos
            for i in 0...Constantes.CANT_MAXIMA_DELITOS{
            //for(var i = 0; i <= Constantes.CANT_MAXIMA_DELITOS; i += 1){
                controller.setDelitoSelected(idDelito: i, estado: true);
            }
            
            //Deshabilita los delitos que ya no aplican
            controller.setDelitoSelected(idDelito: Constantes.TIPO_DELITO_MOVIMIENTOS_SOCIALES, estado: false);
            
            
            
            performSegue(withIdentifier: "home2Intro", sender: self);
            controller.setFirstTimeRun(estado: true); //Indica que ya se corrio una vez
            return;
        }
        
        
        
        myMapView.clear()
        loadDelitos()
        viewDelitoDetail.isHidden = true;
        timeBarSetup();
        viewCargaDatos.isHidden = true;
        
        if(!controller.showHelp()){
            helpViewContainer.isHidden = true;
            //Oculta la barra de navegación
            self.navigationController?.isNavigationBarHidden = false;
        }else{
            helpViewContainer.isHidden = false;
            //Oculta la barra de navegación
            self.navigationController?.isNavigationBarHidden = true;
        }
        
        
        let countDelitosSeleccionados = controller.getCountDelitosSeleccionados();
        
        if(countDelitosSeleccionados == 0){
            viewNoHaseleccionadoEventos.isHidden = false;
        }else{
            viewNoHaseleccionadoEventos.isHidden = true;
        }
        //print("Delitos seleccionados \(countDelitosSeleccionados)");
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func timeBarSetup(){
        btnOneWeek.isEnabled  = false;
        btnOneMonth.isEnabled = false;
        btnTreeMonths.isEnabled = false;
        
        btnOneWeek.setTitleColor(UIColor.gray, for: .normal)
        btnOneMonth.setTitleColor(UIColor.gray, for: .normal)
        btnTreeMonths.setTitleColor(UIColor.gray, for: .normal)
        
        let controller:Controller = Controller();
        
        if(controller.getUserId() > 0){
            btnOneWeek.isEnabled  = true;
            btnOneWeek.setTitleColor(UIColor.white, for: .normal)
        }
        
        if(controller.getUserPro() > 0){
            btnOneWeek.isEnabled  = true;
            btnOneMonth.isEnabled = true;
            btnTreeMonths.isEnabled = true;
            
            btnOneWeek.setTitleColor(UIColor.white, for: .normal)
            btnOneMonth.setTitleColor(UIColor.white, for: .normal)
            btnTreeMonths.setTitleColor(UIColor.white, for: .normal)
        }
        
        
        //TODO version con todo abierto
        btnOneWeek.isEnabled  = true;
        btnOneMonth.isEnabled = true;
        btnTreeMonths.isEnabled = true;
        
        btnOneWeek.setTitleColor(UIColor.white, for: .normal)
        btnOneMonth.setTitleColor(UIColor.white, for: .normal)
        btnTreeMonths.setTitleColor(UIColor.white, for: .normal)
    }
    
    
    
    //---------------- Autocomplete de direccion
    
    @IBAction func autoCompleteClicked(sender: AnyObject) {
        let autocompleteController = GMSAutocompleteViewController();
        autocompleteController.delegate = self;
        self.present(autocompleteController, animated: true, completion: nil);
    }
    
    
    @IBAction func autoCompleteTouchDown(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController();
        autocompleteController.delegate = self;
        self.present(autocompleteController, animated: true, completion: nil);
    }
    
   /*
    @IBAction func autoCompleteTextClicked(sender: AnyObject) {
        let autocompleteController = GMSAutocompleteViewController();
        autocompleteController.delegate = self;
        self.present(autocompleteController, animated: true, completion: nil);
    }
 */
    
    @IBAction func autoCompleteTouchUpInside(_ sender: Any) {
        let autocompleteController = GMSAutocompleteViewController();
        autocompleteController.delegate = self;
        self.present(autocompleteController, animated: true, completion: nil);
    }
    
    
    /*
    @IBAction func autoCompleteTextTouch(sender: AnyObject) {
        let autocompleteController = GMSAutocompleteViewController();
        autocompleteController.delegate = self;
        self.present(autocompleteController, animated: true, completion: nil);
    }
    */
    
    
    //MARK =============== HELP =================
    @IBAction func hideHelpAction(sender: AnyObject) {
        let controller:Controller = Controller();
        helpViewContainer.isHidden = true;
        controller.hideHelp();
        //Muestra la barra de navegación
        self.navigationController?.isNavigationBarHidden = false;
    }
    
    
    //MARK:  MAPAS ------------------------
    
   
    
    
    private func initGoogleMaps(){
        //Posicion inicial de la camara México
        let camera = GMSCameraPosition.camera(withLatitude: 23.364303,longitude: -111.5866852, zoom: zoomLevel);
        
        
        myMapView = GMSMapView.map(withFrame: CGRect(x:0, y:0,  width:self.view.bounds.width, height:self.view.bounds.height), camera:camera)
        self.myMapView.animate(to: camera);
        myMapView.delegate = self;
        myMapView.isMyLocationEnabled = true
        myMapView.settings.myLocationButton = true;
        myMapView.settings.compassButton = true;
        
        
        self.viewContainer.addSubview(myMapView);
    }
    
    
    /*
     ---------------- Servicio de localización
     */
    
    private func initLocalizacion(){
        //Servicios de localización
        self.locationManager.delegate = self;
        self.locationManager.requestWhenInUseAuthorization();
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.startUpdatingLocation();
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print("locationManager Update");
        
        //Localización del usuario
        userLocation = locations[0] as CLLocation;
        
        locationManager.stopUpdatingLocation();
        
        
        
        //actualiza la camara a la posicion del usuario
        //Posicion inicial de la camara México
        let camera = GMSCameraPosition.camera(withLatitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude, zoom: zoomLevel);
        self.myMapView.animate(to: camera);
        
        
        //Una vez que se tiene la posicion del usuario de piden los delitos
        loadDelitos();
        
        //Si se pide que muestre un delito
        if((delitoDetalles.id_evento) != nil ){
            addMarker(delito:delitoDetalles);
            showDelitoDetails(delito: delitoDetalles);
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error");
    }
    
    

   
    
    
    //Carga los delitos de manera asincrona
    func loadDelitos(){
        
        myMapView.clear();
        loadDelitosCount += 1
        //print("loadDelitosCount \(loadDelitosCount)");
        
        
        if( (userLocation) != nil){
            let controller = Controller();
            
            viewCargaDatos.isHidden = false;
            loaderCount = 0;
            
            //for( var i = 1; i <= Constantes.CANT_MAXIMA_DELITOS; i += 1){
            for i in 0...Constantes.CANT_MAXIMA_DELITOS{
                if(controller.isDelitoSelected(idDelito: i)){
                    self.loaderCount += 1;
                    controller.getDelitosByTipo(idTipo: i, tiempoDias: tiempoDias, lat: userLocation!.coordinate.latitude, lon: userLocation!.coordinate.longitude ,  viewHandlerDelitos: loadDelitosCallBack)
                }
            }
        }
        
    }
    
    var loaderCount: Int = 0
    
    func loadDelitosCallBack(delitosList:[DelitoTO]){
        self.loaderCount -= 1;
        //print("Loader count \(self.loaderCount)");
        if(self.loaderCount <= 1){
            DispatchQueue.main.async() { [unowned self] in
                //CozyLoadingActivity.show("Cargando delitos...", disableUI: true)
                self.viewCargaDatos.isHidden = true;
            }
        }
        
        
        
        for d in delitosList{
            //Correr en el thread principal
            DispatchQueue.main.async() { [unowned self] in
                self.addMarker(delito:d);
            }
        }
    }
    
    
    
    func addMarker(delito: DelitoTO){
        //print("Agregando marcador \(delito.id_tipo_delito)");
        
        let cont = Controller();
        let ico = cont.getMarkerIcoByType(tipo: delito.id_tipo_delito);
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(delito.num_latitud, delito.num_longitud);
        
        
        marker.appearAnimation = GMSMarkerAnimation.pop;
        marker.icon = UIImage(named: ico);
        marker.infoWindowAnchor = CGPoint(x:0.44, y:0.45);
        marker.snippet = "\(delito.id_evento!)-\(delito.id_num_delito!)"
        marker.map = self.myMapView
        
        //print("Snippet \(marker.snippet)")
    }
    
    
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        hideDelitoDetails();
    }
    
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        viewDelitoDetail.isHidden = true;
        
        let delitoData:[String] = marker.snippet!.components(separatedBy:"-");
        
        let idDelito:String  = delitoData[0];
        let numDelito:String = delitoData[1];
        
        
        
        let controller:Controller =  Controller();
        
        delitoDetalles = controller.getDelitoDetails(numDelito:numDelito, idDelito: idDelito);
        
        showDelitoDetails(delito: delitoDetalles);
        
        return true;
    }
    

    
    func showDelitoDetails(delito:DelitoTO){
        DispatchQueue.main.async() {
            
            self.addMarker(delito:delito);
            
            let pinLocation:CLLocation = CLLocation(latitude: delito.num_latitud, longitude: delito.num_longitud);
            
            let distance:CLLocationDistance = (self.userLocation?.distance(from: pinLocation))!;
            
            let camera = GMSCameraPosition.camera( withLatitude: delito.num_latitud, longitude: delito.num_longitud, zoom: self.zoomLevelDelitoDetalle)
            self.myMapView.animate(to: camera);
            
            self.imgBadge.image = Controller.getDelitoIco(tipo: self.delitoDetalles.id_tipo_delito)
            self.txtTituloDelito.text = Controller.getDelitoStrByType(tipo: self.delitoDetalles.id_tipo_delito);
            
            if((self.delitoDetalles.fch_delito) != nil){
                self.txtTiempoDelito.text = StringUtils.getNumberOfDays( time: self.delitoDetalles.fch_delito )
            }else{
                self.txtTiempoDelito.text = "Hoy";
            }
            self.txtDistanciaDelito.text = "\(StringUtils.getDistance( distance: distance)) de tí"
            
            self.txtDetalleDelito.text = "\(self.delitoDetalles.txt_resumen)\r\n\(self.delitoDetalles.txt_descripcion_lugar)";
            
            self.txtNumDelincuentes.text = "\(self.delitoDetalles.num_delincuentes)"
            self.txtNumLikes.text = "\(self.delitoDetalles.num_likes)";
            self.txtNumVictimas.text = "\(self.delitoDetalles.num_victimas)";
            self.txtNumMultimedia.text = "\(self.delitoDetalles.multimedia.count)";
            
            if((self.delitoDetalles.num_likes) != nil){
                self.numLikes = self.delitoDetalles.num_likes;
            }else{
                self.numLikes = 0;
            }
            
            if(self.delitoDetalles.multimedia.count == 0){
                self.btnMultimedia.isEnabled = false;
            }else{
                self.btnMultimedia.isEnabled = true;
            }
            
            self.viewDelitoDetail.isHidden = false;
            
            self.myMapView.settings.scrollGestures = false
            self.myMapView.settings.zoomGestures = false
        }
    }
    
    
    func hideDelitoDetails(){
        
        myMapView.settings.scrollGestures = true
        myMapView.settings.zoomGestures = true
        viewDelitoDetail.isHidden = true;
    }
    
    
    
    //Clic al like del delito
    @IBAction func likeAction(sender: UIButton) {
        let controller:Controller = Controller();
        
        let res = controller.addPoint(idEvento: delitoDetalles.id_evento, numDelito: delitoDetalles.id_num_delito, vhNetResponse: likeActionHandler);
        
        if(res == -1){
            self.view.makeToast(message: "Debes iniciar sesión para poder dar like")
        }
    }
    
    
    func likeActionHandler(netRes:NetResponse){
        //print("Like reponse")
        
        //Mensaje a mostar en el toast
        var message:String = ""
        switch(netRes.code!){
        case 1:
            
            DispatchQueue.main.async(execute: {
                // code here
                self.numLikes += 1;
                self.txtNumLikes.text = "\(self.numLikes)";
            });
            //print("Se ha registrado tu like correctamente");
            message = "Se ha registrado tu like correctamente"
            
            break;
        case 0:
            //print("No puedes dar like a tus reportes");
            message = "No puedes dar like a tus reportes"
            break;
        case -1:
            //print("Ha ocurrido un error, intentelo más tarde");
            message = "Ha ocurrido un error, intentalo más tarde"
            break;
        case -2:
            //print("Ya ha dado like a este reporte");
            message = "Ya has dado like a este reporte"
            break;
        default:
            break;
        }
        
        
        DispatchQueue.main.async() { [unowned self] in
            self.view.makeToast(message: message);
        }
    }
    
    
    
    //------------ TIEMPOS -----------------------
    
    func clearTimeSelection(){
        btnOneDay.backgroundColor = nil;
        btnTwoDays.backgroundColor = nil;
        btnOneWeek.backgroundColor = nil;
        btnOneMonth.backgroundColor = nil;
        btnTreeMonths.backgroundColor = nil;
    }
    
    
    @IBAction func oneDayAction(sender: AnyObject) {
        clearTimeSelection();
        btnOneDay.backgroundColor = btnTiempoColorSelected;
        
        tiempoDias = 1;
        loadDelitos();
    }
    
    
    @IBAction func twoDayAction(sender: UIButton) {
        clearTimeSelection();
        
        btnTwoDays.backgroundColor = btnTiempoColorSelected;
        tiempoDias = 2;
        loadDelitos();
    }
    
    
    @IBAction func oneWeekAction(sender: UIButton) {
        clearTimeSelection();
        btnOneWeek.backgroundColor = btnTiempoColorSelected;
        tiempoDias = 3;
        loadDelitos();
    }
    
    @IBAction func oneMonthAction(sender: UIButton) {
        clearTimeSelection();
        btnOneMonth.backgroundColor = btnTiempoColorSelected;
        tiempoDias = 4;
        loadDelitos();
    }
    
    @IBAction func treeMonthAction(sender: UIButton) {
        clearTimeSelection();
        btnTreeMonths.backgroundColor = btnTiempoColorSelected;
        tiempoDias = 5;
        loadDelitos();
    }
    
    
    
    
    
    //Antes de hacer el Segue
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        //print(identifier)
        if (identifier == "home2PuntoEventoSegue") {
            //Valida que el usuario esté logeado
            let controller: Controller = Controller();
            if(controller.getUserId() < 1){
                
                let alert = UIAlertView()
                alert.title = ""
                alert.message = "Debes iniciar sesión para poder reportar eventos";
                alert.addButton(withTitle: "Ok");
                alert.show();
                
                return false;
            }
            
            
            
        }
        
        if(identifier == "home2Gallery"){
            if(delitoDetalles.multimedia.count == 0){
                return false;
            }
        }
        
        return true;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "home2Gallery"){
            let destinationVC = segue.destination as! GalleryViewController
            destinationVC.multimedia = delitoDetalles.multimedia;
            destinationVC.numDelito = delitoDetalles.id_num_delito;
            destinationVC.idEvento = delitoDetalles.id_evento;
        }
        
        if (segue.identifier == "home2PuntoEventoSegue") {
            let center:CLLocationCoordinate2D = myMapView.camera.target;
            let destination:WizardSelectMapViewController = segue.destination as! WizardSelectMapViewController;
            destination.latitud = center.latitude;
            destination.longitud = center.longitude;
        }
    }
    
    func centerMap(location:CLLocationCoordinate2D){
        let camera = GMSCameraPosition.camera(withTarget: location, zoom: zoomLevelPlace);
        self.myMapView.animate(to: camera);
    }
    
} //Cierra clase


extension ViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController!, didAutocompleteWith place: GMSPlace!) {
        /*
         print("Place name: ", place.name)
         print("Place address: ", place.formattedAddress)
         print("Place attributions: ", place.attributions)
         print("Place latitude: ", place.coordinate.latitude)
         print("Place longitude: ", place.coordinate.longitude)
         */
        DispatchQueue.main.async() {
            self.centerMap(location: place.coordinate);
            
            //Agrega un marcador a la posicion seleccionada
            self.addMarker(place:place);
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func addMarker(place: GMSPlace){
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude);
        
        //print("\(place.coordinate.latitude) , \(place.coordinate.longitude)")
        
        marker.appearAnimation = GMSMarkerAnimation.pop;
        marker.title = place.name;
        marker.map = self.myMapView
    }
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error)
    }
    
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func viewController(viewController: GMSAutocompleteViewController!, didFailAutocompleteWithError error: NSError!) {
        
    }
    
    
    //------------------------------------------------------------------------------------------------------------------------------------------
    //----------------------------------- FUNCIONES AGREGADAS PARA EL PUSH ---------------------------------------------------------------------
    //------------------------------------------------------------------------------------------------------------------------------------------
    private func initPushGCM(){
        //Mensajes push
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.updateRegistrationStatus),name: NSNotification.Name(rawValue: appDelegate.registrationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.showReceivedMessage),name: NSNotification.Name(rawValue: appDelegate.messageKey), object: nil)
    }
    
    @objc func updateRegistrationStatus(notification: NSNotification) {
        
        if let info:Dictionary<String,String> = notification.userInfo as? Dictionary<String,String> {
            if let error = info["error"] {
                errorAlRegistrarDispositivo(error: info["error"]!);
            } else if let _ = info["registrationToken"] {
                registroCorrectoDispositivo(registrationToken: info["registrationToken"]!);
            }
        } else {
            //print("Software failure. Guru meditation.")
            errorDesconocidoAlRegistrarDispositivo();
        }
    }
    
    
    
    //Recepcion de notificacion
    @objc func showReceivedMessage(notification: NSNotification) {
        if let info = notification.userInfo as? Dictionary<String,AnyObject> {
            mensajePushRecibido(info: info);
            
        } else {
            print("Software failure. Guru meditation.")
        }
    }
    
    
    //Crea la notificacion
    func showNotification(messageBody:String){
        let settings = UIApplication.shared.currentUserNotificationSettings
        
        if settings!.types == .none {
            let ac = UIAlertController(title: "Can't schedule", message: "Either we don't have permission to schedule notifications, or we haven't asked yet.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(ac, animated: true, completion: nil)
            return
        }
        
        let notification = UILocalNotification()
        notification.fireDate = Date(timeIntervalSinceNow: 1)
        notification.alertBody = messageBody;
        //notification.alertAction = "Notificación de eBrigth"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["CustomField1": "w00t"]
        
        
        UIApplication.shared.scheduleLocalNotification(notification)
        
    }
    
    
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

