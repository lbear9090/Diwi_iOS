import UIKit

class SearchInput: UITextField {
    
    let searchIcon = UIImageView()
    let outerView  = UIView()
    let autocomplete = UITableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        font? = UIFont.Diwi.textField
        layer.borderColor = UIColor.white.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = 18
        autocorrectionType = .no
        backgroundColor = UIColor.Diwi.azure
        textColor = UIColor.white
        tintColor = UIColor.white
        attributedPlaceholder = NSAttributedString(string: TextContent.Labels.whoWasAtEvent,
                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        outerView.frame = CGRect(x: 0, y: 0, width: 32, height: 22)
        
        searchIcon.image = UIImage.Diwi.searchIcon
        searchIcon.frame = CGRect(x: 10,
                                  y: 0,
                                  width: 22,
                                  height: 22)
        
        outerView.addSubview(searchIcon)
        
        leftView = outerView
        
        leftViewMode = .always
    }
    
    func onFocus() {
        backgroundColor = UIColor.white
        searchIcon.image = UIImage.Diwi.searchIconBlue
        textColor = UIColor.Diwi.darkGray
        tintColor = UIColor.Diwi.azure
        attributedPlaceholder = NSAttributedString(string: TextContent.Labels.whoWasAtEvent,
                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.Diwi.azure])
    }
    
    func onBlur() {
        backgroundColor = UIColor.Diwi.azure
        searchIcon.image = UIImage.Diwi.searchIcon
        textColor = UIColor.white
        tintColor = UIColor.white
        attributedPlaceholder = NSAttributedString(string: TextContent.Labels.whoWasAtEvent,
                                                   attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
}
