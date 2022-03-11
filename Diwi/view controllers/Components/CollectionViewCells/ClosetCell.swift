import UIKit
import Kingfisher

class ClosetCell: UICollectionViewCell {
    
    static var identifier: String = "Cell"
    // view props
    weak var textLabel: UILabel!
    let box = UIImageView()
    let deleteButton = UIButton()
    let title = UILabel()
    
    // internal props
    var indexItem: ClosetItem?
    var removeClosetItem: ((Bool) -> Void)?
    var showDeleteButton = false {
        didSet {
            if showDeleteButton {
                setupDeleteButton()
            } else {
                deleteButton.removeFromSuperview()
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setup(mode: ClosetViewMode) {
        box.translatesAutoresizingMaskIntoConstraints = false
        box.backgroundColor = UIColor.Diwi.gray
        box.layer.cornerRadius = 19
        box.contentMode = .scaleAspectFill
        box.clipsToBounds = true
        
        contentView.addSubview(box)
        
        NSLayoutConstraint.activate([
            box.widthAnchor.constraint(equalToConstant: 98),
            box.heightAnchor.constraint(equalToConstant: 110),
            box.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            box.topAnchor.constraint(equalTo: contentView.topAnchor)
        ])
        
        if mode == .looks {
            setupTitle()
        } else {
            // reset title due to cell reuse
            title.text = nil
        }
        
        loadImage()
    }
    
    private func setupTitle() {
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFont.Diwi.textField
        if let text = indexItem?.title {
            title.text = text.capitalized
        }
        title.textColor = UIColor.Diwi.barney
        title.lineBreakMode = .byWordWrapping
        title.numberOfLines = 0
        title.textAlignment = .center
        title.clipsToBounds = true
       
       contentView.addSubview(title)
       
       NSLayoutConstraint.activate([
           title.topAnchor.constraint(equalTo: box.bottomAnchor, constant: 5),
           title.widthAnchor.constraint(equalToConstant: 88),
           title.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
       ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadImage() {
        if let thumb = indexItem?.thumbnail {
            box.kf.setImage(with: URL(string: thumb), options: [])
        } else if let img = indexItem?.image {
            box.kf.setImage(with: URL(string: img), options: [])
        }
    }
    
    func setupDeleteButton() {
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.setImage(UIImage.Diwi.smallDelete, for: .normal)
        deleteButton.addTarget(self, action: #selector(handleDeleteButtonPress), for: .touchUpInside)
               
        contentView.addSubview(deleteButton)
               
        NSLayoutConstraint.activate([
            deleteButton.widthAnchor.constraint(equalToConstant: 28),
            deleteButton.heightAnchor.constraint(equalToConstant: 28),
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            deleteButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 5)
            ])
    }
    
    @objc func handleDeleteButtonPress() {
        removeClosetItem?(selectedForDeletion)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    private func rotateDeleteButton(rotation: CGFloat) {
        UIView.animate(withDuration:0.2,
                       animations: {
            self.deleteButton.transform = CGAffineTransform(rotationAngle: rotation)
        })
    }
    
    func selectedState(value: Bool) {
        if value {
            layer.borderWidth = 3
            layer.cornerRadius = 19
            layer.borderColor = UIColor.Diwi.barney.cgColor
        } else {
            layer.borderWidth = 0
            layer.cornerRadius = 19
            layer.borderColor = UIColor.clear.cgColor
        }
    }
}
