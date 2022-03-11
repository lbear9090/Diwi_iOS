//
//  RemoveEventsFromCalendarViewController.swift
//  Diwi
//
//  Created by Dominique Miller on 1/13/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import JTAppleCalendar

class RemoveEventsFromCalendarViewController: UIViewController {
    
    // MARK: - view props
    let calendar        = JTACMonthView()
    let calendarTitle   = UILabel()
    let calendarHeader  = UIStackView()
    let leftArrow       = UIButton()
    let rightArrow      = UIButton()
    let backButton      = UIButton()
    let scroll          = UIScrollView()
    let header          = UIView()
    let backIcon        = UIButton()
    let navTitle        = UILabel()
    let eventsTable     = UITableView()
    let bg              = UIView()
    let cheersIcon      = UIImageView()
    
    // MARK: - internal props
    let disposeBag = DisposeBag()
    var viewModel: CalendarViewModel!
    var workflow: Workflow {
        return self.viewModel.workflow
    }
    let screenWidth = UIScreen.main.bounds.width
    var removeEvent: ((_ event: Event) -> Void)?
    var goBack: (() -> Void)?
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        if viewModel.getEventsCount() > 0 {
           viewModel.getEvents()
        }
    }
    
    private func scrollByMonth(offset: Int) {
        let newDate = Calendar.current.date(byAdding: .month, value: offset, to: self.viewModel.viewingDate.value)
        self.calendar.scrollToDate(newDate!)
    }
    
    private func updateTitle() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        calendarTitle.text = formatter.string(from: viewModel.viewingDate.value)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
   
}

// MARK: - Setup bindings
extension RemoveEventsFromCalendarViewController {
    private func setupBindings() {
        rightArrow.rx.tap.bind {
                self.scrollByMonth(offset: 1)
            }
            .disposed(by: disposeBag)
        
        leftArrow.rx.tap.bind {
                self.scrollByMonth(offset: -1)
            }
            .disposed(by: disposeBag)
        
        
        viewModel.viewingDate.asDriver().throttle(0.01).drive(onNext: { _ in
            self.updateTitle()
            self.viewModel.filterEvents()
        }).disposed(by: disposeBag)
        
        backButton.rx.tap.bind {
            self.goBack?()
        }.disposed(by: disposeBag)
    
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
    }
}

// MARK: - Setup view
extension RemoveEventsFromCalendarViewController {
    private func setupView() {
        view.backgroundColor = UIColor.white
        setupHeader()
        setupNav()
        setupScroll()
        setupCalendarTitle()
        setupCalendarControls()
        setupCalendarHeader()
        setupCalendar()
        setupEventsTable()
        setupBg()
        setupCheersIcon()
        setTableHeight()
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
        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = UIColor.Diwi.yellow
        view.backgroundColor = UIColor.white
        view.addSubview(header)
        
        var height: NSLayoutConstraint
        if hasNotch() {
            height = header.heightAnchor.constraint(equalToConstant: 90)
        }
        else {
            height = header.heightAnchor.constraint(equalToConstant: 60)
        }
        
        NSLayoutConstraint.activate([
            header.leftAnchor.constraint(equalTo: view.leftAnchor),
            header.rightAnchor.constraint(equalTo: view.rightAnchor),
            header.topAnchor.constraint(equalTo: view.topAnchor),
            height
            ])
    }
    
    private func setupNav() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.setImage(UIImage.Diwi.backIconWhite, for: .normal)
        view.addSubview(backButton)
        
        var paddingTop = CGFloat(25)
        if hasNotch() {
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
        navTitle.text = TextContent.Labels.removeEvent
        navTitle.font = UIFont.Diwi.titleBold
        view.addSubview(navTitle)

        NSLayoutConstraint.activate([
            navTitle.topAnchor.constraint(equalTo: header.topAnchor, constant: paddingTop),
            navTitle.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            ])
    }
    
    private func setupScroll() {
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: header.bottomAnchor),
            scroll.leftAnchor.constraint(equalTo: view.leftAnchor),
            scroll.rightAnchor.constraint(equalTo: view.rightAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
    }
    
    private func setupEventsTable() {
        eventsTable.translatesAutoresizingMaskIntoConstraints = false
        eventsTable.register(EventCalendarCell.self, forCellReuseIdentifier: EventCalendarCell.identifier)
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
        let count = viewModel.getEventsCount()
        let height = (100 * count)
        for constraint in eventsTable.constraints {
            if constraint.identifier == "Height" {
                constraint.constant = CGFloat(height)
                eventsTable.layoutIfNeeded()
                bg.layoutIfNeeded()
            }
        }
    }
}

// MARK: - JTACMonthViewDataSource
extension RemoveEventsFromCalendarViewController: JTACMonthViewDataSource {
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

// MARK: - Calendar view delegate methods
extension RemoveEventsFromCalendarViewController: JTACMonthViewDelegate {
    
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
        guard let event = viewModel.getEvent(on: date) else { return }
        
        removeEvent?(event)
    }
    
    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {}
}

// MARK: - Events list
extension RemoveEventsFromCalendarViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getEventsCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EventCalendarCell.identifier, for: indexPath) as! EventCalendarCell
        cell.event = viewModel.eventForIndex(indexPath: indexPath)
        let hideIcon = workflow == .addEventOrDateToClosetItem ? true : false
        cell.setup(hideIcon: hideIcon, iconImage: UIImage.Diwi.closeBtn)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = viewModel.eventForIndex(indexPath: indexPath)
        
        removeEvent?(event)
    }
}
