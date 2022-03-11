import Foundation
import RxCocoa
import RxSwift

struct ClosetViewModel {
    enum Chronological {
        case earliest, latest
    }
    let closetItems             = BehaviorRelay<[ClosetItem]>(value: [])
    let selectedClosetItems     = BehaviorRelay<[ClosetItem]>(value: [])
    let looks                   = BehaviorRelay<[Look]>(value: [])
    let selectedlooks           = BehaviorRelay<[Look]>(value: [])
    let clothingItems           = BehaviorRelay<[ClothingItem]>(value: [])
    let selectedItems           = BehaviorRelay<[ClothingItem]>(value: [])
    let addItemsButtonText      = BehaviorRelay<String>(value: TextContent.Buttons.addItemsToEvent)
    let navTitle                = BehaviorRelay<String>(value: TextContent.Labels.whatDidIWearAllCaps)
    let success                 = BehaviorRelay<Bool>(value: false)
    let isLoading               = BehaviorRelay<Bool>(value: false)
    let errorMsg                = BehaviorRelay<String>(value: "")
    let errorStatus             = BehaviorRelay<Int>(value: 0)
    let viewMode                = BehaviorRelay<ClosetViewMode>(value: .items)
    let removeButtonText        = BehaviorRelay<String>(value: TextContent.Labels.removeItemFromCloset)
    let hideTwoButtonSwitch     = BehaviorRelay<Bool>(value: false)
    
    private var closetItemsToBeDeleted: [Int] = []
    let disposebag = DisposeBag()
    let workflow: Workflow
    
    private let clothingItemService: ClothingItemInfoService
    private let lookService: LookInfoService
    
    init(clothingItemService: ClothingItemInfoService,
         selectedItems: [ClothingItem]? = nil,
         selectedLooks: [Look]? = nil,
         workflow: Workflow = .defaultWorkflow,
         lookService: LookInfoService) {
        self.clothingItemService = clothingItemService
        self.workflow = workflow
        self.lookService = lookService
        if let items = selectedItems {
            self.selectedItems.accept(items)
        }
        
        if let looks = selectedLooks {
            self.selectedlooks.accept(looks)
        }
    
        setupBasedOnWorkflow()
        getCloset()
    }
    
    mutating func resetState() {
        emptyClosetItemsToBeDeleted()
    }
    
    private func setupBasedOnWorkflow() {
        navTitle.accept(workflow.closetViewNavTitle)
        addItemsButtonText.accept(workflow.closetViewAddItemsBtnText)
        removeButtonText.accept(workflow.closetItemsRemoveBtnText)
        
        if (workflow == .editLook || workflow == .addItemsToNewLook) {
            hideTwoButtonSwitch.accept(true)
        } else if workflow == .removeItems {
            viewMode.accept(.items)
        } else if workflow == .removeLooks {
            viewMode.accept(.looks)
        } else if (workflow == .addLooksToItem || workflow == .addLooksToNewItem) {
            hideTwoButtonSwitch.accept(true)
            viewMode.accept(.looks)
        } else if workflow == .addClosetItemToEvent {
            viewMode.accept(.items)
        }
    }
    
    func setTitleAndButtonForItems() {
        switch workflow {
        case .editFriend:
            navTitle.accept(TextContent.Labels.addItemsWithFriend)
            addItemsButtonText.accept(TextContent.Buttons.saveItemsWithFriend)
        case .addClosetItemToEvent:
            navTitle.accept(TextContent.Labels.addItemsToEvent)
            addItemsButtonText.accept(TextContent.Buttons.saveItemsToEvent)
        case .addItemsToNewLook:
            navTitle.accept(TextContent.Labels.addItemsToLook)
            addItemsButtonText.accept(TextContent.Buttons.saveItemsToLook)
        default:
            print("Workflow not supported yet")
        }
    }
    
    func setTitleAndButtonForLooks() {
        switch workflow {
        case .editFriend:
            navTitle.accept(TextContent.Labels.addLooksWithFriend)
            addItemsButtonText.accept(TextContent.Buttons.saveLooksWithFriend)
        case .editLook:
            navTitle.accept(TextContent.Labels.addItemsToLook)
            addItemsButtonText.accept(TextContent.Buttons.saveItemsToLook)
        case .addLooksToNewItem:
            navTitle.accept(TextContent.Labels.addLooksToItem)
            addItemsButtonText.accept(TextContent.Buttons.saveLooksToItem)
        case .addClosetItemToEvent:
            navTitle.accept(TextContent.Labels.addLooksToEvent)
            addItemsButtonText.accept(TextContent.Buttons.saveLooksToEvent)
        default:
            print("Workflow not supported yet")
        }
    }
    
    func sortByDate(direction: Chronological) {
        var data = closetItems.value
        guard data.count > 0 else { return }
        
        data.sort { (a, b) -> Bool in
            guard let aDate = a.createdAt else {
                return true
            }
            guard let bDate = b.createdAt else {
                return false
            }
            
            if direction == .earliest {
               return aDate < bDate
            } else {
               return aDate > bDate
            }
        }
        
        closetItems.accept(data)
    }
    
    func sortByType() {
        var data = clothingItems.value
        guard data.count > 0 else { return }
        
        data.sort { (a, b) -> Bool in
            return a.typeOf! < b.typeOf!
        }
        clothingItems.accept(data)
        setClosetItems()
    }
}

// MARK: - Convienance methods
extension ClosetViewModel {
   mutating func addClosetItemToBeDeleted(id: Int) {
        closetItemsToBeDeleted.append(id)
    }
    
    mutating func removeClosetItemToBeDeleted(id: Int) {
        if let index = closetItemsToBeDeleted.firstIndex(of: id) {
            closetItemsToBeDeleted.remove(at: index)
        }
    }
    
    private mutating func emptyClosetItemsToBeDeleted() {
        closetItemsToBeDeleted = []
    }
    
    func getClosetItemIds() -> [Int] {
        return closetItemsToBeDeleted
    }
    
    func switchViewMode(for mode: ClosetViewMode) {
        viewMode.accept(mode)
        setClosetItems()
    }
    
    private func setClosetItems() {
        if viewMode.value == .items {
            selectedClosetItems.accept(selectedItems.value)
            closetItems.accept(clothingItems.value)
        } else {
            selectedClosetItems.accept(selectedlooks.value)
            closetItems.accept(looks.value)
        }
    }
    
    func getClosetItemsCount() -> Int {
        return closetItems.value.count
    }
    
    func getSelectedClosetItemsCount() -> Int {
        return selectedClosetItems.value.count
    }
    
    func getSelectedClosetItems() ->[ClosetItem] {
        return selectedClosetItems.value
    }
    
    func getClosetItem(at index: Int) -> ClosetItem {
        return closetItems.value[index]
    }
    
    func getViewMode() -> ClosetViewMode {
        return viewMode.value
    }
    
    func getWorkflow() -> Workflow {
        return workflow
    }
    
    func isSelectedItem(with id: Int) -> Bool {
        return selectedClosetItems.value.contains(where: { $0.id == id })
    }
    
    func addToClosetItems(item: ClosetItem) {
        if let clothingItem = item as? ClothingItem {
            var items = clothingItems.value
            var selected = selectedItems.value
            items.append(clothingItem)
            selected.append(clothingItem)
            clothingItems.accept(items)
            selectedItems.accept(selected)
        } else if let look = item as? Look {
            var items = looks.value
            var selected = selectedlooks.value
            items.append(look)
            selected.append(look)
            looks.accept(items)
            selectedlooks.accept(selected)
        }
        
        setClosetItems()
    }
    
    func addToSelectedItem(item: ClosetItem) {
        var items = selectedClosetItems.value
        items.append(item)
        selectedClosetItems.accept(items)
    }
    
    func removeSelectedItem(item: ClosetItem) {
        var items = selectedClosetItems.value
        if let index = items.firstIndex(where: {$0.id == item.id }) {
            items.remove(at: index)
            selectedClosetItems.accept(items)
        }
    }
}

// MARK: - GET Looks and Items
extension ClosetViewModel {
   func getCloset() {
    // if already loading closet no need to continue
    guard !isLoading.value else { return }
        isLoading.accept(true)
        getItems()
        getLooks()
    }
    
    private func getItems() {
        clothingItemService.index()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                self.isLoading.accept(false)
                self.clothingItems.accept(response)
                self.setClosetItems()
            }, onError: { error in
                self.isLoading.accept(false)
                guard let errorObject = error as? ErrorResponseObject else { return }
                self.errorStatus.accept(errorObject.status)
            }).disposed(by: disposebag)
    }
    
    private func getLooks() {
        lookService.index()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                self.looks.accept(response)
                self.setClosetItems()
            }, onError: { error in
                guard let errorObject = error as? ErrorResponseObject else { return }
                self.errorStatus.accept(errorObject.status)
            }).disposed(by: disposebag)
    }
}
