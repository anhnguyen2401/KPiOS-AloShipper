import UIKit

class ViewPink: UIViewController {
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPass: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func abtnLogin(_ sender: Any) {
        if txtEmail.text != "" && txtPass.text != "" {
            AuthProvider.Instance.login(email: txtEmail.text!, password: txtPass.text!, loginHandler: { (message) in
                if message != nil {
                    self.alertMessage(title: "Problem With Authentication", message: message!);
                } else {
                    ShipperHandler.Instance.shipper = self.txtEmail.text!;
                    self.txtEmail.text = "";
                    self.txtPass.text = "";
                    let nextView = self.storyboard?.instantiateViewController(withIdentifier: "viewblue") as! ViewBlue
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
