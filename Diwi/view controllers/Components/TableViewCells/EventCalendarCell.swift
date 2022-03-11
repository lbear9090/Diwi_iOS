import UIKit
import Kingfisher

class EventCalendarCell: UITableViewCell {
    
    static var identifier: String = "Cell"
    
    let eventName = UILabel()
    let eventDate = UILabel()
    let icon = UIButton()
    var editEvent: (() -> Void)?
    var event = Event()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }
    
    func setup(hideIcon: Bool = false, iconImage: UIImage = UIImage.Diwi.moreIcon) {
        contentView.backgroundColor = UIColor.Diwi.azure
        eventDate.translatesAutoresizingMaskIntoConstraints = false
        eventDate.font = UIFont.Diwi.title
        eventDate.textColor = UIColor.white
        eventDate.text = event.datePretty()
        contentView.addSubview(eventDate)
        
        NSLayoutConstraint.activate([
            eventDate.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            eventDate.leftAnchor.constraint(equalTo: contentView.leftAnchor)
            ])
        
        eventName.translatesAutoresizingMaskIntoConstraints = false
        eventName.font = UIFont.Diwi.floatingButton
        eventName.textColor = UIColor.white
        eventName.text = event.name
        contentView.addSubview(eventName)
        
        NSLayoutConstraint.activate([
            eventName.topAnchor.constraint(equalTo: eventDate.bottomAnchor, constant: 17),
            eventName.leftAnchor.constraint(equalTo: contentView.leftAnchor)
            ])
        
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.isHidden = hideIcon
        icon.setImage(iconImage, for: .normal)
        icon.addTarget(self, action: #selector(handleEditPress), for: .touchUpInside)
        
        
        contentView.addSubview(icon)
        
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: contentView.rightAnchor, constant: -7),
            icon.topAnchor.constraint(equalTo: eventDate.topAnchor)
            ])
        
    }
    
    @objc func handleEditPress() {
        self.editEvent?()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
