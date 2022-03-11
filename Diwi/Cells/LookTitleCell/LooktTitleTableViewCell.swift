//
//  LooktTitleTableViewCell.swift
//  Diwi
//
//  Created by Shane Work on 12/2/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit

protocol LookTitleCellDelegate: NSObjectProtocol {
    func updateTitle(_ text: String)
}

class LooktTitleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelContainer: UIView!
//    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleLabelTextfield: UITextField!
    var isEdit: Bool = true
    static let identifier = "LooktTitleTableViewCell"
    
    weak var delegate: LookTitleCellDelegate?
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    func configure(_ delegate: LookTitleCellDelegate, _ newLook: NewLook) {
        self.titleLabelTextfield.placeholder = "Title* (E.g. Blue Dress, Laura’s Wedding)"
        self.titleLabelTextfield.text = newLook.title
        self.titleLabelTextfield.isUserInteractionEnabled = isEdit
        self.delegate = delegate
        labelContainer.layer.borderColor = UIColor.Diwi.azure.cgColor
        labelContainer.layer.borderWidth = isEdit ? 1 : 0
        labelContainer.layer.cornerRadius = 5
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleLabelTextfield.autocapitalizationType = .words
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension LooktTitleTableViewCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.updateTitle(textField.text ?? "")
    }
}
