//
//  DeleteClosetItemsViewController.swift
//  Diwi
//
//  Created by Dominique Miller on 1/9/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit

import UIKit
import RxSwift
import RxCocoa

class DeleteClosetItemsViewController: UIViewController {
    
    // MARK: - view props
    let header              = UIView()
    let backIcon            = UIButton()
    let navTitle            = UILabel()
    let filterToggle        = UIButton()
    let buttonBorder        = UIView()
    let arrowIcon           = UIImageView()
    let byLatestDate        = UIButton()
    let byEarliestDate      = UIButton()
    let byType              = UIButton()
    var spinnerView         = UIView()
    
    // MARK: - internal props
    let disposeBag = DisposeBag()
    var viewModel: ClosetViewModel!
    let filtersOpen = BehaviorRelay<Bool>(value: false)
    let screenWidth = UIScreen.main.bounds.width
    var goToLogin: (() -> Void)?
    var goBack: (() -> Void)?
    var goToRemoveModal: (([Int], Workflow) -> Void)?
    var collectionView: UICollectionView?
    var workflow: Workflow {
        return viewModel.workflow
    }
    var viewMode: ClosetViewMode {
        return viewModel.getViewMode()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        createViewModelBinding()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
            self.collectionView?.frame.origin.y -= 135
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
            self.collectionView?.frame.origin.y += 135
        }
    }
}

// MARK: - View model bindings
extension DeleteClosetItemsViewController {
    private func createViewModelBinding() {
        backIcon.rx.tap.bind {
                self.goBack?()
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
        
        
        filtersOpen.subscribe(onNext: { [unowned self] (value: Bool) in
            if value {
                self.openFilters()
            }
            else {
                self.closeFilters()
            }
        }).disposed(by: disposeBag)
        
        viewModel.navTitle
            .subscribe(onNext: { [unowned self] value in
                self.navTitle.text = value
        }).disposed(by: disposeBag)
        
        viewModel.closetItems
            .subscribe(onNext: { [unowned self] value in
                self.collectionView?.reloadData()
            }).disposed(by: disposeBag)
        
        viewModel.errorStatus
            .subscribe(onNext: { [unowned self] (value: Int) in
                if value == 401 {
                    self.goToLogin?()
                }
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
extension DeleteClosetItemsViewController {
    private func setupView() {
        setupHeader()
        setupNav()
        setupFilterToggle()
        setupMenu()
        setupCollection()
        setupSpinner()
    }
    
    private func setupHeader() {
        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = UIColor.Diwi.barney
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
        navTitle.font = UIFont.Diwi.titleBold
        header.addSubview(navTitle)

        NSLayoutConstraint.activate([
            navTitle.topAnchor.constraint(equalTo: header.topAnchor, constant: paddingTop),
            navTitle.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            ])
        
    }
    
    private func setupSpinner() {
        spinnerView = UIView.init(frame: view.bounds)
    }
    
    private func setupFilterToggle() {
        filterToggle.translatesAutoresizingMaskIntoConstraints = false
        filterToggle.setTitle(TextContent.Buttons.sortCloset, for: .normal)
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
        view.addSubview(byType)
        view.sendSubviewToBack(byType)
        
        NSLayoutConstraint.activate([
            byType.topAnchor.constraint(equalTo: byEarliestDate.bottomAnchor, constant: -45),
            byType.leftAnchor.constraint(equalTo: view.leftAnchor),
            byType.rightAnchor.constraint(equalTo: view.rightAnchor),
            byType.heightAnchor.constraint(equalToConstant: 45)
        ])
    }
    
    private func setupCollection() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView!.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView!)
        
        collectionView!.dataSource = self
        collectionView!.delegate = self
        collectionView!.register(ClosetCell.self, forCellWithReuseIdentifier: ClosetCell.reuseIdentifier)
        collectionView!.register(CollectionViewFooter.self,
                                 forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                 withReuseIdentifier: CollectionViewFooter.reuseIdentifier)
        collectionView!.alwaysBounceVertical = true
        collectionView!.backgroundColor = .white
        
        NSLayoutConstraint.activate([
            collectionView!.topAnchor.constraint(equalTo: header.bottomAnchor),
            collectionView!.rightAnchor.constraint(equalTo: view.rightAnchor),
            collectionView!.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView!.leftAnchor.constraint(equalTo: view.leftAnchor)
            ])
    }
}

// MARK: - Collection view data source delegate methods
extension DeleteClosetItemsViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return viewModel.getClosetItemsCount()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ClosetCell = collectionView.dequeueReusableCell(for: indexPath)
        let closetItem = viewModel.getClosetItem(at: indexPath.row)
        cell.indexItem = closetItem
        cell.setup(mode: viewMode)
        cell.showDeleteButton = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? ClosetCell,
            let id = viewModel.getClosetItem(at: indexPath.row).id else { return }
        
        if cell.selectedForDeletion {
            viewModel.removeClosetItemToBeDeleted(id: id)
            cell.selectedForDeletion = false
        } else {
            viewModel.addClosetItemToBeDeleted(id: id)
            cell.selectedForDeletion = true
        }
    }
}

// MARK: - Collection view delegate methods
extension DeleteClosetItemsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        layout  collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize{
        
        let size = CGSize(width: screenWidth, height: 75)
        
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if (kind == UICollectionView.elementKindSectionFooter) {
            guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                   withReuseIdentifier: CollectionViewFooter.reuseIdentifier,
                                                                                   for: indexPath) as? CollectionViewFooter else { fatalError("Invalid view type") }
            
            
            footerView.setup(text: viewModel.removeButtonText.value, style: .largeButton)
            
            footerView.buttonPressed = { [weak self] in
                guard let workflow = self?.workflow,
                    let ids = self?.viewModel.getClosetItemIds(),
                    ids.count > 0 else { return }
                
                self?.goToRemoveModal?(ids, workflow)
            }
            
            return footerView
        }
        
        fatalError()
    }
}

// MARK: - Collection view flow layout delegate methods
extension DeleteClosetItemsViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 98, height: 110)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 26, left: 20, bottom: 36, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
}
