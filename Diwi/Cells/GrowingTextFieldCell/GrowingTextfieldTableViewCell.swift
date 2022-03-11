//
//  GrowingTextfieldTableViewCell.swift
//  Diwi
//
//  Created by Shane Work on 12/8/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit

protocol GrowingTextFieldDelegate: NSObjectProtocol {
    func updateNotes(_ text:String)
}

class GrowingTextfieldTableViewCell: UITableViewCell {

    @IBOutlet weak var diwiTextView: PlaceholderUITextView!
    static let identifier = "GrowingTextfieldTableViewCell"
    var isEdit: Bool = true

    weak var delegate: GrowingTextFieldDelegate?
    
    func configure(_ delegate: GrowingTextFieldDelegate, _ newLook: NewLook) {
        self.diwiTextView.placeholder = "Write something about this look..."
        self.diwiTextView.text = newLook.note
        self.diwiTextView.isUserInteractionEnabled = isEdit
        self.delegate = delegate
        diwiTextView.layer.borderColor = UIColor.Diwi.azure.cgColor
        diwiTextView.layer.borderWidth =  isEdit ? 1 : 0
        diwiTextView.layer.cornerRadius = 5
    }
    
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.diwiTextView.autocapitalizationType = .sentences
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}

extension GrowingTextfieldTableViewCell: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.updateNotes(textView.text ?? "")
    }
}
