import UIKit
import RxSwift
import RxCocoa

class AppTextFieldView:UIView {
    let textField = UITextField()
    let underline = UIView()
    let button = UIButton()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setup() {
        setupUnderline()
        setupImageView()
        setupTextField()
    }
    
    fileprivate func setupUnderline() {
        underline.translatesAutoresizingMaskIntoConstraints = false
        underline.backgroundColor = UIColor.Diwi.azure
        addSubview(underline)
        
        NSLayoutConstraint.activate([
            underline.leftAnchor.constraint(equalTo: leftAnchor),
            underline.rightAnchor.constraint(equalTo: rightAnchor),
            underline.heightAnchor.constraint(equalToConstant: 1),
            underline.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    fileprivate func setupImageView() {
        button.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(button)
    }
    public func setImage(_ image:UIImage, height: CGFloat = 28, width: CGFloat = 28) {
        //set image here
        button.setBackgroundImage(image, for: .normal)
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: width),
            button.heightAnchor.constraint(equalToConstant: height),
            button.rightAnchor.constraint(equalTo: rightAnchor),
            button.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -5)
        ])
        
    }
    
    fileprivate func setupTextField() {
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.Diwi.floatingButton
        textField.textColor = UIColor.Diwi.brownishGrey
        addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 28),
            textField.leftAnchor.constraint(equalTo: leftAnchor),
            textField.rightAnchor.constraint(equalTo: button.leftAnchor),
            textField.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        
    }
    
    public func setTitle(_ title:String) {
        textField.text = title
    }
    
}
