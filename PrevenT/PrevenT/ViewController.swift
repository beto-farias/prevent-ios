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
import GoogleMaps

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    let controller:Controller = Controller();
    let btnTiempoColorSelected = UIColor(netHex: 0xE2652A);
    
    
    @IBOutlet var viewContainer: UIView!
    
    //Esta variable debe cambiar segun la seleccion del usuaro
    var tiempoDias = 1;
    
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
    @IBOutlet var imgBadge: DesignableImageView!
    @IBOutlet var txtTituloDelito: DesignableLabel!
    @IBOutlet var txtTiempoDelito: DesignableLabel!
    @IBOutlet var txtDistanciaDelito: UILabel!
    @IBOutlet var txtDetalleDelito: DesignableTextView!
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
        controller.registrarDispositivo(gcmId);
    }
    
    func mensajePushRecibido(info:Dictionary<String,AnyObject>){
        print("Mensaje recibido correctamente \(info)");
        
        
        let netRes:NetResponse = NetResponse(dataDictionary: info);
        print(netRes.toString());
        
        if(netRes.code == 1){
            manageNotificationPushRecibida(netRes);
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
        
        let delito:DelitoTO = controller.getDelitoDetails(delitoNotificacion.id_num_delito, idDelito: delitoNotificacion.id_evento);
        
        
        delitoDetalles = delito;
        
        let pinLocation:CLLocation = CLLocation(latitude: delito.num_latitud, longitude: delito.num_longitud);
        let distance:CLLocationDistance = (userLocation?.distanceFromLocation(pinLocation))!;
        
        if(distance > Constantes.MAX_DISTANCIA_NOTIFICACION && netRes.id != -999){
            print("El evento ha ocurrido a mas de 1,000 metros (\(distance)), no se notifica")
            return;
        }
        
       
        
        let nombreDelito:String = Controller.getDelitoStrByType(delito.id_tipo_delito);
        let distanciaDelito:String = StringUtils.getDistance(distance);
        //Crea la notificacion
        let messageBody:String = "\(netRes.message!), \(nombreDelito) a \(distanciaDelito) de ti";
        showNotification( messageBody );
        
        //Crea la alerta en la ventana para ver el delito
        let alert = UIAlertController(title: "PrevenT", message: messageBody, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Ver", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in self.showDelitoDetails(delito)}));
        
        
        alert.addAction(UIAlertAction(title: "Cerrar", style: UIAlertActionStyle.Default, handler: nil ))
        self.presentViewController(alert, animated: true, completion: nil);
    }
    
    
    
    //====================== TERMINAN FUNCIONES PUSH ====================================================================
    
    
    override func viewWillAppear(animated: Bool) {
        let controller:Controller = Controller();
        
        if(!controller.firstTimeRun()){
            //marca como seleccionados todos los delitos
            for(var i = 0; i <= Constantes.CANT_MAXIMA_DELITOS; i += 1){
                controller.setDelitoSelected(i, estado: true);
            }
            
            //Deshabilita los delitos que ya no aplican
            controller.setDelitoSelected(Constantes.TIPO_DELITO_MOVIMIENTOS_SOCIALES, estado: false);
            
            
            
            performSegueWithIdentifier("home2Intro", sender: self);
            controller.setFirstTimeRun(true); //Indica que ya se corrio una vez
            return;
        }
        
        
        
        myMapView.clear()
        loadDelitos()
        viewDelitoDetail.hidden = true;
        timeBarSetup();
        viewCargaDatos.hidden = true;
        
        if(!controller.showHelp()){
            helpViewContainer.hidden = true;
            //Oculta la barra de navegación
            self.navigationController?.navigationBarHidden = false;
        }else{
            helpViewContainer.hidden = false;
            //Oculta la barra de navegación
            self.navigationController?.navigationBarHidden = true;
        }
        
        
        let countDelitosSeleccionados = controller.getCountDelitosSeleccionados();
        
        if(countDelitosSeleccionados == 0){
            viewNoHaseleccionadoEventos.hidden = false;
        }else{
            viewNoHaseleccionadoEventos.hidden = true;
        }
        //print("Delitos seleccionados \(countDelitosSeleccionados)");
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func timeBarSetup(){
        btnOneWeek.enabled  = false;
        btnOneMonth.enabled = false;
        btnTreeMonths.enabled = false;
        
        btnOneWeek.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        btnOneMonth.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        btnTreeMonths.setTitleColor(UIColor.grayColor(), forState: UIControlState.Normal)
        
        let controller:Controller = Controller();
        
        if(controller.getUserId() > 0){
            btnOneWeek.enabled  = true;
            btnOneWeek.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        }
        
        if(controller.getUserPro() > 0){
            btnOneWeek.enabled  = true;
            btnOneMonth.enabled = true;
            btnTreeMonths.enabled = true;
            
            btnOneWeek.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            btnOneMonth.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            btnTreeMonths.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        }
        
        
        //TODO version con todo abierto
        btnOneWeek.enabled  = true;
        btnOneMonth.enabled = true;
        btnTreeMonths.enabled = true;
        
        btnOneWeek.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btnOneMonth.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btnTreeMonths.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
    
    
    //---------------- Autocomplete de direccion
    
    @IBAction func autoCompleteClicked(sender: AnyObject) {
        let autocompleteController = GMSAutocompleteViewController();
        autocompleteController.delegate = self;
        self.presentViewController(autocompleteController, animated: true, completion: nil);
    }
    
    @IBAction func autoCompleteTextClicked(sender: AnyObject) {
        let autocompleteController = GMSAutocompleteViewController();
        autocompleteController.delegate = self;
        self.presentViewController(autocompleteController, animated: true, completion: nil);
    }
    
    @IBAction func autoCompleteTextTouch(sender: AnyObject) {
        let autocompleteController = GMSAutocompleteViewController();
        autocompleteController.delegate = self;
        self.presentViewController(autocompleteController, animated: true, completion: nil);
    }
    
    
    
    //MARK =============== HELP =================
    @IBAction func hideHelpAction(sender: AnyObject) {
        let controller:Controller = Controller();
        helpViewContainer.hidden = true;
        controller.hideHelp();
        //Muestra la barra de navegación
        self.navigationController?.navigationBarHidden = false;
    }
    
    
    //MARK:  MAPAS ------------------------
    
    private func initGoogleMaps(){
        //Posicion inicial de la camara México
        let camera = GMSCameraPosition.cameraWithLatitude(23.364303,longitude: -111.5866852, zoom: zoomLevel);
        
        
        myMapView = GMSMapView.mapWithFrame(CGRectMake(0, 0,  self.view.bounds.width,self.view.bounds.height), camera:camera)
        self.myMapView.animateToCameraPosition(camera);
        myMapView.delegate = self;
        myMapView.myLocationEnabled = true
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
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print("locationManager Update");
        
        //Localización del usuario
        userLocation = locations[0] as CLLocation;
        
        locationManager.stopUpdatingLocation();
        
        
        
        //actualiza la camara a la posicion del usuario
        //Posicion inicial de la camara México
        let camera = GMSCameraPosition.cameraWithLatitude(userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude, zoom: zoomLevel);
        self.myMapView.animateToCameraPosition(camera);
        
        
        //Una vez que se tiene la posicion del usuario de piden los delitos
        loadDelitos();
        
        //Si se pide que muestre un delito
        if((delitoDetalles.id_evento) != nil ){
            addMarker(delitoDetalles);
            showDelitoDetails(delitoDetalles);
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error");
    }
    
    
    
    
    var loadDelitosCount = 0
    
    
    //Carga los delitos de manera asincrona
    func loadDelitos(){
        
        myMapView.clear();
        loadDelitosCount += 1
        //print("loadDelitosCount \(loadDelitosCount)");
        
        
        if( (userLocation) != nil){
            let controller = Controller();
            
            viewCargaDatos.hidden = false;
            loaderCount = 0;
            
            for( var i = 1; i <= Constantes.CANT_MAXIMA_DELITOS; i += 1){
                if(controller.isDelitoSelected(i)){
                    self.loaderCount += 1;
                    controller.getDelitosByTipo(i, tiempoDias: tiempoDias, lat: userLocation!.coordinate.latitude, lon: userLocation!.coordinate.longitude ,  viewHandlerDelitos: loadDelitosCallBack)
                }
            }
        }
        
    }
    
    var loaderCount: Int = 0
    
    func loadDelitosCallBack(delitosList:[DelitoTO]){
        self.loaderCount -= 1;
        //print("Loader count \(self.loaderCount)");
        if(self.loaderCount <= 1){
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                //CozyLoadingActivity.show("Cargando delitos...", disableUI: true)
                self.viewCargaDatos.hidden = true;
            }
        }
        
        
        
        for d in delitosList{
            //Correr en el thread principal
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                self.addMarker(d);
            }
        }
    }
    
    
    
    func addMarker(delito: DelitoTO){
        //print("Agregando marcador \(delito.id_tipo_delito)");
        
        let cont = Controller();
        let ico = cont.getMarkerIcoByType(delito.id_tipo_delito);
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(delito.num_latitud, delito.num_longitud);
        
        
        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.icon = UIImage(named: ico);
        marker.infoWindowAnchor = CGPointMake(0.44, 0.45);
        marker.snippet = "\(delito.id_evento)-\(delito.id_num_delito)"
        marker.map = self.myMapView
        
        //print("Snippet \(marker.snippet)")
    }
    
    
    
    
    
    func mapView(mapView: GMSMapView!, didTapAtCoordinate coordinate: CLLocationCoordinate2D) {
        //print(coordinate);
        hideDelitoDetails();
    }
    
    
    //Click en un marker
    func mapView(mapView: GMSMapView!, didTapMarker marker: GMSMarker!) -> Bool {
        viewDelitoDetail.hidden = true;
        
        //print("Snippet \(marker.snippet)")
        
        let delitoData = marker.snippet!.componentsSeparatedByString("-")
        let idDelito: String = delitoData[0]
        let numDelito: String = delitoData[1]
        
        let controller:Controller =  Controller();
        
        delitoDetalles = controller.getDelitoDetails( numDelito, idDelito: idDelito);
        
        showDelitoDetails(delitoDetalles);
        
        return true;
    }
    
    func showDelitoDetails(delito:DelitoTO){
        dispatch_async(dispatch_get_main_queue()) {
            
            self.addMarker(delito);
            
            let pinLocation:CLLocation = CLLocation(latitude: delito.num_latitud, longitude: delito.num_longitud);
            
            let distance:CLLocationDistance = (self.userLocation?.distanceFromLocation(pinLocation))!;
            
            let camera = GMSCameraPosition.cameraWithLatitude( delito.num_latitud, longitude: delito.num_longitud, zoom: self.zoomLevelDelitoDetalle)
            self.myMapView.animateToCameraPosition(camera);
            
            self.imgBadge.image = Controller.getDelitoIco(self.delitoDetalles.id_tipo_delito)
            self.txtTituloDelito.text = Controller.getDelitoStrByType(self.delitoDetalles.id_tipo_delito);
            
            if((self.delitoDetalles.fch_delito) != nil){
                self.txtTiempoDelito.text = StringUtils.getNumberOfDays( self.delitoDetalles.fch_delito )
            }else{
                self.txtTiempoDelito.text = "Hoy";
            }
            self.txtDistanciaDelito.text = "\(StringUtils.getDistance( distance)) de tí"
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
                self.btnMultimedia.enabled = false;
            }else{
                self.btnMultimedia.enabled = true;
            }
            
            self.viewDelitoDetail.hidden = false;
            
            self.myMapView.settings.scrollGestures = false
            self.myMapView.settings.zoomGestures = false
        }
    }
    
    
    func hideDelitoDetails(){
        
        myMapView.settings.scrollGestures = true
        myMapView.settings.zoomGestures = true
        viewDelitoDetail.hidden = true;
    }
    
    
    
    //Clic al like del delito
    @IBAction func likeAction(sender: UIButton) {
        let controller:Controller = Controller();
        
        let res = controller.addPoint(delitoDetalles.id_evento, numDelito: delitoDetalles.id_num_delito, vhNetResponse: likeActionHandler);
        
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
            
            dispatch_async(dispatch_get_main_queue(), {
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
        
        
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
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
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        //print(identifier)
        if (identifier == "home2PuntoEventoSegue") {
            //Valida que el usuario esté logeado
            let controller: Controller = Controller();
            if(controller.getUserId() < 1){
                
                let alert = UIAlertView()
                alert.title = ""
                alert.message = "Debes iniciar sesión para poder reportar eventos";
                alert.addButtonWithTitle("Ok");
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if(segue.identifier == "home2Gallery"){
            let destinationVC = segue.destinationViewController as! GalleryViewController
            destinationVC.multimedia = delitoDetalles.multimedia;
            destinationVC.numDelito = delitoDetalles.id_num_delito;
            destinationVC.idEvento = delitoDetalles.id_evento;
        }
        
        if (segue.identifier == "home2PuntoEventoSegue") {
            let center:CLLocationCoordinate2D = myMapView.camera.target;
            let destination:WizardSelectMapViewController = segue.destinationViewController as! WizardSelectMapViewController;
            destination.latitud = center.latitude;
            destination.longitud = center.longitude;
        }
    }
    
    func centerMap(location:CLLocationCoordinate2D){
        let camera = GMSCameraPosition.cameraWithTarget(location, zoom: zoomLevelPlace);
        self.myMapView.animateToCameraPosition(camera);
    }
    
} //Cierra clase


extension ViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(viewController: GMSAutocompleteViewController!, didAutocompleteWithPlace place: GMSPlace!) {
        /*
         print("Place name: ", place.name)
         print("Place address: ", place.formattedAddress)
         print("Place attributions: ", place.attributions)
         print("Place latitude: ", place.coordinate.latitude)
         print("Place longitude: ", place.coordinate.longitude)
         */
        dispatch_async(dispatch_get_main_queue()) {
            self.centerMap(place.coordinate);
            
            //Agrega un marcador a la posicion seleccionada
            self.addMarker(place);
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func addMarker(place: GMSPlace){
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(place.coordinate.latitude, place.coordinate.longitude);
        
        //print("\(place.coordinate.latitude) , \(place.coordinate.longitude)")
        
        marker.appearAnimation = kGMSMarkerAnimationPop;
        marker.title = place.name;
        marker.map = self.myMapView
    }
    
    func viewController(viewController: GMSAutocompleteViewController!, didAutocompleteWithError error: NSError!) {
        // TODO: handle the error.
        print("Error: ", error.description)
    }
    
    // User canceled the operation.
    func wasCancelled(viewController: GMSAutocompleteViewController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func viewController(viewController: GMSAutocompleteViewController!, didFailAutocompleteWithError error: NSError!) {
        
    }
    
    
    //------------------------------------------------------------------------------------------------------------------------------------------
    //----------------------------------- FUNCIONES AGREGADAS PARA EL PUSH ---------------------------------------------------------------------
    //------------------------------------------------------------------------------------------------------------------------------------------
    private func initPushGCM(){
        //Mensajes push
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateRegistrationStatus:",name: appDelegate.registrationKey, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "showReceivedMessage:",name: appDelegate.messageKey, object: nil)
    }
    
    func updateRegistrationStatus(notification: NSNotification) {
        
        if let info:Dictionary<String,String> = notification.userInfo as? Dictionary<String,String> {
            if let error = info["error"] {
                errorAlRegistrarDispositivo(info["error"]!);
            } else if let _ = info["registrationToken"] {
                registroCorrectoDispositivo(info["registrationToken"]!);
            }
        } else {
            //print("Software failure. Guru meditation.")
            errorDesconocidoAlRegistrarDispositivo();
        }
    }
    
    
    
    //Recepcion de notificacion
    func showReceivedMessage(notification: NSNotification) {
        if let info = notification.userInfo as? Dictionary<String,AnyObject> {
            mensajePushRecibido(info);
            
        } else {
            print("Software failure. Guru meditation.")
        }
    }
    
    
    //Crea la notificacion
    func showNotification(messageBody:String){
        let settings = UIApplication.sharedApplication().currentUserNotificationSettings()
        
        if settings!.types == .None {
            let ac = UIAlertController(title: "Can't schedule", message: "Either we don't have permission to schedule notifications, or we haven't asked yet.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
            return
        }
        
        let notification = UILocalNotification()
        notification.fireDate = NSDate(timeIntervalSinceNow: 1)
        notification.alertBody = messageBody;
        //notification.alertAction = "Notificación de eBrigth"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["CustomField1": "w00t"]
        
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
        
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

