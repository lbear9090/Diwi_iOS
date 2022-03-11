//
//  GlobalSearchViewController.swift
//  Diwi
//
//  Created by Dominique Miller on 4/15/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GlobalSearchViewController: UIViewController {
    
    // MARK: - View props
    let searchIcon       = UIImageView(image: UIImage.Diwi.searchIcon)
    let closeButton      = UIButton()
    let searchField      = UITextField()
    let underline        = UIView()
    let resultsTableView = UITableView()
    let noResultsFound   = UILabel()
    let searchBackground = UIView()
    let searchBackgroundBorder = UIView()
    weak var interactiveTransition: BubbleInteractiveTransition?
    var comingFrom = String()
    
    // MARK: - Internal props
    var viewModel: GlobalSearchViewModel!
    var close: (() -> Void)?
    var goToResult: ((_ result: Result) -> Void)?
    let disposeBag = DisposeBag()
    var coordinator: MainCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBackgroundBorder.layer.borderWidth = 1.0
        searchBackgroundBorder.layer.borderColor = UIColor.white.cgColor
        searchBackgroundBorder.layer.cornerRadius = 15

        setupView()
        setupViewBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        searchField.becomeFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}

// MARK: - View bindings
extension GlobalSearchViewController {
    private func setupViewBindings() {
        closeButton.rx.tap.bind { [unowned self] in
            self.close?()
        }.disposed(by:self.disposeBag)
        
        searchField.rx
            .controlEvent(.editingDidEndOnExit)
            .bind { [unowned self] in
                self.searchField.resignFirstResponder()
        }.disposed(by: disposeBag)
        
        searchField.rx.text.orEmpty
            .bind(to: viewModel.query)
            .disposed(by: disposeBag)
        
        viewModel.selectedResult
            .skip(1)
            .drive(onNext: { [unowned self] result in
                self.goToResult?(result)
            }).disposed(by: disposeBag)
        
        viewModel.results
            .skip(1)
            .drive(onNext: { [unowned self] results in
                if results.count > 0 {
                    self.removeNoResultsFound()
                    self.resultsTableView.reloadData()
                } else {
                    self.resultsTableView.reloadData()
                    self.setupNoResultsFound()
                }
            }).disposed(by: disposeBag)
    }
}

// MARK: - Setup View
extension GlobalSearchViewController {
    private func setupView() {
        
        searchBackground.translatesAutoresizingMaskIntoConstraints = false
        searchBackground.backgroundColor = UIColor.Diwi.barney
        view.addSubview(searchBackground)
        
        searchBackgroundBorder.translatesAutoresizingMaskIntoConstraints = false
        searchBackgroundBorder.backgroundColor = UIColor.Diwi.barney
        view.addSubview(searchBackgroundBorder)

        view.backgroundColor = .white
        setupSearchIcon()
        setupCloseButton()
        setupSearchField()
        setupUnderline()
        setupResultsTableView()
    }
    
    private func setupSearchIcon() {
        searchIcon.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(searchIcon)
        
        NSLayoutConstraint.activate([
            searchIcon.widthAnchor.constraint(equalToConstant: 23),
            searchIcon.heightAnchor.constraint(equalToConstant: 23),
            searchIcon.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 25),
            searchIcon.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8)
        ])
    }
    
    private func setupCloseButton() {
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setImage(UIImage.Diwi.removePinkIcon, for: .normal)
        
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 28),
            closeButton.heightAnchor.constraint(equalToConstant: 28),
            closeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -13),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 11)
        ])
    }
    
    private func setupSearchField() {
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.font = UIFont.Diwi.address
        searchField.attributedPlaceholder = NSAttributedString(string: TextContent.Placeholders.searchBy,
                                                               attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
        searchField.textColor = .white
        
        view.addSubview(searchField)
        
        NSLayoutConstraint.activate([
            searchField.leftAnchor.constraint(equalTo: searchIcon.rightAnchor, constant: 4),
            searchField.rightAnchor.constraint(equalTo: closeButton.leftAnchor, constant: 12),
            searchField.heightAnchor.constraint(equalToConstant: 48),
            searchField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -5)
        ])
    }
    
    private func setupUnderline() {
        underline.translatesAutoresizingMaskIntoConstraints = false
        underline.backgroundColor = UIColor.Diwi.azure
        
        view.addSubview(underline)
        
        NSLayoutConstraint.activate([
            underline.heightAnchor.constraint(equalToConstant: 0),
            underline.topAnchor.constraint(equalTo: searchField.bottomAnchor),
            underline.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 13),
            underline.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -13)
        ])
        
        NSLayoutConstraint.activate([
            searchBackground.bottomAnchor.constraint(equalTo: underline.bottomAnchor, constant: 3),
            searchBackground.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            searchBackground.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            searchBackground.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0)
        ])
        
        NSLayoutConstraint.activate([
            searchBackgroundBorder.bottomAnchor.constraint(equalTo: underline.bottomAnchor, constant: -8),
            searchBackgroundBorder.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            searchBackgroundBorder.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            searchBackgroundBorder.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20)
        ])
        
    }
    
    private func setupResultsTableView() {
        resultsTableView.translatesAutoresizingMaskIntoConstraints = false
        resultsTableView.separatorStyle = .none
        resultsTableView.register(SearchResultCell.self, forCellReuseIdentifier: SearchResultCell.identifier)
        resultsTableView.showsVerticalScrollIndicator = false
        resultsTableView.dataSource = self
        resultsTableView.delegate = self
        
        view.addSubview(resultsTableView)
        
        NSLayoutConstraint.activate([
            resultsTableView.topAnchor.constraint(equalTo: underline.bottomAnchor, constant: 25),
            resultsTableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 13),
            resultsTableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -13),
            resultsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupNoResultsFound() {
        noResultsFound.translatesAutoresizingMaskIntoConstraints = false
        noResultsFound.textColor  = UIColor.Diwi.darkGray
        noResultsFound.font = UIFont.Diwi.titleBold
        noResultsFound.text = TextContent.Errors.noResultsFound
        
        view.addSubview(noResultsFound)
        
        NSLayoutConstraint.activate([
            noResultsFound.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            noResultsFound.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
    }
    
    private func removeNoResultsFound() {
        noResultsFound.removeFromSuperview()
    }
}

// MARK: - Tableview Delegate methods
extension GlobalSearchViewController: UITableViewDelegate,
                                      UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getResultsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultCell.identifier, for: indexPath) as! SearchResultCell
        let result = viewModel.getResult(for: indexPath.row)
        cell.setup(with: result)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView.cellForRow(at: indexPath) as? SearchResultCell) != nil {
            searchField.resignFirstResponder()
            //viewModel.setSelected(at: indexPath.row)
            
            if comingFrom == "looksTab"
            {
                let result = viewModel.getResult(for: indexPath.row)
                guard let id = result.id else { return }
    //            vc.dismiss(animated: true) {
                    switch result.modelType {
                    case .ClothingItems:
                        let item = ClothingItem()
                        item.id = id
                        guard let coord = self.coordinator else { return }
                        coord.closetItem(item: item)
                    case .Contacts:
                        debugPrint("")
                        guard let coord = self.coordinator else { return }
                        coord.viewContact(with: id)
                    case .Events:
                        let event = Event()
                        event.id = id
                    case .Looks:
                        debugPrint("")
                        guard let coord = self.coordinator else { return }
                        coord.viewLook(with: id)
                    default:
                        return
                    }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
