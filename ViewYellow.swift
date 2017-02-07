import UIKit
import Firebase

class ViewYellow: UIViewController {
    
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPass: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func abtnLogin(_ sender: Any) {
        if txtEmail.text != "" && txtPass.text != "" {
            AuthProvider.Instance.login(email: txtEmail.text!, password: txtPass.text!, loginHandler: { (message) in
                if message != nil {
                    self.alertMessage(title: "Problem With Authentication", message: message!);
                } else {
                    AloHandler.Instance.user = self.txtEmail.text!;
                    self.txtEmail.text = "";
                    self.txtPass.text = "";
                    let nextView = self.storyboard?.instantiateViewController(withIdentifier: "viewgreen") as! ViewGreen
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
