//
//  ChooseNewEventDateViewController.swift
//  Diwi
//
//  Created by Jae Lee on 10/24/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//


import UIKit
import RxSwift
import RxCocoa
import JTAppleCalendar

class ChooseNewEventDateViewController: UIViewController {
    
    // MARK: - view props
    let navHeader        = NavHeader()
    let calendar         = JTACMonthView()
    let calendarTitle    = UILabel()
    let calendarHeader   = UIStackView()
    let leftArrow        = UIButton()
    let rightArrow       = UIButton()
    let scroll           = UIScrollView()
    let eventsTable      = UITableView()
    let bg               = UIView()
    let cheersIcon       = UIImageView()
    let saveDate         = AppButton()
    
    
    
    // MARK: - internal props
    let disposeBag = DisposeBag()
    weak var coordinator: MainCoordinator?
    var goBack: (() -> Void)?
    var goToSearch: (() -> Void)?
    var saveTheDate: ((_ date: Date) -> Void)?
    var viewModel: CalendarViewModel!
    let emptyCalenderEventCellHeight = 130
    lazy var workflow: Workflow = {
        return viewModel.workflow
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupBindings()
        updateTitle()
        calendar.scrollToDate(viewModel.viewingDate.value, animateScroll: false)
        viewModel.getEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    private func scrollByMonth(offset: Int) {
        let newDate = Calendar.current.date(byAdding: .month, value: offset, to: self.viewModel.viewingDate.value)
        self.calendar.scrollToDate(newDate!)
    }
    
    private func updateTitle() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        let dateString = formatter.string(from: viewModel.viewingDate.value)
        calendarTitle.text = dateString.uppercased()
    }
    
    private func didTapDate(_ date: Date) {
        if workflow == .calendarIndex {
        } else if workflow == .addDatesToFriend {
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
   
}

// MARK: - Setup bindings
extension ChooseNewEventDateViewController {
    private func setupBindings() {
        rightArrow.rx.tap.bind { [unowned self] in
                self.scrollByMonth(offset: 1)
            }
            .disposed(by: disposeBag)
        
        leftArrow.rx.tap.bind { [unowned self] in
                self.scrollByMonth(offset: -1)
            }
            .disposed(by: disposeBag)
        
        saveDate.rx.tap.bind { [unowned self] in
            self.saveDate.buttonPressedAnimation {
                self.saveTheDate?(self.viewModel.getSelectedDateForFriend())
            }
        }.disposed(by: disposeBag)
        
        viewModel.viewingDate.asDriver().throttle(0.01).drive(onNext: { _ in
            self.updateTitle()
            self.viewModel.filterEvents()
        }).disposed(by: disposeBag)
        
        viewModel.events
            .subscribe(onNext: { [unowned self] (value: [Event]) in
                self.calendar.reloadData()
                self.viewModel.filterEvents()
            }).disposed(by: disposeBag)
        
        viewModel.viewingEvents
            .subscribe(onNext: { [unowned self] (value: [Event]) in
                self.eventsTable.reloadData()
                self.setTableHeight()
            }).disposed(by: disposeBag)
        
        viewModel.navTitle
            .subscribe(onNext: { [unowned self] text in
                self.navHeader.navTitle.text = text
        }).disposed(by: disposeBag)
        
        viewModel.saveBtnText
            .subscribe(onNext: { [unowned self] text in
                self.saveDate.setTitle(text, for: .normal)
        }).disposed(by: disposeBag)
    }
}

// MARK: - Setup view
extension ChooseNewEventDateViewController {
    private func setupView() {
        view.backgroundColor = UIColor.white
        setupHeader()
        setupScroll()
        setupCalendarTitle()
        setupCalendarControls()
        setupCalendarHeader()
        setupCalendar()
        
        if workflow == .calendarIndex {
          setupEventsTable()
          setupBg()
          setupCheersIcon()
          setTableHeight()
        }
        
        if saveDateWorkflow() {
            setupSaveDate()
        }
    }
    
    private func setupCalendarTitle() {
        calendarTitle.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(calendarTitle)
        calendarTitle.textColor = UIColor.Diwi.azure
        calendarTitle.font = UIFont.Diwi.h1b
        calendarTitle.text = "MAY 2016"
        
        NSLayoutConstraint.activate([
            calendarTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            calendarTitle.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 75)
            ])
    }
    
    private func setupCalendarControls() {
        leftArrow.translatesAutoresizingMaskIntoConstraints = false
        leftArrow.setImage(UIImage.Diwi.leftArrow, for: .normal)
        scroll.addSubview(leftArrow)
        NSLayoutConstraint.activate([
            leftArrow.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            leftArrow.centerYAnchor.constraint(equalTo: calendarTitle.centerYAnchor),
            leftArrow.heightAnchor.constraint(equalToConstant: 28),
            leftArrow.widthAnchor.constraint(equalToConstant: 28)
            ])
        
        rightArrow.translatesAutoresizingMaskIntoConstraints = false
        rightArrow.setImage(UIImage.Diwi.rightArrow, for: .normal)
        scroll.addSubview(rightArrow)
        NSLayoutConstraint.activate([
            rightArrow.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            rightArrow.centerYAnchor.constraint(equalTo: calendarTitle.centerYAnchor),
            rightArrow.heightAnchor.constraint(equalToConstant: 28),
            rightArrow.widthAnchor.constraint(equalToConstant: 28)
            ])
    }
    
    private func setupCalendarHeader() {
        calendarHeader.translatesAutoresizingMaskIntoConstraints = false
        calendarHeader.axis = .horizontal
        calendarHeader.alignment = .center
        calendarHeader.distribution = .fillEqually
        let days = ["s", "m", "t", "w", "t", "f", "s"]
        for d in days {
            let day = UILabel()
            day.text = d
            day.font = UIFont.Diwi.floatingButton
            day.textColor = UIColor.Diwi.darkGray
            day.textAlignment = .center
            calendarHeader.addArrangedSubview(day)
        }
        
        scroll.addSubview(calendarHeader)
        
        NSLayoutConstraint.activate([
            calendarHeader.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            calendarHeader.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            calendarHeader.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            calendarHeader.topAnchor.constraint(equalTo: calendarTitle.bottomAnchor, constant: 25)
            ])
    }
    
    private func setupCalendar() {
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.backgroundColor = UIColor.white
        calendar.calendarDataSource = self
        calendar.calendarDelegate = self
        calendar.scrollingMode = .stopAtEachCalendarFrame
        calendar.scrollDirection = .horizontal
        calendar.showsHorizontalScrollIndicator = false
        calendar.isPagingEnabled = true
        calendar.allowsMultipleSelection = true
        
        calendar.register(CalendarCell.self, forCellWithReuseIdentifier: CalendarCell.reuseIdentifier)
        scroll.addSubview(calendar)
        
        NSLayoutConstraint.activate([
            calendar.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            calendar.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            calendar.topAnchor.constraint(equalTo: calendarHeader.bottomAnchor, constant: 30),
            calendar.heightAnchor.constraint(equalToConstant: 300)
            ])
    }
    
    private func setupHeader() {
        navHeader.translatesAutoresizingMaskIntoConstraints = false
        navHeader.setup(backgroundColor: UIColor.Diwi.yellow,
                        style: .normal,
                        navTitle: TextContent.Labels.whenIworeIt)
        
        navHeader.leftButtonAction = { [weak self] in
            self?.goBack?()
        }
        
        navHeader.rightButtonAction = { [weak self] in
            self?.goToSearch?()
        }
        
        view.backgroundColor = UIColor.white
        view.addSubview(navHeader)
        
        var headerHeight: CGFloat = 60
        
        if hasNotch() {
            headerHeight += 30
        }
        
        NSLayoutConstraint.activate([
            navHeader.leftAnchor.constraint(equalTo: view.leftAnchor),
            navHeader.rightAnchor.constraint(equalTo: view.rightAnchor),
            navHeader.topAnchor.constraint(equalTo: view.topAnchor),
            navHeader.heightAnchor.constraint(equalToConstant: headerHeight)
        ])
        
    }
    
    private func setupScroll() {
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: navHeader.bottomAnchor),
            scroll.leftAnchor.constraint(equalTo: view.leftAnchor),
            scroll.rightAnchor.constraint(equalTo: view.rightAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
    
    private func setupEventsTable() {
        eventsTable.translatesAutoresizingMaskIntoConstraints = false
        eventsTable.register(EventCalendarCell.self, forCellReuseIdentifier: EventCalendarCell.identifier)
        eventsTable.register(EmptyEventCell.self, forCellReuseIdentifier: EmptyEventCell.identifier)
        eventsTable.dataSource = self
        eventsTable.delegate = self
        eventsTable.isScrollEnabled = false
        eventsTable.allowsSelection = true
        eventsTable.separatorInset = UIEdgeInsets.zero
        scroll.addSubview(eventsTable)
        let height = eventsTable.heightAnchor.constraint(equalToConstant: 0)
        height.identifier = "Height"
        NSLayoutConstraint.activate([
            eventsTable.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 625),
            eventsTable.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            eventsTable.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            eventsTable.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: -30),
            height
            ])
        
    }
    
    private func setupBg() {
        bg.translatesAutoresizingMaskIntoConstraints = false
        bg.backgroundColor = UIColor.Diwi.azure
        scroll.addSubview(bg)
        scroll.sendSubviewToBack(bg)
        
        NSLayoutConstraint.activate([
            bg.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 550),
            bg.leftAnchor.constraint(equalTo: view.leftAnchor),
            bg.rightAnchor.constraint(equalTo: view.rightAnchor),
            bg.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: 35)
            ])
    }
    
    private func setupCheersIcon() {
        cheersIcon.translatesAutoresizingMaskIntoConstraints = false
        cheersIcon.image = UIImage.Diwi.cheersIcon
        view.addSubview(cheersIcon)
        
        NSLayoutConstraint.activate([
            cheersIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cheersIcon.centerYAnchor.constraint(equalTo: bg.topAnchor)
            ])
    }
    
    private func setTableHeight() {
        let count = viewModel.viewingEvents.value.count
        var height:Int = 0
        if count == 0 {
            height = emptyCalenderEventCellHeight
        } else {
            height = 100 * count
        }
        for constraint in eventsTable.constraints {
            if constraint.identifier == "Height" {
                constraint.constant = CGFloat(height)
                eventsTable.layoutIfNeeded()
                bg.layoutIfNeeded()
            }
        }
    }
    
    private func setupSaveDate() {
        saveDate.translatesAutoresizingMaskIntoConstraints = false
        saveDate.titleLabel?.font = UIFont.Diwi.button
        saveDate.isEnabled = false
        
        view.addSubview(saveDate)
        
        NSLayoutConstraint.activate([
            saveDate.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            saveDate.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            saveDate.heightAnchor.constraint(equalToConstant: 50),
            saveDate.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -34)
        ])
    }
}

extension ChooseNewEventDateViewController: JTACMonthViewDataSource {
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        let startDate = formatter.date(from: "2010 01 01")!
        let endDate = formatter.date(from: "2050 01 01")!
        return ConfigurationParameters(startDate: startDate,
                                       endDate: endDate,
                                       generateInDates: .forAllMonths,
                                       generateOutDates: .tillEndOfGrid)
    }
}

extension ChooseNewEventDateViewController: JTACMonthViewDelegate {
    
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: CalendarCell.reuseIdentifier, for: indexPath) as! CalendarCell
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        return cell
    }
    
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        configureCell(view: cell, cellState: cellState)
    }
    
    func configureCell(view: JTACDayCell?, cellState: CellState) {
        guard let cell = view as? CalendarCell  else { return }
        let events = viewModel.events.value
        
        if events.count == 0 {
            cell.shouldHighlight = false
            cell.update(cellState: cellState)
        }
        
        for event in events {
            if Calendar.current.compare(event.date!, to: cellState.date, toGranularity: .day) == .orderedSame {
                cell.shouldHighlight = true
                cell.update(cellState: cellState)
                return
            }
            else {
                cell.shouldHighlight = false
                cell.update(cellState: cellState)
            }
        }
    }
    
    func calendarDidScroll(_ calendar: JTACMonthView) {
        let dates = calendar.visibleDates()
        let date = dates.monthDates.first?.date
        if let date = date {
            viewModel.viewingDate.accept(date)
        }
    }

    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        if saveDateWorkflow() {
            if let calendarCell = cell as? CalendarCell {
                // update currently selected date cell
                calendarCell.shouldHighlight = true
                calendarCell.update(cellState: cellState, workflow: workflow)
                
                // remove highlighting for previously selected cell
                let previousCellDate = viewModel.getPreviousSelectedCellForFriend()
                previousCellDate.resetMarker()
                
                // update selected date for friend
                viewModel.addSelectedDateForFriend(date: date)
                
                // update previous selected cell to currently selected
                viewModel.setPreviousSelectedCellForFriend(with: calendarCell)
                
                // enable save button for user
                if !saveDate.isEnabled {
                    saveDate.isEnabled = true
                }
            }
        } else {
            didTapDate(date)
        }
    }
    
    private func saveDateWorkflow() -> Bool {
        return workflow == .addDatesToFriend || workflow == .addDatesToLook || workflow == .addDatesToItem
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        if saveDateWorkflow() {
            if let calendarCell = cell as? CalendarCell {
                   calendarCell.shouldHighlight = false
                   calendarCell.update(cellState: cellState, workflow: workflow)
            }
        }
    }
}

extension ChooseNewEventDateViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = viewModel.viewingEvents.value.count
        if count == 0 {
            return 1
        } else {
            return count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let count = viewModel.viewingEvents.value.count
        if count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: EmptyEventCell.identifier, for: indexPath) as! EmptyEventCell
            cell.setup()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: EventCalendarCell.identifier, for: indexPath) as! EventCalendarCell
            cell.event = viewModel.viewingEvents.value[indexPath.row]
            cell.setup(hideIcon: true)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if viewModel.viewingEvents.value.count == 0 {
            return CGFloat(emptyCalenderEventCellHeight)
        } else {
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected event")
        
    }
}
