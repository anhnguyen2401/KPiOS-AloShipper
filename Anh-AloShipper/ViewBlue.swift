
import UIKit
import MapKit

class ViewBlue: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, ShipperController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var btnAccept: UIButton!
    
    private var locationManager = CLLocationManager();
    private var userLocation: CLLocationCoordinate2D?;
    private var riderLocation: CLLocationCoordinate2D?;
    private var timer = Timer();
    private var acceptedAlo = false;
    private var driverCanceledUber = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationManager();
        ShipperHandler.Instance.delegate = self;
        ShipperHandler.Instance.observeMessagesForShipper();
    }
    
    private func initializeLocationManager() {
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.requestWhenInUseAuthorization();
        locationManager.startUpdatingLocation();
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locationManager.location?.coordinate {
            userLocation = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            let region = MKCoordinateRegion(center: userLocation!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01));
            mapView.setRegion(region, animated: true);
            mapView.removeAnnotations(mapView.annotations);
            
            if riderLocation != nil {
                if acceptedAlo {
                    let riderAnnotation = MKPointAnnotation();
                    riderAnnotation.coordinate = riderLocation!;
                    riderAnnotation.title = "Riders Location";
                    mapView.addAnnotation(riderAnnotation);
                }
            }
            
            let annotation = MKPointAnnotation();
            annotation.coordinate = userLocation!;
            annotation.title = "Drivers Location";
            mapView.addAnnotation(annotation);
            
        }
        
    }
    
    func acceptAlo(lat: Double, long: Double) {
        if !acceptedAlo {
            aloRequest(title: "AloShipper Request", message: "You have a request at this location Lat: \(lat), Long: \(long)", requestAlive: true);
        }
    }
    
    func userCanceledShipper() {
        if !driverCanceledUber {
            ShipperHandler.Instance.cancelForShipper();
            self.acceptedAlo = false;
            self.btnAccept.isHidden = true;
            aloRequest(title: "AloShipper Canceled", message: "The Rider Has Canceled", requestAlive: false);
        }
    }
    
    func aloCanceled() {
        acceptedAlo = false;
        btnAccept.isHidden = true;
        timer.invalidate();
    }
    
    func updateUserLocation(lat: Double, long: Double) {
        riderLocation = CLLocationCoordinate2D(latitude: lat, longitude: long);
    }
    
    func updateDriversLocation() {
        ShipperHandler.Instance.updateShipperLocation(lat: userLocation!.latitude, long: userLocation!.longitude);
    }
    
    @IBAction func abtnAccept(_ sender: Any) {
        if acceptedAlo {
            driverCanceledUber = true;
            btnAccept.isHidden = true;
            ShipperHandler.Instance.cancelForShipper();
            timer.invalidate();
        }
    }
    
    @IBAction func abtnLogout(_ sender: Any) {
        if AuthProvider.Instance.logOut() {
            if acceptedAlo {
                btnAccept.isHidden = true;
                ShipperHandler.Instance.cancelForShipper();
                timer.invalidate();
            }
            dismiss(animated: true, completion: nil);
            
        } else {
            aloRequest(title: "Could Not Logout", message: "We could not logout at the moment, please try again later", requestAlive: false)
        }
    }
    
    private func aloRequest(title: String, message: String, requestAlive: Bool) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        if requestAlive {
            let accept = UIAlertAction(title: "Accept", style: .default, handler: { (alertAction: UIAlertAction) in
                self.acceptedAlo = true;
                self.btnAccept.isHidden = false;
                self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(ViewBlue.updateDriversLocation), userInfo: nil, repeats: true);
                ShipperHandler.Instance.aloAccepted(lat: Double(self.userLocation!.latitude), long: Double(self.userLocation!.longitude));
            });
            let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil);
            alert.addAction(accept);
            alert.addAction(cancel);
        } else {
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil);
            alert.addAction(ok);
        }
        present(alert, animated: true, completion: nil);
    }
    
} // class
















































