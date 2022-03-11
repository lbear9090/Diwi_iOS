
import UIKit
import Firebase
import UXCam

class ViewController: UIViewController {
    
    var coordinator: MainCoordinator?
    
    @IBOutlet weak var pinkViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var blueViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var greenViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var blackViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pinkView: UIView!
    @IBOutlet weak var blueView: UIView!
    @IBOutlet weak var greenView: UIView!
    @IBOutlet weak var blackView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.5, animations: {
            self.pinkViewTopConstraint.constant = UIScreen.main.bounds.height - 10
            self.view.layoutIfNeeded()
        }, completion: {res in
            UIView.animate(withDuration: 0.5, animations: {
                self.blueViewTopConstraint.constant = UIScreen.main.bounds.height - 10
                self.view.layoutIfNeeded()
            }, completion: {res in
                UIView.animate(withDuration: 0.5, animations: {
                    self.greenViewTopConstraint.constant = UIScreen.main.bounds.height - 10
                    self.view.layoutIfNeeded()
                }, completion: {res in
                    UIView.animate(withDuration: 0.5, animations: {
                        self.blackViewTopConstraint.constant = UIScreen.main.bounds.height - 10
                        self.view.layoutIfNeeded()
                    }, completion: {res in
                        self.coordinator = MainCoordinator(navController: self.navigationController!)
                        self.coordinator?.start()
                    })
                })
            })
        })
    }
    
}

