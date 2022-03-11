
import Foundation
import UIKit

class MainCoordinator: Coordinator {
    
    var childCoordinators: [Coordinator]?
    var navigationController: UINavigationController
    var presentingController: UIViewController? {
        return navigationController.topViewController
    }
    var tabBarController: DiwiTabBarController!
    
    // stored state
    var clothingItem: ClothingItem?
    var look: Look?
    var selectedEvent: Event?
    var selectedEvents =  [Event]()
    var selectedClothingItems = [ClothingItem]()
    var selectedItemsForNewClosetItem = [ClosetItem]()
    var selectedLooks = [Look]()
    var selectedDate: Date?
    var idsToRemove: [Int] = []
    var imageUrl = [URL]()
    init(navController: UINavigationController) {
        navigationController = navController
    }
    
    private func clearState() {
        clothingItem = nil
        look = nil
        selectedEvent = nil
        selectedEvents = []
        selectedDate = nil
        selectedClothingItems = []
        selectedLooks = []
        idsToRemove = []
        selectedItemsForNewClosetItem = []
    }
    
    private func indexOfViewController(vc: UIViewController) -> Int? {
        let viewControllers = navigationController.viewControllers
        guard let index = viewControllers.firstIndex(of: vc) else { return nil }
        
        return index
    }
    
    private func removeViewController(at index: Int) {
        navigationController.viewControllers.remove(at: index)
    }

    func start() {
        if KeychainService().getUserJWT() != nil {
            //login() //So that login is the root VC and we can pop back to this on logout
            startTabBarController()
        }
        else {
            login()
        }
    }
    
    func startTabBarController() {
        tabBarController = DiwiTabBarController()
        tabBarController.modalPresentationStyle = .currentContext
        self.navigationController.present(tabBarController, animated: true, completion: nil)
    }
    
    func homePage() {
        //TODO: Add App Delegate root window
    }
    
    func removeEventsFromCalendar() {
        let vc = RemoveEventsFromCalendarViewController()
        let vm = CalendarViewModel(eventService: EventService(), workflow: .calendarIndex)
        vc.viewModel = vm
        
        vc.goBack = { [weak self] in
            self?.popController()
        }
        
        vc.removeEvent = { [weak self] event in
            self?.selectedEvent = event
            self?.globalModal(workflow: .removeEventFromCalendar)
        }
        
        navigationController.setNavigationBarHidden(true, animated: true)
        navigationController.pushViewController(vc, animated: true)
    }

    func chooseNewEventDate(workflow: Workflow = .calendarIndex) {
        let vc = ChooseNewEventDateViewController()
        let vm = CalendarViewModel(eventService: EventService(), workflow: workflow)
        vc.viewModel = vm
        vc.coordinator = self
        vc.goBack = { [weak self] in
            self?.popController()
        }
        vc.saveTheDate = { [weak self] date in
            self?.selectedDate = date
            self?.popController()
        }
        navigationController.setNavigationBarHidden(true, animated: true)
        navigationController.pushViewController(vc, animated: true)
    }

    func logout() {
        KeychainService().clearValues()
        removeExistingTabBarFromStack()
        navigationController.popToRootViewController(animated: true)
    }

    func popController() {
        navigationController.popViewController(animated: true)
    }
	
	func account() -> ProfileViewController {
		let vc = ProfileViewController()
		let vm = ProfileViewModel(userInfoService: KeychainService(),
								  updateUserService: UserService())
		vc.viewModel = vm
		
		vc.goBack = { [weak self] in
			self?.popController()
		}
		
		vc.goTologout = { [weak self] in
			self?.logout()
		}
		
		return vc
	}

    func profile() {
        let vc = ProfileViewController()
        let vm = ProfileViewModel(userInfoService: KeychainService(),
                                  updateUserService: UserService())
        vc.viewModel = vm
        
        vc.goBack = { [weak self] in
            self?.popController()
        }
        
        vc.goTologout = { [weak self] in
            self?.logout()
        }
        
        navigationController.setNavigationBarHidden(true, animated: true)
        navigationController.pushViewController(vc, animated: true)
    }

    func login() {
        let vc = LoginViewController()
        vc.coordinator = self
        navigationController.setNavigationBarHidden(true, animated: true)
        navigationController.pushViewController(vc, animated: true)
    }

    func signup() {
        let vc = SignupViewController()
        vc.coordinator = self
        navigationController.setNavigationBarHidden(true, animated: true)
        navigationController.pushViewController(vc, animated: true)
    }

    func loading() {
        let vc = LoadingViewController()
        vc.coordinator = self
        navigationController.setNavigationBarHidden(true, animated: true)
        navigationController.pushViewController(vc, animated: true)
    }

    func forgotPassword() {
        let vc = ForgotPasswordViewController()
        let vm = ForgotPasswordViewModel(userService: UserService())
        vc.viewModel = vm
        
        vc.goToLogin = { [weak self] in
            self?.login()
        }
        
        vc.goToSignup = { [weak self] in
            self?.signup()
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    func onboarding() {
        let vc = OnboardingViewController()
        
        vc.finished = { [weak self] in
            self?.navigationController.popToRootViewController(animated: false)
            self?.start()
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    func selectedItem(){
        let vc = SelectedItemViewController()
        vc.goToCamera = { [weak self] in
            self?.newItem(workflow: .addClosetItem)
        }
        vc.goToNewItem = { [weak self]  in
//            self?.goToNewLookVC()
        }
        vc.goBack = { [weak self] in
            
        }
        vc.modalPresentationStyle = .fullScreen
        navigationController.pushViewController(vc, animated: true)
    }
    
    func goToNewLookVC(){
        let vc = NewLookVC()
        vc.modalPresentationStyle = .fullScreen
        navigationController.pushViewController(vc, animated: true)
    }
    
    func globalSearch() {
        guard let presentingVC = presentingController else { return }
        
        let vc = GlobalSearchViewController()
        let vm = GlobalSearchViewModel(searchService: GlobalSearchService())
        vc.modalPresentationStyle = .fullScreen
        vc.viewModel = vm
        
        vc.close = {
            presentingVC.dismiss(animated: true)
        }
        
        vc.goToResult = { [weak self] result in
            guard let id = result.id else { return }
            presentingVC.dismiss(animated: true) {
                switch result.modelType {
                case .ClothingItems:
                    let item = ClothingItem()
                    item.id = id
                    self?.closetItem(item: item)
                case .Contacts:
                    self?.viewContact(with: id)
                case .Events:
                    let event = Event()
                    event.id = id
                case .Looks:
                    self?.viewLook(with: id)
                default:
                    return
                }
            }
        }
        
        presentingVC.present(vc, animated: true)
    }
}

// MARK: - Closet
extension MainCoordinator {
    
    func addLook(workflow: Workflow = .defaultWorkflow) {
        let vc = AddLookViewController()
        vc.coordinator = self
        let vm = AddLookViewModel(lookService: LookService(),
                                  tagService: TagService(),
                                  workflow: workflow)
        vc.viewModel = vm
        
        vc.goBack = { [weak self] in
            self?.clearState()
            self?.popController()
        }
        
        vc.finished = { [weak self] look in
            if workflow == .defaultWorkflow {
               self?.clearState()
            } else {
               self?.look = look
            }
            self?.popController()
        }
        
        vc.addClosetItems = { [weak self] items in
            guard let clothingItems = items as? [ClothingItem] else { return }
            self?.selectedClothingItems = clothingItems
            self?.whatDidIWear(workflow: .addItemsToNewLook)
        }
        
        vc.addEvents = { [weak self] items in
            guard let events = items as? [Event] else { return }
            self?.selectedEvents = events
            self?.events(workflow: .addEventsToLook)
        }
        
        vc.addDates = { [weak self] in
            self?.chooseNewEventDate(workflow: .addDatesToLook)
        }
        
        vc.addContacts = { [weak self] in
            self?.chooseWhoController(viewModel: vm)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    func viewLook(with id: Int) {
        let vc = ViewEditLookController()
        let vm = ViewEditLookViewModel(id: id,
                                       lookService: LookService(),
                                       tagService: TagService())
        vc.viewModel = vm
        vc.coordinator = self
        
        vc.goBack = { [weak self] in
            self?.clearState()
            self?.popController()
        }
        
        vc.addClosetItems = { [weak self] items in
            guard let clothingItems = items as? [ClothingItem] else { return }
            self?.selectedClothingItems = clothingItems
            self?.whatDidIWear(workflow: .editLook)
        }
        
        vc.addEvents = { [weak self] items in
            guard let events = items as? [Event] else { return }
            self?.selectedEvents = events
            self?.events(workflow: .addEvents)
        }
        
        vc.addDates = { [weak self] in
            self?.chooseNewEventDate(workflow: .addDatesToFriend)
        }
        
        vc.addContacts = { [weak self] in
            self?.chooseWhoController(viewModel: vm)
        }
        
        vc.goToSearch = { [weak self] in
            self?.globalSearch()
        }
    
        navigationController.pushViewController(vc, animated: true)
    }
    
    func closetItem(item: ClothingItem) {
        let vc = ViewEditClothingItemViewController()
        vc.coordinator = self
        clothingItem = item
        
        guard let id = item.id else { return }
        
        let vm = ViewEditClothingItemViewModel(id: id,
                                       clothingItemService: ClothingItemService(),
                                       clothingTypesService: ClothingTypesService(),
                                       tagService: TagService())
        vc.viewModel = vm
        
        vc.goBack = { [weak self] in
            self?.clearState()
            self?.popController()
        }
        
        vc.addClosetItems = { [weak self] items in
            guard let closetItems = items as? [Look] else { return }
            self?.selectedLooks = closetItems
            self?.whatDidIWear(workflow: .addLooksToItem)
        }
        
        vc.addEvents = { [weak self] items in
            guard let events = items as? [Event] else { return }
            self?.selectedEvents = events
            self?.events(workflow: .addEventsToItem)
        }
        
        vc.addDates = { [weak self] in
            self?.chooseNewEventDate(workflow: .addDatesToItem)
        }
        
        vc.addContacts = { [weak self] in
            self?.chooseWhoController(viewModel: vm)
        }
        
        vc.goToSearch = { [weak self] in
            self?.globalSearch()
        }
  
        navigationController.setNavigationBarHidden(true, animated: true)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func deleteClosetItems(workflow: Workflow) {
        let vc = DeleteClosetItemsViewController()
        vc.viewModel = ClosetViewModel(clothingItemService: ClothingItemService(),
                                       workflow: workflow,
                                       lookService: LookService())
        
        vc.goBack = { [weak self] in
            self?.popController()
        }
        
        vc.goToRemoveModal = { [weak self] (ids, workflow) in
            self?.idsToRemove = ids
            self?.globalModal(workflow: workflow)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - New item flow
// TODO: - refactor to child coordinator
extension MainCoordinator {
    func newItem(_ image:UIImage? = nil, workflow: Workflow) {
        
        let vc = NewItemViewController()
        let vm = NewItemViewModel(clothingTypesService: ClothingTypesService(),
                                  clothingItemService: ClothingItemService(),
                                  tagService: TagService(),
                                  workflow: workflow)
        if let image = image {
            vm.itemPhoto.accept(image)
        }
        
        vc.goBack = { [weak self] in
            self?.clearState()
            self?.popController()
        }
        
        vc.finished = { [weak self] in
            self?.popController()
        }
        
        vc.addClosetItems = { [weak self] items in
            guard let closetItems = items as? [Look] else { return }
            self?.selectedItemsForNewClosetItem = closetItems
            self?.whatDidIWear(workflow: .addLooksToNewItem)
        }
        
        vc.addEvents = { [weak self] items in
            guard let events = items as? [Event] else { return }
            self?.selectedEvents = events
            self?.events(workflow: .addEventsToItem)
        }
        
        vc.addDates = { [weak self] in
            self?.chooseNewEventDate(workflow: .addDatesToItem)
        }
        
        vc.addContacts = { [weak self] in
            self?.chooseWhoController(viewModel: vm)
        }
        
        vc.goToSearch = { [weak self] in
            self?.globalSearch()
        }
        
        vc.viewModel = vm
        vc.coordinator = self
        vc.modalPresentationStyle = .fullScreen

        navigationController.pushViewController(vc, animated: true)
    }

    func globalModal(workflow: Workflow) {
        guard let presentingVC = presentingController else { return }
        
        let vc = GlobalModalViewController()
        let vm = GlobalModalViewModel(workflow: workflow,
                                      event: selectedEvent ?? Event(),
                                      clothingItem: clothingItem ?? ClothingItem(),
                                      eventClothingItemService: EventClothingItemService(),
                                      eventService: EventService(),
                                      tagService: TagService(),
                                      clothingItemService: ClothingItemService(),
                                      lookService: LookService(),
                                      idsToRemove: idsToRemove)
        vc.viewModel = vm
        vc.modalPresentationStyle = .fullScreen
        
        vc.leftButtonAction = { [weak self] in
            presentingVC.dismiss(animated: true, completion: {
                if workflow == .addEventOrDateToClosetItem {
                    self?.events(workflow: workflow)
                } else if workflow == .saveItemToEvent {
                    self?.popController()
                }
            })
        }
        
        vc.rightButtonAction = { [weak self] in
             // needs to be reworked.  Navigation is not smooth.
             presentingVC.dismiss(animated: true, completion: {
                if workflow == .saveItemToEvent {
                    self?.clearState()
                } else if workflow == .noEventScheduledOnDay {
                    let selectedDate = self?.selectedDate ?? Date()
                } else if workflow == .removeEventFromCalendar {
                    self?.clearState()
                } else if workflow == .removeContacts {
                    self?.clearState()
                } else if workflow == .removeItems {
                    self?.clearState()
                } else if workflow == .removeLooks {
                    self?.clearState()
                    self?.popController()
                }
             })
        }

        vc.closeButtonAction = { [weak self] in
            presentingVC.dismiss(animated: true, completion: {
                self?.clearState()
            })
        }

        presentingVC.present(vc, animated: true)
    }
}

// MARK: - Add Event flow
// TODO: - refactor to child coordinator
extension MainCoordinator {
    private func events(workflow: Workflow = .eventsIndex) {
        let vc = EventsViewController()
        vc.viewModel = EventsViewModel(eventService: EventService(),
                                       selectedEvents: selectedEvents,
                                       workflow: workflow)
        vc.coordinator = self
        
        vc.selectedEventToAdd = { [weak self] event in
            self?.selectedEvent = event
            self?.popController()
        }
        
        vc.selectedEventsToAdd = { [weak self] events in
            self?.selectedEvents = events
            self?.popController()
        }
        
        vc.addEventToClosetItem = { [weak self] event in
            self?.selectedEvent = event
            self?.globalModal(workflow: .saveItemToEvent)
        }

        vc.goToSearch = { [weak self] in
            self?.globalSearch()
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    func addlocationToEvent(vm: EditEventOrAddEventViewModel) {
        let vc = LocationFormViewController()
        vc.viewModel = vm
        
        vc.finished = {
            self.popController()
        }
        
        navigationController.pushViewController(vc, animated: true)
    }

    func timePickerController(viewModel: EditEventOrAddEventViewModel) {
        let vc = TimePickerViewController()
        vc.modalPresentationStyle = .fullScreen
        
        vc.finished = { [weak self] (date) in
            viewModel.time.accept("\(date.toString("h:mm a"))")
            self?.presentingController?.dismiss(animated: true, completion: nil)
        }

        self.presentingController?.present(vc, animated: true, completion: nil)
    }

    func chooseWhoController(viewModel: ChooseWhoViewModel) {
        let vc = ChooseWhoViewController()
        vc.viewModel  = viewModel

        vc.finished = { [weak self] in
            self?.popController()
        }
        
        vc.goToSearch = { [weak self] in
            self?.globalSearch()
        }

        navigationController.pushViewController(vc, animated: true)
    }
    
    func whatDidIWear(workflow: Workflow = .defaultWorkflow) {
        let vc = WhatDidIWearViewController()
        let looks = whatDidIWearSelectedLooks(for: workflow)
        let clothingItems = whatDidIWearSelectedClothingItems(for: workflow)
        let vm = ClosetViewModel(clothingItemService: ClothingItemService(),
                                 selectedItems: clothingItems,
                                 selectedLooks: looks,
                                 workflow: workflow,
                                 lookService: LookService())

        vc.viewModel = vm
        // used to access state
        vc.coordinator = self
        
        vc.finished = { [weak self] in
            self?.popController()
        }
        
        vc.unauthorized = { [weak self] in
            self?.login()
        }
        
        vc.goToNewItem = { [weak self] workflow in
            self?.newItem(workflow: workflow)
        }
        
        vc.goToNewLook = { [weak self] workflow in
            self?.addLook(workflow: workflow)
        }
        
        vc.goToSearch = { [weak self] in
            self?.globalSearch()
        }
        
        vc.addItems = { [weak self] (items, viewMode) in
            if viewMode == .items,
                let convertedItems = items as? [ClothingItem] {
                if workflow == .addItemsToNewLook {
                    self?.selectedItemsForNewClosetItem = convertedItems
                } else {
                    self?.selectedClothingItems = convertedItems
                }
            } else if viewMode == .looks,
                let convertedLooks = items as? [Look] {
                if workflow == .addLooksToNewItem {
                    self?.selectedItemsForNewClosetItem = convertedLooks
                } else {
                    self?.selectedLooks = convertedLooks
                }
            }
            self?.popController()
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func whatDidIWearSelectedClothingItems(for workflow: Workflow) -> [ClothingItem] {
        if let items = selectedItemsForNewClosetItem as? [ClothingItem],
            workflow == .addItemsToNewLook {
            return items
        } else {
            return selectedClothingItems
        }
    }
    
    private func whatDidIWearSelectedLooks(for workflow: Workflow) -> [Look] {
        if let looks = selectedItemsForNewClosetItem as? [Look],
            workflow == .addLooksToNewItem {
            return looks
        } else {
            return selectedLooks
        }
    }
}

// MARK: - TabBar Navigation
extension MainCoordinator {
    
    private func removeExistingTabBarFromStack() {
        if let vcIndex = self.indexOfViewController(vc: self.tabBarController) {
            self.removeViewController(at: vcIndex)
        }
    }
    
    private func contacts() -> ContactsViewController {
        let vc = ContactsViewController()
        vc.viewModel = ContactsViewModel(tagService: TagService())
        
        vc.goToHomePage = { [weak self] in
//            self?.popController()
          self?.homePage()
        }
        
        vc.goToRemoveContacts = { [weak self] in
            self?.removeContacts()
        }
        
        vc.goToContact = { [weak self] id in
            self?.viewContact(with: id)
        }
        
        vc.goToNewContact = { [weak self] in
            self?.addContacts()
        }
        
        vc.goToSearch = { [weak self] in
            self?.globalSearch()
        }
        
        return vc
    }
    
    private func tabBarEvents(workflow: Workflow = .eventsIndex) -> EventsViewController {
        let vc = EventsViewController()
        vc.viewModel = EventsViewModel(eventService: EventService(),
                                       selectedEvents: selectedEvents,
                                       workflow: workflow)
        vc.coordinator = self
        
        vc.selectedEventToAdd = { [weak self] event in
            self?.selectedEvent = event
            self?.popController()
        }
        
        vc.addEventToClosetItem = { [weak self] event in
            self?.selectedEvent = event
            self?.globalModal(workflow: .saveItemToEvent)
        }

        vc.goToSearch = { [weak self] in
            self?.globalSearch()
        }
        
        vc.goToHomePage = { [weak self] in
          self?.homePage()
        }
        
        return vc
    }
}

// MARK: - Contacts
extension MainCoordinator {
    func removeContacts() {
        let vc = RemoveContactsViewController()
        
        vc.viewModel = ContactsViewModel(tagService: TagService())
        
        vc.goBack = { [weak self] in
            self?.popController()
        }
        
        vc.goToRemoveContacts = { [weak self] ids in
            self?.idsToRemove = ids
            self?.globalModal(workflow: .removeContacts)
        }
        
        vc.goToGlobalSearch = { [weak self] in
            self?.globalSearch()
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    func addContacts() {
        let vc = AddContactViewController()
        vc.viewModel = AddContactsViewModel(tagService: TagService())
        
        vc.goBack = { [weak self] in
            self?.popController()
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    func viewContact(with id: Int) {
        let vc = ViewUpdateContactViewController()
        vc.viewModel = ViewEditContactViewModel(id: id, tagService: TagService())
        vc.coordinator = self
        
        vc.goBack = { [weak self] in
            self?.clearState()
            self?.popController()
        }
        
        vc.addClosetItems = { [weak self] (items, looks) in
            self?.selectedLooks = looks
            self?.selectedClothingItems = items
            self?.whatDidIWear(workflow: .editFriend)
        }
        
        vc.addEvents = { [weak self] items in
            guard let events = items as? [Event] else { return }
            self?.selectedEvents = events
            self?.events(workflow: .addEvents)
        }
        
        vc.addDates = { [weak self] in
            self?.chooseNewEventDate(workflow: .addDatesToFriend)
        }
        
        vc.goToSearch = { [weak self] in
            self?.globalSearch()
        }
 
        navigationController.pushViewController(vc, animated: true)
    }
}
