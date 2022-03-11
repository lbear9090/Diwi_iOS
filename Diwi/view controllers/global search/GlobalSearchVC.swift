//
//  ViewController.swift
//  UISearchController
//
//  Created by Anupam Chugh on 25/05/17.
//  Copyright © 2017 JournalDev.com. All rights reserved.
//

import UIKit

class GlobalSearchVC: UITableViewController {
    
    var models = [Result]()
    var isAPIEngage: Bool = false
    var looks = [LookModel]()
    var tags = [LookModel]()
    var dates = [LookModel]()
    var searchText = String()
    var close: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(SearchResultCell.self, forCellReuseIdentifier: SearchResultCell.identifier)
        self.tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.looks.removeAll()
        self.tags.removeAll()
        self.dates.removeAll()
        self.models.removeAll()
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
    }
    
    func getLooksFromServer() {
        Loader.show()
        self.isAPIEngage = true
        debugPrint("search string::::::::::::\(searchText)")
        APIManager.globalSearch(parameters: ["search":["search_term":searchText]]) { (looksvm, error) in
            DispatchQueue.main.async {
                self.isAPIEngage = false
                Loader.hide()
                if error == nil {
                    self.looks.removeAll()
                    self.tags.removeAll()
                    self.dates.removeAll()
                    self.models.removeAll()
                    if let allLooks = looksvm {
                        if let looksArray = allLooks["looks"] as? [NSDictionary]{
                            for dic in looksArray{
                                let value = LookModel(fromDictionary: dic)
                                self.looks.append(value)
                            }
                            if looksArray.count > 0
                            {
                                self.models.append(Result(id: 1, title: self.searchText, label: looksArray.count > 0 ? "\(looksArray.count) looks containing the keyword \u{22}\(self.searchText)\u{22}" : "No looks found", searchType: .Look))
                            }
                        }
                        if let tagsArray = allLooks["tags"] as? [NSDictionary]{
                            for dic in tagsArray{
                                let value = LookModel(fromDictionary: dic)
                                self.tags.append(value)
                            }
                            if tagsArray.count > 0
                            {
//                                self.models.append(Result(id: 2, title: self.searchText, label: tagsArray.count > 0 ? "\(tagsArray.count) tags containing the keyword \u{22}\(self.searchText)\u{22}" : "No tags found", searchType: .Contact))
                                self.models.append(Result(id: 2, title: self.searchText, label: tagsArray.count > 0 ? "One of your friends" : "No tags found", searchType: .Contact))
                            }
                        }
                        if let tagsArray = allLooks["dates"] as? [NSDictionary]{
                            for dic in tagsArray{
                                let value = LookModel(fromDictionary: dic)
                                self.dates.append(value)
                            }
                            if tagsArray.count > 0
                            {
                                self.models.append(Result(id: 3, title: self.searchText, label: tagsArray.count > 0 ? "\(tagsArray.count) Look worn in \u{22}\(self.searchText)\u{22}" : "No dates found", searchType: .Event))
                            }
                        }
                    }
                    //self.models.append(Result(id: 3, title: self.searchText, label: "", searchType: .Search))
                    self.tableView.reloadData()
                }else
                {
                    AlertController.alert(message: "Something went wrong.")
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultCell.identifier, for: indexPath) as! SearchResultCell
        cell.setup(with: models[indexPath.row])
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if models[indexPath.row].searchType == .Look
        {
            let vc = FriendsLooksViewController()
            vc.looksArr = looks
            vc.descriptionText = " All Looks with \u{22}\(searchText.capitalized)\u{22}"
            self.presentingViewController?.navigationController?.pushViewController(vc, animated:true)
        } else if models[indexPath.row].searchType == .Contact {
            let vc = FriendsLooksViewController()
            vc.looksArr = tags
            vc.descriptionText = "Looks worn with \u{22}\(searchText.capitalized)\u{22}"
            self.presentingViewController?.navigationController?.pushViewController(vc, animated:true)
        } else if models[indexPath.row].searchType == .Event {
            let vc = FriendsLooksViewController()
            vc.looksArr = dates
            vc.descriptionText = "Looks worn in \u{22}\(searchText.capitalized)\u{22}"
            self.presentingViewController?.navigationController?.pushViewController(vc, animated:true)
        }else {
            let vc = FriendsLooksViewController()
            vc.looksArr = looks
            vc.descriptionText = " All Looks with \u{22}\(searchText.capitalized)\u{22}"
            self.presentingViewController?.navigationController?.pushViewController(vc, animated:true)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}
extension GlobalSearchVC {
    func updateSearchResults(searchString: String) {
        debugPrint("typed string::::::::::::\(searchString)")
        if !self.isAPIEngage
        {
            self.searchText = searchString
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.getLooksFromServer()
            })
        }
    }
}
