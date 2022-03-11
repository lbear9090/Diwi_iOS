import UIKit
import Kingfisher

class ClosetItemCell: UITableViewCell {
    
    static var identifier: String = "Cell"
    
    let box = UIImageView()
    let eventName = UILabel()
    let eventDate = UILabel()
    let eventTime = UILabel()
    var eventClothingItem = EventClothingItem()
    let deleteButton = UIButton()
    var editingMode = false
    var removeEventFromItem: ((_ id: Int?) -> Void)?
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func setup() {
        box.translatesAutoresizingMaskIntoConstraints = false
        box.backgroundColor = UIColor.Diwi.gray
        box.layer.cornerRadius = 19
        box.contentMode = .scaleAspectFill
        box.clipsToBounds = true
        loadImage()
        contentView.addSubview(box)
        
        NSLayoutConstraint.activate([
            box.widthAnchor.constraint(equalToConstant: 71),
            box.heightAnchor.constraint(equalToConstant: 80),
            box.leftAnchor.constraint(equalTo: contentView.leftAnchor),
            box.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20)
            ])
        
        eventName.translatesAutoresizingMaskIntoConstraints = false
        eventName.font = UIFont.Diwi.floatingButton
        eventName.textColor = UIColor.Diwi.barney
        eventName.text = eventClothingItem.title
        contentView.addSubview(eventName)
        
        NSLayoutConstraint.activate([
            eventName.topAnchor.constraint(equalTo: box.topAnchor, constant: 9),
            eventName.leftAnchor.constraint(equalTo: box.rightAnchor, constant: 21)
            ])
        
        eventDate.translatesAutoresizingMaskIntoConstraints = false
        eventDate.font = UIFont.Diwi.floatingButton
        eventDate.textColor = UIColor.Diwi.darkGray
        eventDate.text = eventClothingItem.calendarDate()
        contentView.addSubview(eventDate)
        
        NSLayoutConstraint.activate([
            eventDate.topAnchor.constraint(equalTo: eventName.bottomAnchor, constant: 7),
            eventDate.leftAnchor.constraint(equalTo: box.rightAnchor, constant: 21)
            ])
        
        eventTime.translatesAutoresizingMaskIntoConstraints = false
        eventTime.font = UIFont.Diwi.floatingButton
        eventTime.textColor = UIColor.Diwi.darkGray
        eventTime.text = eventClothingItem.timeOfDay()
        contentView.addSubview(eventTime)
        
        NSLayoutConstraint.activate([
            eventTime.topAnchor.constraint(equalTo: eventDate.bottomAnchor, constant: 7),
            eventTime.leftAnchor.constraint(equalTo: box.rightAnchor, constant: 21)
            ])
        
        if editingMode {
            deleteButton.translatesAutoresizingMaskIntoConstraints = false
            deleteButton.setImage(UIImage.Diwi.removePinkIcon, for: .normal)
            deleteButton.addTarget(self, action: #selector(deletePress), for: .touchUpInside)
            deleteButton.isHidden = false
            contentView.addSubview(deleteButton)
            
            NSLayoutConstraint.activate([
                deleteButton.heightAnchor.constraint(equalToConstant: 28),
                deleteButton.widthAnchor.constraint(equalToConstant: 28),
                deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor,constant: 20),
                deleteButton.rightAnchor.constraint(equalTo: contentView.rightAnchor)
            ])
        } else {
            deleteButton.isHidden = true
        }
    }

    @objc func deletePress() {
        self.deleteButton.buttonPressedAnimation {
            self.removeEventFromItem?(self.eventClothingItem.id)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadImage() {
        if let thumb = eventClothingItem.thumbnail {
            box.kf.setImage(with: URL(string: thumb), options: [])
        } else if let img = eventClothingItem.image {
            box.kf.setImage(with: URL(string: img), options: [])
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
}
