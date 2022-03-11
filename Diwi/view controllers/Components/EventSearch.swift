import UIKit

class EventSearch: UIView, UITextFieldDelegate {

    let autocomplete = UITableView()
    let searchInput = SearchInput()
    let background = UIView()
    let separator = UIView()
    
    var delegate: AutocompleteDelegate?
    var firstTableViewHeight = true
    
    var data: [Tag] = []
    var tableViewHeightChange: ((CGFloat)-> Void)?
    
    var isEnabled: Bool = true {
        didSet {
            searchInput.isEnabled = isEnabled
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupTable()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
        setupTable()
    }
    
    private func setup() {
        searchInput.translatesAutoresizingMaskIntoConstraints = false
        searchInput.delegate = self
        addSubview(searchInput)
        NSLayoutConstraint.activate([
            searchInput.leftAnchor.constraint(equalTo: leftAnchor),
            searchInput.rightAnchor.constraint(equalTo: rightAnchor),
            searchInput.topAnchor.constraint(equalTo: topAnchor),
            searchInput.heightAnchor.constraint(equalToConstant: 36)
            ])
        
        background.translatesAutoresizingMaskIntoConstraints = false
        background.backgroundColor = UIColor.white
        background.isHidden = true
        addSubview(background)
        sendSubviewToBack(background)
        NSLayoutConstraint.activate([
            background.leftAnchor.constraint(equalTo: leftAnchor),
            background.rightAnchor.constraint(equalTo: rightAnchor),
            background.topAnchor.constraint(equalTo: searchInput.centerYAnchor),
            background.bottomAnchor.constraint(equalTo: searchInput.bottomAnchor, constant: 18)
            ])
    }
    
 
    private func setupTable() {
        autocomplete.translatesAutoresizingMaskIntoConstraints = false
        addSubview(autocomplete)
        autocomplete.register(AutocompleteCell.self, forCellReuseIdentifier: AutocompleteCell.identifier)
        autocomplete.backgroundColor = UIColor.white
        autocomplete.separatorStyle = .none
        autocomplete.isHidden = true
        autocomplete.layer.cornerRadius = 18
        autocomplete.delegate = self
        autocomplete.dataSource = self
        let height = autocomplete.heightAnchor.constraint(equalToConstant: 0)
        height.identifier = "Height"
        NSLayoutConstraint.activate([
            autocomplete.topAnchor.constraint(equalTo: topAnchor, constant: 36),
            autocomplete.widthAnchor.constraint(equalTo: widthAnchor),
            height
            ])
        
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = UIColor.Diwi.azure
        separator.isHidden = true
        addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.leftAnchor.constraint(equalTo: leftAnchor),
            separator.rightAnchor.constraint(equalTo: rightAnchor),
            separator.topAnchor.constraint(equalTo: autocomplete.topAnchor),
            separator.heightAnchor.constraint(equalToConstant: 1)
            ])
    }
    
    private func setShadow() {
        layer.cornerRadius = 18
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = .zero
        layer.shadowRadius = 18
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.masksToBounds = false
        clipsToBounds = false
    }
    
    private func hideShadow() {
        layer.shadowOpacity = 0
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        searchInput.onBlur()
        autocomplete.isHidden = true
        background.isHidden = true
        separator.isHidden = true
        hideShadow()
        resetHeightOfTableView()
        delegate?.didFinishEditing()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setTableHeight()
        searchInput.onFocus()
        autocomplete.isHidden = false
        background.isHidden = false
        separator.isHidden = false
        setShadow()
        delegate?.didStartEditing()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
        
    private func setTableHeight() {
        var count = data.count
    
        if (count > 6) {
            count = 6
        }
        
        let height = 44 * count
        for constraint in autocomplete.constraints {
            if constraint.identifier == "Height" {
                constraint.constant = CGFloat(height)
                tableViewHeightChange?(CGFloat(height))
                autocomplete.layoutIfNeeded()
            }
        }
    }
    
    private func resetHeightOfTableView() {
        let height = 0
        for constraint in autocomplete.constraints {
            if constraint.identifier == "Height" {
                constraint.constant = CGFloat(height)
                tableViewHeightChange?(CGFloat(height))
                autocomplete.layoutIfNeeded()
            }
        }
    }
    
    func reloadData() {
        if firstTableViewHeight {
            resetHeightOfTableView()
            firstTableViewHeight = false
        } else {
            setTableHeight()
        }
        
        autocomplete.reloadData()
    }
    
}

extension EventSearch: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = data.count
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EventCell.identifier, for: indexPath) as! AutocompleteCell
        cell.tagData = data[indexPath.item]
        cell.setup()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = autocomplete.cellForRow(at: indexPath) as! AutocompleteCell
        delegate?.didSelectTag(withId: cell.tagData.id!)
    }

}
