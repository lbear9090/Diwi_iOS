import UIKit
import RxSwift
import RxCocoa

class EventCalendarContainerViewController: UIViewController {
    
    // MARK: - view props
    let calendar = CalendarViewController()
    let scroll = UIScrollView()
    let header = UIView()
    let backIcon = UIButton()
    let navTitle = UILabel()
    let eventsTable = UITableView()
    let bg = UIView()
    let cheersIcon = UIImageView()
    
    // MARK: - internal props
    weak var coordinator: MainCoordinator?
    let data = ["a", "b", "c"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: - Setup view
extension EventCalendarContainerViewController {
    private func setupView() {
        view.backgroundColor = UIColor.white
        setupHeader()
        setupNav()
        setupCalendar()
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
        backIcon.translatesAutoresizingMaskIntoConstraints = false
        backIcon.setImage(UIImage.Diwi.backIconWhite, for: .normal)
        header.addSubview(backIcon)

        var paddingTop = CGFloat(25)
        if hasNotch() {
            paddingTop += 30
        }

        NSLayoutConstraint.activate([
            backIcon.topAnchor.constraint(equalTo: header.topAnchor, constant: paddingTop),
            backIcon.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 10),
            backIcon.widthAnchor.constraint(equalToConstant: 25),
            backIcon.heightAnchor.constraint(equalToConstant: 25)
            ])

        navTitle.translatesAutoresizingMaskIntoConstraints = false
        navTitle.textColor = UIColor.white
        navTitle.text = TextContent.Labels.calendar
        navTitle.font = UIFont.Diwi.titleBold
        header.addSubview(navTitle)

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
    
    private func setupCalendar() {
        addChild(calendar)
        view.addSubview(calendar.view)
        calendar.didMove(toParent: self)
        calendar.view.isUserInteractionEnabled = true
        calendar.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            calendar.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            calendar.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            calendar.view.topAnchor.constraint(equalTo: view.topAnchor),
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
            eventsTable.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 650),
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
            bg.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 575),
            bg.leftAnchor.constraint(equalTo: view.leftAnchor),
            bg.rightAnchor.constraint(equalTo: view.rightAnchor),
            bg.bottomAnchor.constraint(equalTo: scroll.bottomAnchor)
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
        let count = data.count
        let height = 100 * count
        for constraint in eventsTable.constraints {
            if constraint.identifier == "Height" {
                constraint.constant = CGFloat(height)
                eventsTable.layoutIfNeeded()
                bg.layoutIfNeeded()
            }
        }
    }
}

extension EventCalendarContainerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = data.count
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EventCalendarCell.identifier, for: indexPath) as! EventCalendarCell
        cell.setup()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected event")

    }
}
