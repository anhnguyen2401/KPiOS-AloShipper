import Foundation
import FirebaseDatabase

class DBProvider {
    private static let _instance = DBProvider();
    
    static var Instance: DBProvider {
        return _instance;
    }
    
    var dbRef: FIRDatabaseReference {
        return FIRDatabase.database().reference();
    }
    
    var ridersRef: FIRDatabaseReference {
        return dbRef.child(Constants.USER);
    }
    
    var requestRef: FIRDatabaseReference {
        return dbRef.child(Constants.ALO_REQUEST);
    }
    
    var requestAcceptedRef: FIRDatabaseReference {
        return dbRef.child(Constants.ALO_ACCEPTED);
    }
    
    func saveUser(withID: String, email: String, password: String) {
        let data: Dictionary<String, Any> = [Constants.EMAIL: email, Constants.PASSWORD: password, Constants.isUser: true];
        ridersRef.child(withID).child(Constants.DATA).setValue(data);
    }
    
} // class
