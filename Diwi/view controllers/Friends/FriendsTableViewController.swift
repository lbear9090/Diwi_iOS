//
//  FriendsTableViewController.swift
//  Diwi
//
//  Created by Shane Work on 12/18/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit

class FriendsTableViewController: UITableViewController {
    
    let friends = ["Chad", "Joezy", "Lauren", "Fredo", "Robbert", "Enoch", "Jenna", "Elliot", "Jared", "Timothy", "Gabe"]
        
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        setupNavBar()
        self.tableView.separatorColor = UIColor.Diwi.azure
    }

    func registerCell() {
        let nib = UINib(nibName: "FriendsListTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "FriendsListCell")
    }
    
    func setupNavBar() {
        configureNavigationBar(largeTitleColor: .white,
                               backgoundColor: UIColor.Diwi.barney,
                               tintColor: .white, title: "New Look",
                               preferredLargeTitle: false,
                               searchController: nil)
        
        let leftBarButtonItem: UIBarButtonItem = UIBarButtonItem(title:"Cancel",
                                                                 style: .plain,
                                                                 target: self,
                                                                 action:#selector(leftBarButtonTapped))
        
        let rightBarButtonItem: UIBarButtonItem = UIBarButtonItem(title:"Save",
                                                                 style: .plain,
                                                                 target: self,
                                                                 action:#selector(rightBarButtonTapped))
        
        self.navigationItem.setRightBarButton(rightBarButtonItem, animated: false)
        self.navigationItem.setLeftBarButton(leftBarButtonItem, animated: false)
    }
    
    @objc func leftBarButtonTapped() {
        
    }
    
    @objc func rightBarButtonTapped() {
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return friends.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsListCell", for: indexPath) as! FriendsListTableViewCell
        cell.nameLabel.text = friends[indexPath.row]

        return cell
    }
    

    
}
