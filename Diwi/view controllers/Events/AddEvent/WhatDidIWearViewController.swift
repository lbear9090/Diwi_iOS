//
//  WhatDidIWear.swift
//  Diwi
//
//  Created by Dominique Miller on 11/19/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class WhatDidIWearViewController: UIViewController {
    
    // MARK: - view props
    let header                = UIView()
    let backIcon              = UIButton()
    let searchIcon            = UIButton()
    let navTitle              = UILabel()
    let filterToggle          = UIButton()
    let buttonBorder          = UIView()
    let arrowIcon             = UIImageView()
    let byEvent               = UIButton()
    let byType                = UIButton()
    var closetCollection: UICollectionView?
    let plusButton            = UIButton()
    let addItemsToEventButton = UIButton()
    var spinnerView           = UIView()
    let emptyMessage          = AppButton()
    let twoButtonSwitch = TwoButtonSwitch(leftText: TextContent.Buttons.looks,
                                          rightText: TextContent.Buttons.items)
    
    // MARK: - internal props
    let disposeBag = DisposeBag()
    var viewModel: ClosetViewModel!
    let filtersOpen = BehaviorRelay<Bool>(value: false)
    var unauthorized: (() -> Void)?
    var finished: (() -> Void)?
    var goToNewItem: ((Workflow) -> Void)?
    var goToNewLook: ((Workflow) -> Void)?
    var addItems: ((_ items: [ClosetItem], _ itemType: ClosetViewMode) -> Void)?
    var goToSearch: (() -> Void)?
    var coordinator: MainCoordinator?
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
        
        // used when returning from creating
        // a new clothing item or look sub flow
        updateCollectionViewIfNewClosetItem()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func closeFilters() {
        UIView.animate(withDuration: 0.25) {
            self.arrowIcon.transform = CGAffineTransform(rotationAngle: 0)
            self.byEvent.frame.origin.y -= 45
            self.byType.frame.origin.y -= 90
            self.closetCollection?.frame.origin.y -= 90
        }
    }
    
    private func openFilters() {
        UIView.animate(withDuration: 0.25) {
            self.arrowIcon.transform = CGAffineTransform(rotationAngle: (-90.0 * .pi) / 180.0)
            self.byEvent.frame.origin.y += 45
            self.byType.frame.origin.y += 90
            self.closetCollection?.frame.origin.y += 90

        }
    }
    
    private func goToLogin() {
        unauthorized?()
    }
    
    private func resetCollectionView() {
        self.closetCollection?.reloadData()
    }
    
    private func updateCollectionViewIfNewClosetItem() {
        if let item = coordinator?.clothingItem {
            viewModel.addToClosetItems(item: item)
        }
        
        if let look = coordinator?.look {
            viewModel.addToClosetItems(item: look)
        }
    }
}

// MARK: - View model bindings
extension WhatDidIWearViewController {
    private func createViewModelBinding() {
        
        backIcon.rx.tap.bind {
            self.finished?()
            }
            .disposed(by: disposeBag)
        
        searchIcon.rx.tap.bind {
            self.goToSearch?()
        }.disposed(by: disposeBag)
        
        filterToggle.rx.tap.bind {
            self.filtersOpen.accept(!self.filtersOpen.value)
        }
        .disposed(by: disposeBag)
        
        emptyMessage.rx.tap.bind {
            if self.viewMode == .items {
                self.goToNewItem?(.addClosetItem)
            } else {
                self.goToNewLook?(.addClosetLook)
            }
        }.disposed(by: disposeBag)
        
        byType.rx.tap.bind {
            self.viewModel.sortByType()
        }
        .disposed(by: disposeBag)
        
        byEvent.rx.tap.bind {
            self.viewModel.sortByDate(direction: .latest)
        }
        .disposed(by: disposeBag)
        
        filtersOpen.subscribe(onNext: { [unowned self] (value: Bool) in
            if value {
                self.openFilters()
            }
            else {
                self.closeFilters()
            }
        }).disposed(by: disposeBag)
        
        viewModel
            .isLoading
            .subscribe(onNext: { [unowned self] value in
            if value {
                self.displaySpinner(onView: self.view, spinnerView: self.spinnerView)
            }
            else {
                self.removeSpinner(spinner: self.spinnerView)
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
        
        viewModel.errorStatus
            .subscribe(onNext: { [unowned self] (value: Int) in
                if value == 401 {
                    self.goToLogin()
                }
            }).disposed(by: disposeBag)
        
        plusButton.rx.tap.bind {
            if self.viewMode == .items {
               self.goToNewItem?(self.viewModel.getWorkflow())
            } else if self.viewMode == .looks {
                self.goToNewLook?(self.viewModel.getWorkflow())
            }
        }.disposed(by: disposeBag)
        
        addItemsToEventButton.rx.tap.bind {
            self.addItemsToEventButton.buttonPressedAnimation {
                if self.viewModel.getSelectedClosetItemsCount() > 0 {
                    self.addItems?(self.viewModel.getSelectedClosetItems(), self.viewMode)
                } else {
                    self.presentMessage(title: TextContent.Errors.oops,
                                        message: TextContent.Errors.needToAddMoreItems)
                }
            }            
        }.disposed(by: disposeBag)
        
        viewModel.viewMode
        .subscribe(onNext: { [unowned self] value in
            if value == .items {
                self.emptyMessage.setTitle(TextContent.Buttons.addItems, for: .normal)
                self.viewModel.setTitleAndButtonForItems()
            } else {
                self.emptyMessage.setTitle(TextContent.Buttons.addLooks, for: .normal)
                self.viewModel.setTitleAndButtonForLooks()
            }
        }).disposed(by: disposeBag)
        
        viewModel.navTitle
            .subscribe(onNext: { [unowned self] value in
                self.navTitle.text = value
        }).disposed(by: disposeBag)
        
        viewModel.addItemsButtonText
            .subscribe(onNext: { [unowned self] value in
                self.addItemsToEventButton.setTitle(value, for: .normal)
        }).disposed(by: disposeBag)
        
        viewModel.hideTwoButtonSwitch
            .subscribe(onNext: {[unowned self] value in
                self.twoButtonSwitch.isHidden = value
        }).disposed(by: disposeBag)
    }
}

// MARK: - Setup view
extension WhatDidIWearViewController {
    private func setupView() {
        setupHeader()
        setupNav()
        setupTwoButtonSwitch()
        setupFilterToggle()
        setupMenu()
        setupAddItemsToEventButton()
        setupCollection()
        setupPlusButton()
        setupSpinner()
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
        navTitle.font = UIFont.Diwi.titleBold
        header.addSubview(navTitle)

        NSLayoutConstraint.activate([
            navTitle.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            navTitle.centerYAnchor.constraint(equalTo: searchIcon.centerYAnchor)
        ])
        
    }
    
    private func setupTwoButtonSwitch() {
        twoButtonSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        twoButtonSwitch.leftButtonPress = { [weak self] in
            // switch to looks collection
            self?.viewModel.switchViewMode(for: .looks)
        }
        
        twoButtonSwitch.rightButtonPress = { [weak self] in
            // switch to items collection
            self?.viewModel.switchViewMode(for: .items)
        }
        
        header.addSubview(twoButtonSwitch)
        
        NSLayoutConstraint.activate([
            twoButtonSwitch.topAnchor.constraint(equalTo: navTitle.bottomAnchor, constant: 11),
            twoButtonSwitch.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 30),
            twoButtonSwitch.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -30),
            twoButtonSwitch.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupFilterToggle() {
        filterToggle.translatesAutoresizingMaskIntoConstraints = false
        filterToggle.setTitle(TextContent.Buttons.sortCloset, for: .normal)
        filterToggle.titleLabel?.font = UIFont.Diwi.floatingButton
        filterToggle.addBottomBorder()
        filterToggle.contentHorizontalAlignment = .left
        header.addSubview(filterToggle)
        
        NSLayoutConstraint.activate([
            filterToggle.topAnchor.constraint(equalTo: twoButtonSwitch.bottomAnchor, constant: 11),
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
        byEvent.translatesAutoresizingMaskIntoConstraints = false
        byEvent.backgroundColor = UIColor.Diwi.barney
        byEvent.titleLabel?.font = UIFont.Diwi.floatingButton
        byEvent.contentHorizontalAlignment = .left
        byEvent.setTitle(TextContent.Buttons.byEvent, for: .normal)
        byEvent.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 43.0, bottom: 0.0, right: 0)
        view.addSubview(byEvent)
        view.sendSubviewToBack(byEvent)
        
        NSLayoutConstraint.activate([
            byEvent.topAnchor.constraint(equalTo: header.bottomAnchor, constant: -45),
            byEvent.leftAnchor.constraint(equalTo: view.leftAnchor),
            byEvent.rightAnchor.constraint(equalTo: view.rightAnchor),
            byEvent.heightAnchor.constraint(equalToConstant: 45)
            ])
        
        byType.translatesAutoresizingMaskIntoConstraints = false
        byType.backgroundColor = UIColor.Diwi.barney
        byType.titleLabel?.font = UIFont.Diwi.floatingButton
        byType.contentHorizontalAlignment = .left
        byType.setTitle(TextContent.Buttons.byType, for: .normal)
        byType.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: 43.0, bottom: 0.0, right: 0)
        view.addSubview(byType)
        view.sendSubviewToBack(byType)
        
        NSLayoutConstraint.activate([
            byType.topAnchor.constraint(equalTo: byEvent.bottomAnchor, constant: -45),
            byType.leftAnchor.constraint(equalTo: view.leftAnchor),
            byType.rightAnchor.constraint(equalTo: view.rightAnchor),
            byType.heightAnchor.constraint(equalToConstant: 45)
            ])
    }
    
    private func setupCollection() {
        closetCollection = CollectionsConfig.closetIndex.collectionView()
        view.addSubview(closetCollection!)
        
        closetCollection!.dataSource = self
        closetCollection!.delegate = self
        closetCollection!.allowsMultipleSelection = true
        closetCollection!.allowsSelection = true
        
        NSLayoutConstraint.activate([
            closetCollection!.topAnchor.constraint(equalTo: header.bottomAnchor),
            closetCollection!.rightAnchor.constraint(equalTo: view.rightAnchor),
            closetCollection!.bottomAnchor.constraint(equalTo: addItemsToEventButton.topAnchor, constant: -12.5),
            closetCollection!.leftAnchor.constraint(equalTo: view.leftAnchor)
            ])
    }
    
    private func setupPlusButton() {
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.setImage(UIImage.Diwi.addIconWhite, for: .normal)
        
        view.addSubview(plusButton)
        
        NSLayoutConstraint.activate([
            plusButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8),
            plusButton.widthAnchor.constraint(equalToConstant: 58),
            plusButton.heightAnchor.constraint(equalToConstant: 58),
            plusButton.bottomAnchor.constraint(equalTo: addItemsToEventButton.topAnchor, constant: -12.5)
            ])
    }
    
    private func setupAddItemsToEventButton() {
        addItemsToEventButton.translatesAutoresizingMaskIntoConstraints = false
        addItemsToEventButton.titleLabel?.font = UIFont.Diwi.floatingButton
        addItemsToEventButton.setTitleColor(.white, for: .normal)
        addItemsToEventButton.backgroundColor = UIColor.Diwi.barney
        addItemsToEventButton.roundAllCorners(radius: 25)
        
        view.addSubview(addItemsToEventButton)

        NSLayoutConstraint.activate([
            addItemsToEventButton.heightAnchor.constraint(equalToConstant: 50),
            addItemsToEventButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            addItemsToEventButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            addItemsToEventButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
        ])
    }
    
    private func setupSpinner() {
        spinnerView = UIView.init(frame: view.bounds)
    }
    
    private func setupEmptyState() {
        emptyMessage.translatesAutoresizingMaskIntoConstraints = false
        emptyMessage.inverseColor()
        emptyMessage.setTitleColor(UIColor.Diwi.barney, for: .normal)
        emptyMessage.titleLabel?.font = UIFont.Diwi.button
        
        view.addSubview(emptyMessage)
        
        NSLayoutConstraint.activate([
            emptyMessage.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -175),
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
extension WhatDidIWearViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return viewModel.getClosetItemsCount()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ClosetCell = closetCollection!.dequeueReusableCell(for: indexPath)
        let closetItem = viewModel.getClosetItem(at: indexPath.row)
        cell.indexItem = closetItem
        
        cell.setup(mode: viewMode)
        if let id = closetItem.id, viewModel.isSelectedItem(with: id) {
            cell.selectedState(value: true)
        } else {
            cell.selectedState(value: false)
        }
        
        return cell
    }
}

// MARK: - Collection view delegate methods
extension WhatDidIWearViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // add to selected items array and add selected border
        if let cell = collectionView.cellForItem(at: indexPath) as? ClosetCell {
            cell.selectedState(value: true)
            let item = viewModel.getClosetItem(at: indexPath.row)
            viewModel.addToSelectedItem(item: item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        // remove from selected items array and add selected border
        if let cell = collectionView.cellForItem(at: indexPath) as? ClosetCell {
            cell.selectedState(value: false)
            let item = viewModel.getClosetItem(at: indexPath.row)
            viewModel.removeSelectedItem(item: item)
        }
    }
}

// MARK: - Collection view flow layout delegate methods
extension WhatDidIWearViewController: UICollectionViewDelegateFlowLayout {
    
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
