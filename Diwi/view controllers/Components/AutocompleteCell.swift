import UIKit
import Kingfisher

class AutocompleteCell: UITableViewCell {
    
    static var identifier: String = "Cell"
    
    let label = UILabel()
    let checkbox = Checkbox()
    var tagData:Tag = Tag() {
        didSet {
            label.text = tagData.title
            update()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    func setup() {
        selectionStyle = .none
        
        checkbox.translatesAutoresizingMaskIntoConstraints = false
        checkbox.image = UIImage.Diwi.checkboxBlue
        checkbox.activeColor = UIColor.white.cgColor
        checkbox.layer.borderWidth = 1
        checkbox.layer.borderColor = UIColor.Diwi.azure.cgColor
        checkbox.layer.cornerRadius = 4
        checkbox.isUserInteractionEnabled = false
        contentView.addSubview(checkbox)
        update()
        
        NSLayoutConstraint.activate([
            checkbox.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkbox.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 18),
            checkbox.widthAnchor.constraint(equalToConstant: 18),
            checkbox.heightAnchor.constraint(equalToConstant: 18)
            ])
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = tagData.title
        label.textColor  = UIColor.Diwi.darkGray
        label.font = UIFont.Diwi.floatingButton
        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            label.leftAnchor.constraint(equalTo: checkbox.rightAnchor, constant: 10)
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func update() {
        if (tagData.selected) {
            checkbox.setChecked()
        }
        else {
            checkbox.setUnchecked()
        }
    }
    func toggle() {
        if tagData.selected {
            tagData.selected = false
            checkbox.setUnchecked()
            return
        }
        else {
            tagData.selected = true
            checkbox.setChecked()
            return
        }
    }
}
