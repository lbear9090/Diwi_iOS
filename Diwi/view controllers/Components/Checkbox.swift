import UIKit

class Checkbox: UIButton {
    
    var isChecked = false
    var image = UIImage.Diwi.checkbox
    var activeColor = UIColor.black.cgColor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        layer.cornerRadius = 3
        layer.masksToBounds = true
        setUnchecked()
    }
    
    func setChecked() {
        isChecked = true
        layer.backgroundColor = activeColor
        setBackgroundImage(image, for: .normal)
    }
    
    func setUnchecked() {
        isChecked = false
        layer.backgroundColor = UIColor.white.cgColor
        setBackgroundImage(nil, for: .normal)
    }
    
    func toggle() {
        if (isChecked) {
            setUnchecked()
        }
        else {
            setChecked()
        }
    }
}
