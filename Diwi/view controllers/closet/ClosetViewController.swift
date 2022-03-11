import UIKit
import RxSwift
import RxCocoa

final class ClosetViewController: UIViewController {
    
    // MARK: - view props
    let header          = UIView()
    let searchIcon      = UIButton()
    let navTitle        = UILabel()
    let filterToggle    = UIButton()
    let buttonBorder    = UIView()
    let arrowIcon       = UIImageView()
    let byType          = UIButton()
    let byLatestDate    = UIButton()
    let byEarliestDate  = UIButton()
    var closetCollection: UICollectionView?
    let plusButton      = UIButton()
    let emptyMessage    = AppButton()
    var spinnerView     = UIView()
    let twoButtonSwitch = TwoButtonSwitch(leftText: TextContent.Buttons.looks,
                                          rightText: TextContent.Buttons.items)
    
    // MARK: - internal props
    let disposeBag = DisposeBag()
    var viewModel: ClosetViewModel!
    let filtersOpen = BehaviorRelay<Bool>(value: false)
    let screenWidth = UIScreen.main.bounds.width
    var goToRemoveItems: (() -> Void)?
    var goToRemoveLooks: (() -> Void)?
    var goToLogin: (() -> Void)?
    var goBack: (() -> Void)?
    var goToClosetItem: ((ClothingItem) -> Void)?
    var goToLook: ((_ id: Int) -> Void)?
    var goToNewItem: ((Workflow) -> Void)?
    var goToHomePage: (() -> Void)?
    var goToSeach: (() -> Void)?
    var viewMode: ClosetViewMode {
        return viewModel.getViewMode()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        createViewModelBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        viewModel.getCloset()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func getLooks() -> Bool {
        return false
    }
    
    private func closeFilters() {
        UIView.animate(withDuration: 0.25) {
            self.arrowIcon.transform = CGAffineTransform(rotationAngle: 0)
            self.byLatestDate.frame.origin.y -= 45
            self.byEarliestDate.frame.origin.y -= 90
            // by type is only visable for items
            if self.viewMode == .items {
                print("closing by type")
               self.byType.frame.origin.y -= 135
            }
            self.closetCollection?.frame.origin.y -= 135
        }
    }
    
    private func openFilters() {
        UIView.animate(withDuration: 0.25) {
            self.arrowIcon.transform = CGAffineTransform(rotationAngle: (-90.0 * .pi) / 180.0)
            self.byLatestDate.frame.origin.y += 45
            self.byEarliestDate.frame.origin.y += 90
            // by type is only visable for items
            if self.viewMode == .items {
              self.byType.frame.origin.y += 135
            }
            self.closetCollection?.frame.origin.y += 135
        }
    }
    
    // Cast ClosetItem back to its model and go to single view
    private func goToIndexItem(item: ClosetItem) {
        switch viewMode {
        case .items:
            if let clothingItem = item as? ClothingItem {
                goToClosetItem?(clothingItem)
            }
        case .looks:
            if let look = item as? Look,
                let id = look.id {
                goToLook?(id)
            }
        }
    }
}

// MARK: - View model bindings
extension ClosetViewController {
    private func createViewModelBinding() {
        
        searchIcon.rx.tap.bind {
            self.goToSeach?()
        }.disposed(by: disposeBag)
        
        filterToggle.rx.tap.bind {
            self.filtersOpen.accept(!self.filtersOpen.value)
        }.disposed(by: disposeBag)
        
        byType.rx.tap.bind {
            self.viewModel.sortByType()
        }.disposed(by: disposeBag)
        
        byLatestDate.rx.tap.bind {
            self.viewModel.sortByDate(direction: .latest)
        }.disposed(by: disposeBag)
        
        byEarliestDate.rx.tap.bind {
            self.viewModel.sortByDate(direction: .earliest)
        }.disposed(by: disposeBag)
        
        plusButton.rx.tap.bind { [unowned self] in
            let workflow: Workflow = self.viewMode == .items ? .addClosetItem : .addClosetLook
            self.goToNewItem?(workflow)
        }.disposed(by: disposeBag)
               
        emptyMessage.rx.tap.bind {
             let workflow: Workflow = self.viewMode == .items ? .addClosetItem : .addClosetLook
             self.goToNewItem?(workflow)
        }.disposed(by: disposeBag)
        
        filtersOpen
            .subscribe(onNext: { [unowned self] (value: Bool) in
            if self.closetCollection?.frame.origin.y == 185.0 {
                self.openFilters()
            } else if self.closetCollection?.frame.origin.y == 320.0 {
                self.closeFilters()
            }
        }).disposed(by: disposeBag)
        
        viewModel.closetItems
            .skip(1)
            .subscribe(onNext: { [unowned self] value in
                if value.count > 0 {
                    self.removeEmptyState()
                } else if value.count == 0 {
                    self.setupEmptyState()
                }
                
                self.closetCollection?.reloadData()
            }).disposed(by: disposeBag)
        
        viewModel.isLoading
            .subscribe(onNext: { [unowned self] (value: Bool) in
                if value {
                    self.displaySpinner(onView: self.view, spinnerView: self.spinnerView)
                } else {
                    self.removeSpinner(spinner: self.spinnerView)
                }
        }).disposed(by: disposeBag)
        
        viewModel.viewMode
            .subscribe(onNext: { [unowned self] value in
                if value == .items {
                    self.emptyMessage.setTitle(TextContent.Buttons.addItems, for: .normal)
                    self.showSortByType()
                } else {
                    self.emptyMessage.setTitle(TextContent.Buttons.addLooks, for: .normal)
                    self.hideSortByType()
                }
            }).disposed(by: disposeBag)
        
        viewModel.errorStatus
            .subscribe(onNext: { [unowned self] (value: Int) in
                if value == 401 {
                    self.goToLogin?()
                }
            }).disposed(by: disposeBag)
    }
}

// MARK: - Setup view
extension ClosetViewController {
    private func setupView() {
        spinnerView = UIView.init(frame: view.bounds)
        
        setupHeader()
        setupMenu()
        setupCollection()
        setupPlusButton()
    }
    
    private func setupHeader() {
        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = UIColor.Diwi.barney
        view.backgroundColor = UIColor.white
        view.addSubview(header)
        
        var headerHeight: CGFloat = 185
        
        if hasNotch() {
            headerHeight += 30
        }
        
        NSLayoutConstraint.activate([
            header.leftAnchor.constraint(equalTo: view.leftAnchor),
            header.rightAnchor.constraint(equalTo: view.rightAnchor),
            header.topAnchor.constraint(equalTo: view.topAnchor),
            header.heightAnchor.constraint(equalToConstant: headerHeight)
            ])
    }
        
    private func setupMenu() {
        byLatestDate.translatesAutoresizingMaskIntoConstraints = false
        byLatestDate.backgroundColor = UIColor.Diwi.barney
        byLatestDate.titleLabel?.font = UIFont.Diwi.floatingButton
        byLatestDate.contentHorizontalAlignment = .left
        byLatestDate.setTitle(TextContent.Buttons.byLatestDate, for: .normal)
        byLatestDate.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 43.0, bottom: 0.0, right: 0)
        view.addSubview(byLatestDate)
        view.sendSubviewToBack(byLatestDate)
        
        NSLayoutConstraint.activate([
            byLatestDate.topAnchor.constraint(equalTo: header.bottomAnchor, constant: -45),
            byLatestDate.leftAnchor.constraint(equalTo: view.leftAnchor),
            byLatestDate.rightAnchor.constraint(equalTo: view.rightAnchor),
            byLatestDate.heightAnchor.constraint(equalToConstant: 45)
            ])
        
        byEarliestDate.translatesAutoresizingMaskIntoConstraints = false
        byEarliestDate.backgroundColor = UIColor.Diwi.barney
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
        
        byType.translatesAutoresizingMaskIntoConstraints = false
        byType.backgroundColor = UIColor.Diwi.barney
        byType.titleLabel?.font = UIFont.Diwi.floatingButton
        byType.contentHorizontalAlignment = .left
        byType.setTitle(TextContent.Buttons.byType, for: .normal)
        byType.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 43.0, bottom: 0.0, right: 0)
        
    }
    
    private func showSortByType() {
        view.addSubview(byType)
        view.sendSubviewToBack(byType)
        
        NSLayoutConstraint.activate([
            byType.topAnchor.constraint(equalTo: byEarliestDate.bottomAnchor, constant: -45),
            byType.leftAnchor.constraint(equalTo: view.leftAnchor),
            byType.rightAnchor.constraint(equalTo: view.rightAnchor),
            byType.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
    
    private func hideSortByType() {
        byType.removeFromSuperview()
    }
    
    private func setupCollection() {
        closetCollection = CollectionsConfig.closetIndex.collectionView()
        view.addSubview(closetCollection!)
        
        closetCollection!.dataSource = self
        closetCollection!.delegate = self
        
        NSLayoutConstraint.activate([
            closetCollection!.topAnchor.constraint(equalTo: header.bottomAnchor),
            closetCollection!.rightAnchor.constraint(equalTo: view.rightAnchor),
            closetCollection!.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            closetCollection!.leftAnchor.constraint(equalTo: view.leftAnchor)
            ])
    }
    
    private func setupPlusButton() {
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.setImage(UIImage.Diwi.addIconWhite, for: .normal)
        
        view.addSubview(plusButton)
        
        NSLayoutConstraint.activate([
            plusButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            plusButton.widthAnchor.constraint(equalToConstant: 58),
            plusButton.heightAnchor.constraint(equalToConstant: 58),
            plusButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
    }
    
    private func setupEmptyState() {
        emptyMessage.translatesAutoresizingMaskIntoConstraints = false
        emptyMessage.inverseColor()
        emptyMessage.setTitleColor(UIColor.Diwi.barney, for: .normal)
        emptyMessage.titleLabel?.font = UIFont.Diwi.button
        
        view.addSubview(emptyMessage)
        
        NSLayoutConstraint.activate([
            emptyMessage.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            emptyMessage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyMessage.heightAnchor.constraint(equalToConstant: 50),
            emptyMessage.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            emptyMessage.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30)
        ])
        
        plusButton.isHidden = true
    }
    
    private func removeEmptyState() {
        emptyMessage.removeFromSuperview()
        plusButton.isHidden = false
    }
    
}

// MARK: - Collection view data source delegate methods
extension ClosetViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return viewModel.getClosetItemsCount()
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell: ClosetCell = closetCollection!.dequeueReusableCell(for: indexPath)
//        let closetItem = viewModel.getClosetItem(at: indexPath.row)
//        cell.indexItem = closetItem
//        cell.setup(mode: viewMode)
//        return cell
        
        let cell: ClosetCell = closetCollection!.dequeueReusableCell(for: indexPath)
        cell.setup(mode: viewMode)
        return cell
    }
}

// MARK: - Collection view delegate methods
extension ClosetViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = viewModel.getClosetItem(at: indexPath.row)
        self.goToIndexItem(item: item)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout  collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize{
        guard viewModel.getClosetItemsCount() > 0 else { return CGSize(width: 0, height: 0)}
        
        return CollectionsConfig.closetIndex.referenceSizeForFooterInSection
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if (kind == UICollectionView.elementKindSectionFooter) {
            guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                   withReuseIdentifier: CollectionViewFooter.reuseIdentifier,
                                                                                   for: indexPath) as? CollectionViewFooter else { fatalError("Invalid view type") }
            
            let text = viewMode == .items ? TextContent.Labels.removeItemFromCloset : TextContent.Labels.removeLookFromCloset
            footerView.setup(text: text, style: .normal)
            
            footerView.buttonPressed = { [weak self] in
                if self?.viewMode == .items {
                    self?.goToRemoveItems?()
                } else {
                    self?.goToRemoveLooks?()
                }
            }
            
            return footerView
        }
        
        fatalError()
    }
}

// MARK: - Collection view flow layout delegate methods
extension ClosetViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        if viewMode == .items {
          return CollectionsConfig.closetIndex.cgSizeForItem
        } else {
          return CGSize(width: 98, height: 150)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return CollectionsConfig.closetIndex.insetForSectionAt
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CollectionsConfig.closetIndex.minimumLineSpacingForSectionAt
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CollectionsConfig.closetIndex.minimumLineSpacingForSectionAt
    }
}
