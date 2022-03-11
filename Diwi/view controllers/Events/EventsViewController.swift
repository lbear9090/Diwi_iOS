import UIKit
import RxSwift
import RxCocoa

class EventsViewController: UIViewController {
    
    // MARK: - view props
    let header          = UIView()
    let homePageIcon    = UIButton()
    let searchIcon      = UIButton()
    let navTitle        = UILabel()
    let filterToggle    = UIButton()
    let buttonBorder    = UIView()
    let arrowIcon       = UIImageView()
    let byAlphabet      = UIButton()
    let byLatestDate    = UIButton()
    let byEarliestDate  = UIButton()
    let addIcon         = UIButton()
    let backButton      = UIButton()
    let emptyMessage    = AppButton()
    let bottomButtonContainer = UIView()
    let saveEvents      = AppButton()

    let eventsTable = UITableView()
    let eventSearch = EventSearch()

    // MARK: - internal props
    weak var coordinator: MainCoordinator?
    let disposeBag = DisposeBag()
    var viewModel: EventsViewModel!
    let filtersOpen = BehaviorRelay<Bool>(value: false)
    lazy var workflow: Workflow = {
        return viewModel.workflow
    }()
    var selectedEventToAdd: ((_ event: Event) -> Void)?
    var selectedEventsToAdd: ((_ event: [Event]) -> Void)?
    var addEventToClosetItem: ((_ event: Event) -> Void)?
    var showSingleEvent: ((_ event: Event) -> Void)?
    var removeEvents: (() -> Void)?
    var goToSearch: (() -> Void)?
    var goToHomePage: (() -> Void)?
    let screenWidth = UIScreen.main.bounds.width
    var eventSearchResultsHeight: NSLayoutConstraint = NSLayoutConstraint()
    var headerHeightAnchor: NSLayoutConstraint = NSLayoutConstraint()
    var eventsTableBottomPadding: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createViewModelBinding()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
           super.viewDidAppear(true)
           
           if viewModel.events.value.count > 0 {
               viewModel.getEvents()
           }
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
        emptyMessage.isHidden = true
        addIcon.isHidden = false
        filterToggle.isHidden = false
        buttonBorder.isHidden = false
        arrowIcon.isHidden = false
        eventSearch.isHidden = false
        headerHeightAnchor.constant = hasNotch() ? 215 : 185
        view.layoutIfNeeded()
    }
    
    private func showEmpty() {
        emptyMessage.isHidden = false
        addIcon.isHidden = true
        filterToggle.isHidden = true
        buttonBorder.isHidden = true
        arrowIcon.isHidden = true
        eventSearch.isHidden = true
        headerHeightAnchor.constant = hasNotch() ? 90 : 60
        
        view.layoutIfNeeded()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}

// MARK: - View model bindings
extension EventsViewController {
    private func createViewModelBinding() {
        saveEvents.rx.tap.bind {
            self.selectedEventsToAdd?(self.viewModel.getSelectedEvents())
        }.disposed(by: disposeBag)

        homePageIcon.rx.tap.bind {
            self.goToHomePage?()
        }.disposed(by: disposeBag)
        
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
        
        addIcon.rx.tap.bind {
            self.addIcon.buttonPressedAnimation {
                self.coordinator?.chooseNewEventDate()
            }
        }.disposed(by: disposeBag)
        
        emptyMessage.rx.tap.bind {
            self.coordinator?.chooseNewEventDate()
        }.disposed(by: disposeBag)
        
        backButton.rx.tap.bind { [unowned self] in
            self.coordinator?.popController()
        }.disposed(by: disposeBag)
        
        searchIcon.rx.tap.bind { [unowned self] in
            self.goToSearch?()
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
                if value.count > 0 {
                    self.eventSearch.isEnabled = true
                    self.setupFooter()
                    self.hideEmpty()
                } else if value.count == 0 {
                    self.eventSearch.isEnabled = false
                    self.hideFooter()
                    self.showEmpty()
                }
                
                if self.workflow != .eventsIndex {
                    self.hideFooter()
                }
                
                if self.workflow == .addEvents || self.workflow == .addEventsToItem {
                    self.eventsTable.allowsMultipleSelection = true
                }
                
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

        viewModel.navTitle
            .subscribe(onNext: { [unowned self] text in
                self.navTitle.text = text
        }).disposed(by: disposeBag)
        
        viewModel.saveBtnText
            .subscribe(onNext: { [unowned self] text in
                self.saveEvents.setTitle(text, for: .normal)
        }).disposed(by: disposeBag)
        
        viewModel.noMatchingEventsForPerson
            .subscribe(onNext: { [unowned self] value in
                if value {
                    self.presentMessage(title: TextContent.Errors.oops, message: TextContent.Errors.noMatchingEventsFound)
                }
            }).disposed(by: disposeBag)
    }
}

// MARK: - Setup view
extension EventsViewController {
    private func setupView() {
        setupHeader()
        setupNav()
        setupFilterToggle()
        setupMenu()
        setupEventsTable()
        setupEmpty()
        setupSearch()
        setupAddIcon()
    }
    
    private func setupHeader() {
        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = UIColor.Diwi.azure
        view.backgroundColor = UIColor.white
        view.addSubview(header)
        
        var headerHeight: CGFloat = 185
        
        if hasNotch() {
            headerHeight += 30
        }
        
        headerHeightAnchor = header.heightAnchor.constraint(equalToConstant: headerHeight)
        NSLayoutConstraint.activate([
            header.leftAnchor.constraint(equalTo: view.leftAnchor),
            header.rightAnchor.constraint(equalTo: view.rightAnchor),
            header.topAnchor.constraint(equalTo: view.topAnchor),
            headerHeightAnchor
            ])
        
    }
    
    private func setupNav() {
        switch workflow {
        case .eventsIndex:
            setupIndexNav()
        case .addEvent:
            setupAddEventNav()
        case .addEventOrDateToClosetItem:
            setupAddEventNav()
        case .addEvents:
            setupAddEvents()
        case .addEventsToLook:
            setupAddEvents()
        case .addEventsToItem:
            setupAddEvents()
        default:
            setupIndexNav()
        }
    }
    
    private func setupAddEvents() {
        setupAddEventNav()
        setupSaveEvents()
        eventsTableBottomPadding = -60
    }
    
    private func setupAddEventNav() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage.Diwi.backIconWhite, for: .normal)
        view.addSubview(backButton)
        
        var paddingTop = CGFloat(25)
        
        if (hasNotch()) {
            paddingTop += 30
        }
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: header.topAnchor, constant: paddingTop),
            backButton.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 10),
            backButton.widthAnchor.constraint(equalToConstant: 28),
            backButton.heightAnchor.constraint(equalToConstant: 28)
            ])
        
        navTitle.translatesAutoresizingMaskIntoConstraints = false
        navTitle.textColor = UIColor.white
        navTitle.font = UIFont.Diwi.titleBold
        view.addSubview(navTitle)

        NSLayoutConstraint.activate([
            navTitle.topAnchor.constraint(equalTo: header.topAnchor, constant: paddingTop),
            navTitle.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            ])
    }
    
    private func setupIndexNav() {
        homePageIcon.translatesAutoresizingMaskIntoConstraints = false
        homePageIcon.setImage(UIImage.Diwi.homePageIcon, for: .normal)
        header.addSubview(homePageIcon)
        
        var paddingTop = CGFloat(25)
        
        if (hasNotch()) {
            paddingTop += 30
        }
        
        NSLayoutConstraint.activate([
            homePageIcon.topAnchor.constraint(equalTo: header.topAnchor, constant: paddingTop),
            homePageIcon.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 10),
            homePageIcon.widthAnchor.constraint(equalToConstant: 28),
            homePageIcon.heightAnchor.constraint(equalToConstant: 28)
            ])
        
        searchIcon.translatesAutoresizingMaskIntoConstraints = false
        searchIcon.setImage(UIImage.Diwi.searchIcon, for: .normal)
        header.addSubview(searchIcon)
        
        NSLayoutConstraint.activate([
            searchIcon.topAnchor.constraint(equalTo: header.topAnchor, constant: paddingTop),
            searchIcon.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -10),
            searchIcon.widthAnchor.constraint(equalToConstant: 28),
            searchIcon.heightAnchor.constraint(equalToConstant: 28)
            ])
        
        navTitle.translatesAutoresizingMaskIntoConstraints = false
        navTitle.textColor = UIColor.white
        navTitle.text = TextContent.Labels.events
        navTitle.font = UIFont.Diwi.titleBold
        header.addSubview(navTitle)
        
        NSLayoutConstraint.activate([
            navTitle.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            navTitle.centerYAnchor.constraint(equalTo: searchIcon.centerYAnchor)
            ])
        
    }
    
    private func setupFilterToggle() {
        filterToggle.translatesAutoresizingMaskIntoConstraints = false
        filterToggle.setTitle(TextContent.Buttons.sortEvents, for: .normal)
        filterToggle.titleLabel?.font = UIFont.Diwi.floatingButton
        filterToggle.addBottomBorder()
        filterToggle.contentHorizontalAlignment = .left
        header.addSubview(filterToggle)
        
        let padding = CGFloat(66)
        
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
            eventsTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: eventsTableBottomPadding)
        ])
    }
    
    private func setupFooter() {
        // MARK: - Set tableview footer
        let footerView = TableViewFooter(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 150))
        
        footerView.setup(text: TextContent.Labels.removeEvents, style: .normal)
        
        footerView.buttonPressed = { [weak self] in
            self?.removeEvents?()
        }
        
        eventsTable.tableFooterView = footerView
    }
    
    private func hideFooter() {
        eventsTable.tableFooterView = nil
    }
    
    private func setupEmpty() {
        emptyMessage.translatesAutoresizingMaskIntoConstraints = false
        emptyMessage.inverseColor()
        emptyMessage.setTitle(TextContent.Buttons.addEvents, for: .normal)
        emptyMessage.setTitleColor(UIColor.Diwi.barney, for: .normal)
        emptyMessage.titleLabel?.font = UIFont.Diwi.button
        
        view.addSubview(emptyMessage)
        
        NSLayoutConstraint.activate([
            emptyMessage.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            emptyMessage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyMessage.heightAnchor.constraint(equalToConstant: 50),
            emptyMessage.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            emptyMessage.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30)
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
    private func setupAddIcon() {
        addIcon.translatesAutoresizingMaskIntoConstraints = false
        addIcon.setImage(UIImage.Diwi.addEventWhite, for: .normal)
        
        var padding: CGFloat = -30
        
        if workflow != .eventsIndex {
            addIcon.isHidden = true
            padding = -85
        }
        
        view.addSubview(addIcon)
        
        NSLayoutConstraint.activate([
            addIcon.heightAnchor.constraint(equalToConstant: 59),
            addIcon.widthAnchor.constraint(equalToConstant: 59),
            addIcon.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: padding),
            addIcon.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
        ])
    }
    
    private func setupSaveEvents() {
        bottomButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        bottomButtonContainer.backgroundColor = .white
        
        view.addSubview(bottomButtonContainer)
        view.bringSubviewToFront(bottomButtonContainer)
        
        NSLayoutConstraint.activate([
            bottomButtonContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
            bottomButtonContainer.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomButtonContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            bottomButtonContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        saveEvents.translatesAutoresizingMaskIntoConstraints = false
        saveEvents.titleLabel?.font = UIFont.Diwi.button
        
        bottomButtonContainer.addSubview(saveEvents)
        
        NSLayoutConstraint.activate([
            saveEvents.leftAnchor.constraint(equalTo: bottomButtonContainer.leftAnchor, constant: 30),
            saveEvents.rightAnchor.constraint(equalTo: bottomButtonContainer.rightAnchor, constant: -30),
            saveEvents.heightAnchor.constraint(equalToConstant: 50),
            saveEvents.centerYAnchor.constraint(equalTo: bottomButtonContainer.centerYAnchor)
        ])
    }
}

extension EventsViewController: AutocompleteDelegate {
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

// MARK: - TableView Delegate methods
extension EventsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = viewModel.events.value.count
        
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EventCell.identifier, for: indexPath) as! EventCell
        cell.event = viewModel.events.value[indexPath.row]
        cell.setup()
        cell.selectionStyle = .none
        if workflow == .addEvents || workflow == .addEventsToLook || workflow == .addEventsToItem {
            cell.showDeleteButton = true
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? EventCell else { return }
        
        let event = viewModel.eventAtIndex(indexPath.row)
        
        if workflow == .addEvent {
            selectedEventToAdd?(event)
        } else if workflow == .addEventOrDateToClosetItem {
            addEventToClosetItem?(event)
        } else if workflow == .eventsIndex {
            showSingleEvent?(event)
        } else if workflow == .addEvents {
            cell.selectedForDeletion = true
            viewModel.addToSelectedEvents(event: event)
        } else if workflow == .addEventsToLook || workflow == .addEventsToItem {
            cell.selectedForDeletion = true
            viewModel.addToSelectedEvents(event: event)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? EventCell else { return }
        
        let event = viewModel.eventAtIndex(indexPath.row)
        
        if workflow == .addEvents ||
            workflow == .addEventsToItem ||
            workflow == .addEventsToLook {
            cell.selectedForDeletion = false
            viewModel.removeFromSelectedEvents(event: event)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 125
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
        if viewModel.events.value.count > 0 {
            numOfSections = 1
            tableView.backgroundView = nil
            tableView.separatorStyle  = .singleLine
        }
        else {
            tableView.separatorStyle  = .none
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
