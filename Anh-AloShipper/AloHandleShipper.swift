import Foundation
import FirebaseDatabase

protocol ShipperController: class {
    func acceptAlo(lat: Double, long: Double);
    func userCanceledShipper();
    func aloCanceled();
    func updateUserLocation(lat: Double, long: Double);
}

class ShipperHandler {
    private static let _instance = ShipperHandler();
    
    weak var delegate: ShipperController?;
    
    var user = "";
    var shipper = "";
    var shipper_id = "";
    
    static var Instance: ShipperHandler {
        return _instance;
    }
    
    func observeMessagesForShipper() {
        // USER REQUESTED A SHIPPER
        DBProvider.Instance.requestRef.observe(FIRDataEventType.childAdded) { (snapshot: FIRDataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let latitude = data[Constants.LATITUDE] as? Double {
                    if let longitude = data[Constants.LONGITUDE] as? Double {
                        self.delegate?.acceptAlo(lat: latitude, long: longitude);
                    }
                }
                if let name = data[Constants.NAME] as? String {
                    self.user = name;
                }
            }
            // USER CANCELED SHIPPER
            DBProvider.Instance.requestRef.observe(FIRDataEventType.childRemoved, with: { (snapshot: FIRDataSnapshot) in
                
                if let data = snapshot.value as? NSDictionary {
                    if let name = data[Constants.NAME] as? String {
                        if name == self.user {
                            self.user = "";
                            self.delegate?.userCanceledShipper();
                        }
                    }
                }
            });
        }
        // USER UPDATING LOCATION
        DBProvider.Instance.requestRef.observe(FIRDataEventType.childChanged) { (snapshot: FIRDataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let lat = data[Constants.LATITUDE] as? Double {
                    if let long = data[Constants.LONGITUDE] as? Double {
                        self.delegate?.updateUserLocation(lat: lat, long: long);
                    }
                }
            }
        }
        // SHIPPER ACCEPTS USER
        DBProvider.Instance.requestAcceptedRef.observe(FIRDataEventType.childAdded) { (snapshot: FIRDataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.shipper {
                        self.shipper_id = snapshot.key;
                    }
                }
            }
        }
        // SHIPPER CANCELED USER
        DBProvider.Instance.requestAcceptedRef.observe(FIRDataEventType.childRemoved) { (snapshot: FIRDataSnapshot) in
            
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.shipper {
                        self.delegate?.aloCanceled();
                    }
                }
            }
        }
    }
    
    func aloAccepted(lat: Double, long: Double) {
        let data: Dictionary<String, Any> = [Constants.NAME: shipper, Constants.LATITUDE: lat, Constants.LONGITUDE: long];
        
        DBProvider.Instance.requestAcceptedRef.childByAutoId().setValue(data);
    }
    
    func cancelForShipper() {
        DBProvider.Instance.requestAcceptedRef.child(shipper_id).removeValue();
    }
    
    func updateShipperLocation(lat: Double, long: Double) {
        DBProvider.Instance.requestAcceptedRef.child(shipper_id).updateChildValues([Constants.LATITUDE: lat, Constants.LONGITUDE: long]);
    }
    
}













































