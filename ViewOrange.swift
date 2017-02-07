import UIKit
import Firebase

class ViewOrange: UIViewController {
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPass: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func abtnSave(_ sender: Any) {
        if txtEmail.text != "" && txtPass.text != "" {
            AuthProvider.Instance.signUp(withEmail: txtEmail.text!, password: txtPass.text!, loginHandler: { (message) in
                if message != nil {
                    self.alertMessage(title: "Problem With Creating A New User", message: message!);
                } else {
                    AloHandler.Instance.user = self.txtEmail.text!;
                    self.txtEmail.text = "";
                    self.txtPass.text = "";
                    let nextView = self.storyboard?.instantiateViewController(withIdentifier: "viewpurple") as! ViewPurple
                    self.present(nextView, animated: true, completion: nil)
                }
            });
        } else {
            alertMessage(title: "Email And Password Are Required", message: "Please enter email and password in the text fields");
        }
        
    }
    
    private func alertMessage(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert);
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil);
        alert.addAction(ok);
        present(alert, animated: true, completion: nil);
    }
    
    
}
