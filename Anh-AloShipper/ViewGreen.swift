
import UIKit
import Firebase
import MapKit

class ViewGreen: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, AloController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var btnFind: UIButton!
    
    private var locationManager = CLLocationManager();
    private var userLocation: CLLocationCoordinate2D?;
    private var driverLocation: CLLocationCoordinate2D?;
    private var timer = Timer();
    private var canCallShipper = true;
    private var riderCanceledRequest = false;
    private var appStartedForTheFirstTime = true;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeLocationManager();
        AloHandler.Instance.observeMessagesForUser();
        AloHandler.Instance.delegate = self;
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
            if driverLocation != nil {
                if !canCallShipper {
                    let driverAnnotation = MKPointAnnotation();
                    driverAnnotation.coordinate = driverLocation!;
                    driverAnnotation.title = "Driver Location";
                    mapView.addAnnotation(driverAnnotation);
                }
            }
            let annotation = MKPointAnnotation();
            annotation.coordinate = userLocation!;
            annotation.title = "Drivers Location";
            mapView.addAnnotation(annotation);
        }
    }
    
    func updateRidersLocation() {
        AloHandler.Instance.updateUserLocation(lat: userLocation!.latitude, long: userLocation!.longitude);
    }
    
    func canCallShipper(delegateCalled: Bool) {
        if delegateCalled {
           btnFind.setTitle("Cancel Shipper", for: UIControlState.normal);
            canCallShipper = false;
        } else {
            btnFind.setTitle("Call Shipper", for: UIControlState.normal);
            canCallShipper = true;
        }
    }

    func shipperAcceptedRequest(requestAccepted: Bool, driverName: String) {
        if !riderCanceledRequest {
            if requestAccepted {
                alertMessage(title: "Shipper Accepted", message: "\(driverName) Accepted Your Shipper Request")
            } else {
                AloHandler.Instance.cancelAlo()
                timer.invalidate();
                alertMessage(title: "Shipper Canceled", message: "\(driverName) Canceled Shipper Request")
            }
        }
        riderCanceledRequest = false;
    }
    
    func updateShipperLocation(lat: Double, long: Double) {
        driverLocation = CLLocationCoordinate2D(latitude: lat, longitude: long);
    }
    
    @IBAction func abtnFindShipper(_ sender: Any) {
        if userLocation != nil {
            if canCallShipper {
                AloHandler.Instance.requestAlo(latitude: Double(userLocation!.latitude), longitude: Double(userLocation!.longitude))
                
                timer = Timer.scheduledTimer(timeInterval: TimeInterval(10), target: self, selector: #selector(ViewGreen.updateRidersLocation), userInfo: nil, repeats: true);
                
            } else {
                riderCanceledRequest = true;
                AloHandler.Instance.cancelAlo();
                timer.invalidate();
            }
        }
    }
    
    @IBAction func abtnLogout(_ sender: Any) {
        if AuthProvider.Instance.logOut() {
            if !canCallShipper {
                AloHandler.Instance.cancelAlo();
                timer.invalidate();
            }
            dismiss(animated: true, completion: nil);
        } else {
            alertMessage(title: "Could Not Logout", message: "We could not logout at the moment, please try again later");
        }
    }
    
    private func alertMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil);
        alert.addAction(ok);
        present(alert, animated: true, completion: nil);
    }
}
