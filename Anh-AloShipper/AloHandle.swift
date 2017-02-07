import Foundation
import FirebaseDatabase

protocol AloController: class {
    func canCallShipper(delegateCalled: Bool);
    func shipperAcceptedRequest(requestAccepted: Bool, driverName: String);
    func updateShipperLocation(lat: Double, long: Double);
}

class AloHandler {
    private static let _instance = AloHandler();
    
    weak var delegate: AloController?;
    
    var user = "";
    var shipper = "";
    var user_id = "";
    
    static var Instance: AloHandler {
        return _instance;
    }
    
    func observeMessagesForUser() {
        // USER REQUESTED SHIPPER
        DBProvider.Instance.requestRef.observe(FIRDataEventType.childAdded) { (snapshot: FIRDataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.user {
                        self.user_id = snapshot.key;
                        self.delegate?.canCallShipper(delegateCalled: true);
                    }
                }
            }
        }
        // USER CANCELED SHIPPER
        DBProvider.Instance.requestRef.observe(FIRDataEventType.childRemoved) { (snapshot: FIRDataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.user {
                        self.delegate?.canCallShipper(delegateCalled: false);
                    }
                }
            }
        }
        // SHIPPER ACCEPTED USER
        DBProvider.Instance.requestAcceptedRef.observe(FIRDataEventType.childAdded) { (snapshot: FIRDataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if self.shipper == "" {
                        self.shipper = name;
                        self.delegate?.shipperAcceptedRequest(requestAccepted: true, driverName: self.shipper);
                    }
                }
            }
        }
        // SHIPPER CANCELED USER
        DBProvider.Instance.requestAcceptedRef.observe(FIRDataEventType.childRemoved) { (snapshot:FIRDataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.shipper {
                        self.shipper = "";
                        self.delegate?.shipperAcceptedRequest(requestAccepted: false, driverName: name);
                    }
                }
            }
        }
        // SHIPPER UPDATING LOCATION
        DBProvider.Instance.requestAcceptedRef.observe(FIRDataEventType.childChanged) { (snapshot: FIRDataSnapshot) in
            if let data = snapshot.value as? NSDictionary {
                if let name = data[Constants.NAME] as? String {
                    if name == self.shipper {
                        if let lat = data[Constants.LATITUDE] as? Double {
                            if let long = data[Constants.LONGITUDE] as? Double {
                                self.delegate?.updateShipperLocation(lat: lat, long: long);
                            }
                        }
                    }
                }
            }
        }
    }
    
    func requestAlo(latitude: Double, longitude: Double) {
        let data: Dictionary<String, Any> = [Constants.NAME: user, Constants.LATITUDE: latitude, Constants.LONGITUDE: longitude];
        DBProvider.Instance.requestRef.childByAutoId().setValue(data);
    }
    
    func cancelAlo() {
        DBProvider.Instance.requestRef.child(user_id).removeValue();
    }
    
    func updateUserLocation(lat: Double, long: Double) {
        DBProvider.Instance.requestRef.child(user_id).updateChildValues([Constants.LATITUDE: lat, Constants.LONGITUDE: long]);
    }
    
}// class
















































