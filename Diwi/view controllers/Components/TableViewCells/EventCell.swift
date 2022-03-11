import UIKit
import Kingfisher

class EventCell: UITableViewCell {
    
    static var identifier: String = "Cell"
    
    // MARK: -  view props
    let box = UIImageView()
    let eventName = UILabel()
    let eventDate = UILabel()
    let eventTime = UILabel()
    var event = Event()
    let deleteButton = UIButton()
    
    // MARK: - internal props
    var showDeleteButton = false {
        didSet {
            if showDeleteButton {
                setupDeleteButton()
            }
        }
    }
    
    var selectedForDeletion = false {
        didSet {
            if selectedForDeletion {
                box.layer.borderColor = UIColor.Diwi.barney.cgColor
                box.layer.borderWidth = 3
                rotateDeleteButton(rotation: 0.8)
            } else {
                box.layer.borderColor = UIColor.clear.cgColor
                box.layer.borderWidth = 0
                rotateDeleteButton(rotation: 0)
            }
        }
    }
    
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
        eventName.text = event.name

        contentView.addSubview(eventName)
        
        NSLayoutConstraint.activate([
            eventName.topAnchor.constraint(equalTo: box.topAnchor, constant: 9),
            eventName.leftAnchor.constraint(equalTo: box.rightAnchor, constant: 21)
            ])
        
        eventDate.translatesAutoresizingMaskIntoConstraints = false
        eventDate.font = UIFont.Diwi.floatingButton
        eventDate.textColor = UIColor.Diwi.darkGray
        eventDate.text = event.calendarDate()

        contentView.addSubview(eventDate)
        
        NSLayoutConstraint.activate([
            eventDate.topAnchor.constraint(equalTo: eventName.bottomAnchor, constant: 7),
            eventDate.leftAnchor.constraint(equalTo: box.rightAnchor, constant: 21)
        ])
        
        eventTime.translatesAutoresizingMaskIntoConstraints = false
        eventTime.font = UIFont.Diwi.floatingButton
        eventTime.textColor = UIColor.Diwi.darkGray
        eventTime.text = event.timeOfDay()
        contentView.addSubview(eventTime)
        
        NSLayoutConstraint.activate([
            eventTime.topAnchor.constraint(equalTo: eventDate.bottomAnchor, constant: 7),
            eventTime.leftAnchor.constraint(equalTo: box.rightAnchor, constant: 21)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadImage() {
        if let img = event.image {
            box.kf.setImage(with: URL(string: img), options: [])
        }
    }
    
    func setupDeleteButton() {
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setImage(UIImage.Diwi.removePinkIcon, for: .normal)
               
        contentView.addSubview(deleteButton)
               
        NSLayoutConstraint.activate([
            deleteButton.widthAnchor.constraint(equalToConstant: 28),
            deleteButton.heightAnchor.constraint(equalToConstant: 28),
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            deleteButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 5)
            ])
    }
    
    private func rotateDeleteButton(rotation: CGFloat) {
        UIView.animate(withDuration:0.2,
                       animations: {
            self.deleteButton.transform = CGAffineTransform(rotationAngle: rotation)
        })
    }
}
