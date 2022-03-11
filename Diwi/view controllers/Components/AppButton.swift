import UIKit

class AppButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        layer.cornerRadius = 24
        layer.masksToBounds = true
        layer.backgroundColor = UIColor.Diwi.barney.cgColor
    }
    
    func enableButton() {
        isEnabled = true
        layer.backgroundColor = UIColor.Diwi.barney.cgColor
        alpha = 1
    }
    
    func EnableButton() {
        isEnabled = true
        layer.backgroundColor = UIColor.white.cgColor
        alpha = 1
    }
    
    func disableButton() {
        isEnabled = false
        layer.backgroundColor = UIColor.Diwi.barney.cgColor
        alpha = 0.5
    }
    
    func inverseColor() {
        layer.backgroundColor = UIColor.clear.cgColor
        layer.borderColor = UIColor.Diwi.barney.cgColor
        layer.borderWidth = 2
    }
}
