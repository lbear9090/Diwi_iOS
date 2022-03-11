//
//  RemoveEventsViewController.swift
//  Diwi
//
//  Created by Dominique Miller on 1/10/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RemoveEventsViewController: UIViewController {
    
    // MARK: - view props
    let header          = UIView()
    let navTitle        = UILabel()
    let filterToggle    = UIButton()
    let buttonBorder    = UIView()
    let arrowIcon       = UIImageView()
    let byAlphabet      = UIButton()
    let byLatestDate    = UIButton()
    let byEarliestDate  = UIButton()
    let backButton      = UIButton()
    let emptyTopLabel   = UILabel()
    let emptyHeading    = UILabel()
    let emptySubHeading = UILabel()
    let eventsTable     = UITableView()
    let eventSearch     = EventSearch()
    var spinnerView     = UIView()

    // MARK: - internal props
    weak var coordinator: MainCoordinator?
    let disposeBag = DisposeBag()
    var viewModel: EventsViewModel!
    let filtersOpen = BehaviorRelay<Bool>(value: false)
    var workflow: Workflow = .eventsIndex
    let screenWidth = UIScreen.main.bounds.width
    var goBack: (() -> Void)?
    var eventSearchResultsHeight: NSLayoutConstraint = NSLayoutConstraint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createViewModelBinding()
        viewModel.getEvents()
        viewModel.getTags()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    private func closeFilters() {
        UIView.animate(withDuration: 0.25) {
            self.arrowIcon.transform = CGAffineTransform(rotationAngle: 0)
            self.byAlphabet.frame.origin.y -= 45
            self.byLatestDate.frame.origin.y -= 90
            self.byEarliestDate.frame.origin.y -= 135
            self.eventsTable.frame.origin.y -= 135
        }
    }

    private func openFilters() {
        UIView.animate(withDuration: 0.25) {
            self.arrowIcon.transform = CGAffineTransform(rotationAngle: (-90.0 * .pi) / 180.0)
            self.byAlphabet.frame.origin.y += 45
            self.byLatestDate.frame.origin.y += 90
            self.byEarliestDate.frame.origin.y += 135
            self.eventsTable.frame.origin.y += 135

        }
    }
    
    private func goToLogin() {
        coordinator?.logout()
    }
    
    private func hideEmpty() {
        emptyTopLabel.isHidden = true
        emptyHeading.isHidden = true
        emptySubHeading.isHidden = true
    }
    
    private func showEmpty() {
        emptyTopLabel.isHidden = false
        emptyHeading.isHidden = false
        emptySubHeading.isHidden = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}

// MARK: - View model bindings
extension RemoveEventsViewController {
    private func createViewModelBinding() {
        filterToggle.rx.tap.bind {
            self.filtersOpen.accept(!self.filtersOpen.value)
        }.disposed(by: disposeBag)

        byAlphabet.rx.tap.bind {
            self.viewModel.sortAlphabetically()
        }.disposed(by: disposeBag)

        byLatestDate.rx.tap.bind {
                self.viewModel.sortByLatest()
        }.disposed(by: disposeBag)
        
        byEarliestDate.rx.tap.bind {
                self.viewModel.sortByEarliest()
        }.disposed(by: disposeBag)
        
        backButton.rx.tap.bind { [unowned self] in
            self.goBack?()
        }.disposed(by: disposeBag)
        
        filtersOpen.subscribe(onNext: { [unowned self] (value: Bool) in
            if value {
                self.openFilters()
            }
            else {
                self.closeFilters()
            }
        }).disposed(by: disposeBag)

        viewModel.events
            .subscribe(onNext: { [unowned self] (value: [Event]) in
                self.eventsTable.reloadData()
            }).disposed(by: disposeBag)
        
        viewModel.displayedTags
            .subscribe(onNext: { [unowned self] (value: [Tag]) in
                if value.count > 0 {
                    self.eventSearch.data = value
                    self.eventSearch.reloadData()
                }
            }).disposed(by: disposeBag)

        viewModel.errorStatus
            .subscribe(onNext: { [unowned self] (value: Int) in
                if value == 401 {
                    self.goToLogin()
                }
            }).disposed(by: disposeBag)
    
        eventSearch.searchInput.rx.text.orEmpty
            .bind(to: viewModel.query)
            .disposed(by: disposeBag)
        
        viewModel.inputValue
            .subscribe(onNext: { [unowned self] (value: String) in
                self.eventSearch.searchInput.text = value
            }).disposed(by: disposeBag)
        
        viewModel.isLoading
            .subscribe(onNext: { [unowned self] (value: Bool) in
                if value {
                    self.displaySpinner(onView: self.view, spinnerView: self.spinnerView)
                } else {
                    self.removeSpinner(spinner: self.spinnerView)
                }
            }).disposed(by: disposeBag)
        
        viewModel.success
            .subscribe(onNext: { [unowned self] (value: Bool) in
                if value {
                    self.goBack?()
                }
            }).disposed(by: disposeBag)
    }
}

// MARK: - Setup view
extension RemoveEventsViewController {
    private func setupView() {
        setupHeader()
        setupNav()
        setupFilterToggle()
        setupMenu()
        setupEventsTable()
        setupEmpty()
        setupSearch()
        setupSpinner()
    }
    
    private func setupHeader() {
        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = UIColor.Diwi.azure
        view.backgroundColor = UIColor.white
        view.addSubview(header)
        
        NSLayoutConstraint.activate([
            header.leftAnchor.constraint(equalTo: view.leftAnchor),
            header.rightAnchor.constraint(equalTo: view.rightAnchor),
            header.topAnchor.constraint(equalTo: view.topAnchor),
            header.heightAnchor.constraint(equalToConstant: 185)
            ])
        
    }
    
    private func setupNav() {
        var paddingTop = CGFloat(25)
        
        if hasNotch() {
            paddingTop += 30
        }
        
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage.Diwi.backIconWhite, for: .normal)
        
        view.addSubview(backButton)
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: header.topAnchor, constant: paddingTop),
            backButton.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 10),
            backButton.widthAnchor.constraint(equalToConstant: 28),
            backButton.heightAnchor.constraint(equalToConstant: 28)
        ])
        
        navTitle.translatesAutoresizingMaskIntoConstraints = false
        navTitle.textColor = UIColor.white
        navTitle.text = TextContent.Labels.removeEvents
        navTitle.font = UIFont.Diwi.titleBold
        header.addSubview(navTitle)
        
        NSLayoutConstraint.activate([
            navTitle.topAnchor.constraint(equalTo: header.topAnchor, constant: paddingTop),
            navTitle.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            ])
        
    }
    
    private func setupFilterToggle() {
        filterToggle.translatesAutoresizingMaskIntoConstraints = false
        filterToggle.setTitle(TextContent.Buttons.sortEvents, for: .normal)
        filterToggle.titleLabel?.font = UIFont.Diwi.floatingButton
        filterToggle.addBottomBorder()
        filterToggle.contentHorizontalAlignment = .left
        header.addSubview(filterToggle)
        
        var padding = CGFloat(66)
        if hasNotch() {
            padding -= 30
        }
        
        NSLayoutConstraint.activate([
            filterToggle.topAnchor.constraint(equalTo: navTitle.bottomAnchor, constant: padding),
            filterToggle.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 30),
            filterToggle.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -30),
            filterToggle.heightAnchor.constraint(equalToConstant: 50)
            ])
        
        buttonBorder.translatesAutoresizingMaskIntoConstraints = false
        buttonBorder.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        header.addSubview(buttonBorder)
        
        NSLayoutConstraint.activate([
            buttonBorder.topAnchor.constraint(equalTo: filterToggle.bottomAnchor),
            buttonBorder.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 30),
            buttonBorder.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -30),
            buttonBorder.heightAnchor.constraint(equalToConstant: 1)
            ])
        
        arrowIcon.translatesAutoresizingMaskIntoConstraints = false
        arrowIcon.image = UIImage.Diwi.downArrowIcon
        header.addSubview(arrowIcon)
        
        NSLayoutConstraint.activate([
            arrowIcon.centerYAnchor.constraint(equalTo: filterToggle.centerYAnchor),
            arrowIcon.rightAnchor.constraint(equalTo: filterToggle.rightAnchor),
            ])
    }
    
    private func setupMenu() {
        byAlphabet.translatesAutoresizingMaskIntoConstraints = false
        byAlphabet.backgroundColor = UIColor.Diwi.azure
        byAlphabet.titleLabel?.font = UIFont.Diwi.floatingButton
        byAlphabet.contentHorizontalAlignment = .left
        byAlphabet.setTitle(TextContent.Buttons.alphabetically, for: .normal)
        byAlphabet.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 43.0, bottom: 0.0, right: 0)
        view.addSubview(byAlphabet)
        view.sendSubviewToBack(byAlphabet)
        
        NSLayoutConstraint.activate([
            byAlphabet.topAnchor.constraint(equalTo: header.bottomAnchor, constant: -45),
            byAlphabet.leftAnchor.constraint(equalTo: view.leftAnchor),
            byAlphabet.rightAnchor.constraint(equalTo: view.rightAnchor),
            byAlphabet.heightAnchor.constraint(equalToConstant: 45)
            ])
        
        byLatestDate.translatesAutoresizingMaskIntoConstraints = false
        byLatestDate.backgroundColor = UIColor.Diwi.azure
        byLatestDate.titleLabel?.font = UIFont.Diwi.floatingButton
        byLatestDate.contentHorizontalAlignment = .left
        byLatestDate.setTitle(TextContent.Buttons.byLatestDate, for: .normal)
        byLatestDate.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 43.0, bottom: 0.0, right: 0)
        view.addSubview(byLatestDate)
        view.sendSubviewToBack(byLatestDate)
        
        NSLayoutConstraint.activate([
            byLatestDate.topAnchor.constraint(equalTo: byAlphabet.bottomAnchor, constant: -45),
            byLatestDate.leftAnchor.constraint(equalTo: view.leftAnchor),
            byLatestDate.rightAnchor.constraint(equalTo: view.rightAnchor),
            byLatestDate.heightAnchor.constraint(equalToConstant: 45)
            ])
        
        byEarliestDate.translatesAutoresizingMaskIntoConstraints = false
        byEarliestDate.backgroundColor = UIColor.Diwi.azure
        byEarliestDate.titleLabel?.font = UIFont.Diwi.floatingButton
        byEarliestDate.contentHorizontalAlignment = .left
        byEarliestDate.setTitle(TextContent.Buttons.byEarliestDate, for: .normal)
        byEarliestDate.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 43.0, bottom: 0.0, right: 0)
        
        view.addSubview(byEarliestDate)
        
        view.sendSubviewToBack(byEarliestDate)
        
        NSLayoutConstraint.activate([
            byEarliestDate.topAnchor.constraint(equalTo: byLatestDate.bottomAnchor, constant: -45),
            byEarliestDate.leftAnchor.constraint(equalTo: view.leftAnchor),
            byEarliestDate.rightAnchor.constraint(equalTo: view.rightAnchor),
            byEarliestDate.heightAnchor.constraint(equalToConstant: 45)
        ])

    }
    
    private func setupEventsTable() {
        eventsTable.translatesAutoresizingMaskIntoConstraints = false
        eventsTable.register(EventCell.self, forCellReuseIdentifier: EventCell.identifier)
        eventsTable.dataSource = self
        eventsTable.delegate = self
        eventsTable.separatorColor = UIColor.Diwi.azure
        eventsTable.showsVerticalScrollIndicator = false
        eventsTable.separatorInset = UIEdgeInsets.zero
        eventsTable.register(TableViewFooter.self,
        forHeaderFooterViewReuseIdentifier: TableViewFooter.reuseIdentifier)
        
        view.addSubview(eventsTable)
        
        NSLayoutConstraint.activate([
            eventsTable.topAnchor.constraint(equalTo: header.bottomAnchor),
            eventsTable.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            eventsTable.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            eventsTable.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // MARK: - Set tableview footer
        let footerView = TableViewFooter(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 75))
        
        footerView.setup(text: TextContent.Labels.removeEvents, style: .largeButton)
        
        footerView.buttonPressed = { [weak self] in
            self?.viewModel.removeItemsFromEvents()
        }
        
        eventsTable.tableFooterView = footerView
    }
    
    private func setupEmpty() {
        emptyTopLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyTopLabel.text = "Get started with"
        emptyTopLabel.textColor = UIColor.Diwi.barney
        emptyTopLabel.font = UIFont.Diwi.h2
        view.addSubview(emptyTopLabel)
        
        NSLayoutConstraint.activate([
            emptyTopLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyTopLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -220)
            ])
        
        
        emptyHeading.translatesAutoresizingMaskIntoConstraints = false
        emptyHeading.text = "DIWI"
        emptyHeading.textColor = UIColor.Diwi.barney
        emptyHeading.font = UIFont.Diwi.jumbo
        view.addSubview(emptyHeading)
        
        NSLayoutConstraint.activate([
            emptyHeading.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyHeading.topAnchor.constraint(equalTo: emptyTopLabel.bottomAnchor, constant: -24)
            ])
        
        emptySubHeading.translatesAutoresizingMaskIntoConstraints = false
        emptySubHeading.text = "Press the blue plus sign down below."
        emptySubHeading.textColor = UIColor.Diwi.darkGray
        emptySubHeading.font = UIFont.Diwi.floatingButton
        view.addSubview(emptySubHeading)
        
        NSLayoutConstraint.activate([
            emptySubHeading.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptySubHeading.topAnchor.constraint(equalTo: emptyHeading.bottomAnchor, constant: -24)
            ])
        
        self.hideEmpty()
    }
    
    private func setupSearch() {
        eventSearch.translatesAutoresizingMaskIntoConstraints = false
        eventSearch.delegate = self
        eventSearch.tableViewHeightChange = { [weak self] height in
            if height == 0 {
                self?.eventSearchResultsHeight.constant = 50
            } else {
                self?.eventSearchResultsHeight.constant = height
            }
        }
        view.addSubview(eventSearch)
        
        eventSearchResultsHeight = eventSearch.heightAnchor.constraint(equalToConstant: 50)
        
        NSLayoutConstraint.activate([
            eventSearch.topAnchor.constraint(equalTo: navTitle.bottomAnchor, constant: 20),
            eventSearch.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            eventSearch.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            eventSearchResultsHeight
            ])
    }
    
    private func setupSpinner() {
        spinnerView = UIView.init(frame: view.bounds)
    }
}

extension RemoveEventsViewController: AutocompleteDelegate {
    func didSelectTag(withId: Int) {
        viewModel.selectTag(withId: withId)
    }
    
    func didStartEditing() {
        viewModel.clearInputValue()
    }
    
    func didFinishEditing() {
        viewModel.setInputValue()
        viewModel.searchEvents()
    }
}

extension RemoveEventsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = viewModel.events.value.count
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EventCell.identifier, for: indexPath) as! EventCell
        
        cell.event = viewModel.events.value[indexPath.row]
        cell.setup()
        cell.selectionStyle = .none
        cell.showDeleteButton = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? EventCell,
            let id = cell.event.id else { return }
        
        if cell.selectedForDeletion {
            viewModel.removeItemToBeDeleted(id: id)
            cell.selectedForDeletion = false
        } else {
            viewModel.addItemToBeDeleted(id: id)
            cell.selectedForDeletion = true
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
        if viewModel.events.value.count > 0 {
            self.hideEmpty()
            numOfSections = 1
            tableView.backgroundView = nil
            tableView.separatorStyle  = .singleLine
        }
        else {
            tableView.separatorStyle  = .none
            self.showEmpty()
        }
        return numOfSections
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView,
                   estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 50.0
    }
}
