//
//  FriendsListViewController.swift
//  Diwi
//
//  Created by Shane Work on 12/22/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit

protocol FriendsAddedDelegate {
    func selectedFriends(ids: [Int],names: [String], resource: [FriendModel])
}

class FriendsListViewController: UIViewController {
    
    @IBOutlet weak var createFriendView: UIView!
    @IBOutlet weak var friendsCountLabel: UILabel!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var friendsSearchBar: UISearchBar!
    var delegate: FriendsAddedDelegate?
    var friends = [FriendModel]()
    var selectedFreiends = [Int]()
    var selectedName = [String]()
    var selectedIndex: Int = 0
    var selectedSection: Int = 0
    var section = [Character]()
    var friendsDictionary = [Character:Any]()
    var sectionHeaders = [String]()
    var titleArray = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        friendsTableView.sectionIndexColor = UIColor.Diwi.azure
        setupUI()
        //TODO: Change colors from black
        //        fetchFriends()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden =  true
        fetchFriends()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func addNewFriendTap(_ sender: Any) {
        goToAddFriend()
    }
    
    @IBAction func addFriendButton(_ sender: Any) {
        let viewController = UINavigationController(rootViewController: AddFriendViewController())
        viewController.modalPresentationStyle = .currentContext
        self.present(viewController, animated: true, completion: nil)
    }
    
    func fetchFriends() {
        Loader.show()
        APIManager.fetchTags(comp: { (tags, error,success) in
            Loader.hide()
            if success ?? false
            {
                if let tags = tags {
                    self.friends = tags
                    self.friendsCountLabel.text = "\(self.friends.count) Friends"
                }
                if (self.friends.count) == 0 {
                    self.createFriendView.isHidden = false
                } else {
                    self.createFriendView.isHidden = true
                }
                self.sortUser()
                
                delay(delay: 0.4) {
                    self.friendsTableView.reloadData()
                }
                print("titleArray: ",self.titleArray)
            } else {
                AlertController.alert(message: error ?? AlertMsg.errorCreateLook)
            }
        })
    }
    
    private func sortUser() {
        
        friendsDictionary = Dictionary(grouping: self.friends) { ($0.title.uppercased().first!) }
        let lazyMapCollection = friendsDictionary.keys
        let stringArray = Array(lazyMapCollection.map { Character(extendedGraphemeClusterLiteral: $0) })
        self.section = stringArray.sorted()
        self.sectionHeaders.removeAll()
        for char in self.section
        {
            self.sectionHeaders.append(String(char))
        }
        
        var frModel = [FriendModel]()
        friends.removeAll()
        if self.friendsDictionary.count > 0 {
        for ff in (0...friendsDictionary.count - 1) {
            let userKey = section[ff]
            if let users = friendsDictionary[userKey] as? [FriendModel] {
                frModel = users.sorted(by: { (item1, item2) -> Bool in
                    item1.title.caseInsensitiveCompare(item2.title) == .orderedAscending
                })
            }
        }
            friends.append(contentsOf: frModel)
        }
        friendsDictionary = Dictionary(grouping: self.friends) { ($0.title.uppercased().first!)}
    }
    
    func deleteFriend(id: Int) {
        Loader.show()
        if let token = KeychainService().getUserJWT() {
            let apiFullUrl = webApiBaseURL+ApiURL.tags+"/"+"\(id)"
            var request = URLRequest(url: URL(string: apiFullUrl)!,timeoutInterval: 30.0)
            request.addValue(token, forHTTPHeaderField: "Authorization")
            request.httpMethod = "DELETE"
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else {
                    print(String(describing: error))
                    return
                }
                DispatchQueue.main.async {
                    print(String(data: data, encoding: .utf8) ?? "")
                    if error != nil
                    {
                        Loader.hide()
                        AlertController.alert(message: error.debugDescription)
                    } else {
                        self.sectionHeaders.removeAll()
                        self.friends.removeAll()
                        self.fetchFriends()
                    }
                }
            }
            task.resume()
        }
    }
    
    func setupUI() {
        setupNavBar()
        setupSearchBar()
        setupTableView()
        
        friendsCountLabel.text = "\(friends.count) Friends"
        friendsCountLabel.textColor = UIColor.Diwi.opaqueBlack
    }
    
    func setupTableView() {
        let nib = UINib(nibName: "FriendsListTableViewCell", bundle: nil)
        self.friendsTableView.register(nib, forCellReuseIdentifier: "FriendsListCell")
        
        friendsTableView.delegate = self
        friendsTableView.dataSource = self
    }
    
    func setupNavBar() {
        configureNavigationBar(largeTitleColor: .white,
                               backgoundColor: UIColor.Diwi.opaqueBlack,
                               tintColor: .white, title: "Friends",
                               preferredLargeTitle: false,
                               searchController: nil)
        
        let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(title:"Cancel",
                                                                 style: .plain,
                                                                 target: self,
                                                                 action:#selector(cancelBtn))
        
        let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(title:"Add",
                                                                  style: .plain,
                                                                  target: self,
                                                                  action:#selector(addButton))
        
        self.navigationItem.setRightBarButton(rightBarButtonItem, animated: false)
        self.navigationItem.setLeftBarButton(leftBarButtonItem, animated: false)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.Diwi.navigationButton]
    }
    
    @objc func cancelBtn() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func addButton() {
        self.dismiss(animated: true, completion: nil)
        var selectedFriendsModel = [FriendModel]()
        for id in selectedFreiends
        {
            let b = self.friends.filter { ($0.id == id)}
            if b.count > 0
            {
                selectedFriendsModel.append(contentsOf: b)
            }
        }
        delegate?.selectedFriends(ids: selectedFreiends,names: selectedName, resource: selectedFriendsModel)
    }
    
    func setupSearchBar() {
        let textField = friendsSearchBar.value(forKey: "searchField") as! UITextField
        
        let glassIconView = textField.leftView as! UIImageView
        glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
        glassIconView.tintColor = UIColor.Diwi.lightGray
        
        friendsSearchBar.searchBarStyle = .prominent
        friendsSearchBar.isTranslucent = false
        let textFieldInsideSearchBar = friendsSearchBar.value(forKey: "searchField") as? UITextField
        let placeholderLabel       = textFieldInsideSearchBar?.value(forKey: "placeholderLabel") as? UILabel
        placeholderLabel?.font     = UIFont.Diwi.h1
        textFieldInsideSearchBar?.backgroundColor = UIColor.white
        textFieldInsideSearchBar?.layer.borderColor = UIColor.Diwi.lightGray.cgColor
        textFieldInsideSearchBar?.layer.borderWidth = 1
        textFieldInsideSearchBar?.layer.cornerRadius = 18
        textFieldInsideSearchBar?.textColor = UIColor.Diwi.lightGray
        textFieldInsideSearchBar?.placeholder = "Search for a friend"
        friendsSearchBar.barTintColor = UIColor.white
        friendsSearchBar.backgroundImage = UIImage()
    }
    
    func goToAddFriend() {
        let viewController = UINavigationController(rootViewController: AddFriendViewController())
        viewController.modalPresentationStyle = .currentContext
        self.present(viewController, animated: true, completion: nil)
    }
    
}

extension FriendsListViewController: UITableViewDataSource, UITableViewDelegate {
    
    //set the number of sections
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.section.count
    }
    //set the section index titles
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.sectionHeaders
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 25))
        let label = UILabel()
        label.frame = CGRect.init(x: 22, y: 0, width: headerView.frame.width-45, height: headerView.frame.height)
        label.backgroundColor = UIColor.groupTableViewBackground
        label.text = "  \(self.section[section].uppercased())"
        label.font = UIFont.Diwi.placeHolder
        label.textColor = UIColor.black
        headerView.addSubview(label)
        return headerView
    }

    //sets the nubmer of rows per section
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let userKey = self.section[section]
        if let users = friendsDictionary[userKey] as? [FriendModel] {
            return users.count
        }
        return 0
    }

    //populate the user from the dictionary instead of the array now
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsListCell", for: indexPath) as! FriendsListTableViewCell
        cell.selectedButton.addTarget(self, action: #selector(selectButtonTap(_:)), for: .touchUpInside)
        cell.selectedButton.tag = (indexPath.section * 1000) + indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(deleteButtonTap(_:)), for: .touchUpInside)
        cell.deleteButton.tag = (indexPath.section * 1000) + indexPath.row

        cell.selectedButton.setBackgroundImage(#imageLiteral(resourceName: "checkEmpty"), for: .normal)
        cell.nameLabel.textColor = UIColor.Diwi.barney
        cell.deleteButton.isHidden = false
        
        let userKey = section[indexPath.section]
        if let users = friendsDictionary[userKey] as? [FriendModel]{
            if selectedFreiends.contains(users[indexPath.row].id) {
                cell.selectedButton.setBackgroundImage(#imageLiteral(resourceName: "checkFilled"), for: .normal)
                cell.nameLabel.textColor = UIColor.Diwi.contactGray
                cell.deleteButton.isHidden = true
            }
            cell.nameLabel.text = users[indexPath.row].title
        }
        cell.selectionStyle = .none
        return cell
    }
    
    @objc func selectButtonTap(_ sender: UIButton) {
        
        let row = sender.tag % 1000
        let userKey = section[(sender.tag / 1000)]
        if let users = friendsDictionary[userKey] as? [FriendModel]{
            if !selectedFreiends.contains(users[row].id) {
                selectedFreiends.append(users[row].id)
                selectedName.append(users[row].title)
            }else
            {
                let index = selectedFreiends.index(of: users[row].id)
                selectedFreiends.remove(at: index ?? 0)
                selectedName.remove(at: index ?? 0)
            }
        }
        self.friendsTableView.reloadData()
    }
    
    @objc func deleteButtonTap(_ sender: UIButton) {
        
        selectedIndex = sender.tag % 1000
        selectedSection = sender.tag / 1000
        let userKey = section[selectedSection]

        if let users = friendsDictionary[userKey] as? [FriendModel]{
            let name = users[selectedIndex].title
            AlertController.actionSheetWithDestructive(title: "", message: "Delete \(name ?? "Friend")?", sourceView: self.view, buttons: [], destructiveButtonTitle: "Delete", cancelButtonTitle: "Cancel") { (actionsheet, selectedIndex) in
                self.view.endEditing(true)
                if selectedIndex == 1 {
                    self.deleteFriend(id: users[self.selectedIndex].id)
                }
            }
        }
    }
}
