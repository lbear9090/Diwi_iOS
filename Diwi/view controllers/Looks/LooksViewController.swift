//
//  LooksViewController.swift
//  Diwi
//
//  Created by Shane Work on 10/28/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit
import RxSwift
import Alamofire
import AlamofireImage
import AVKit

class LooksViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var contentContainerView: UIView!
    @IBOutlet weak var createALookView: UIView!
    @IBOutlet weak var tabBarIndicatorWidth: NSLayoutConstraint!
    @IBOutlet weak var tabBarIndicator: UIView!
    @IBOutlet weak var collectionVw: UICollectionView!
    @IBOutlet weak var searchTableView: UITableView!
    var filterCustomButton = UIButton()
    var searchController : UISearchController!
    var cellTapped: (() -> Void)?
    let rightBarButtonItem = UIBarButtonItem()
    var toggleState = 2
    let lookService = LookService()
    let disposebag = DisposeBag()
    var looks: [Look] = []
    var emptyView: EmptyLooksView!
    var filterIsDescending: Bool = false
    var filterAscending: UIBarButtonItem!
    var filterDescending: UIBarButtonItem!
    var looksArr:[LookModel]?
    var coordinator: MainCoordinator?
    var viewModel: GlobalSearchViewModel!
    let disposeBag = DisposeBag()
    let transition = BubbleTransition()
    let interactiveTransition = BubbleInteractiveTransition()
    var touchPoints: CGPoint!
    var peekPop: PeekPop?
    var previewingContext: PreviewingContext?
    var _resultsTableController: GlobalSearchVC? = nil
    var refresher:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var array = ["Adrian","April","Alexa","adrian b"]

        array = array.sorted(by: { (lhs: String, rhs: String) -> Bool in
            return lhs.caseInsensitiveCompare(rhs) == .orderedAscending
        })
        
        

//        array = array.sorted { (lhs: String, rhs: String) -> Bool in do {
//            return lhs.caseInsensitiveCompare(rhs) == .orderedAscending
//        }

        print("array: ",array)
        
        coordinator = MainCoordinator(navController: self.navigationController!)
        viewModel = GlobalSearchViewModel(searchService: GlobalSearchService())
        
        collectionVw.register(UINib(nibName: "CollectionHeaderCell", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CollectionHeaderCell")
        
        filterCustomButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.size.width - 80, y: 2, width: 35, height: 35))
        filterCustomButton.backgroundColor = .clear
        filterCustomButton.addTarget(self, action:#selector(self.buttonClicked(_:)), for: .touchUpInside)
        filterCustomButton.setBackgroundImage(UIImage(named: "descending_gray"), for: .normal)

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "GlobalSearchVC") as? GlobalSearchVC
        {
            searchController = UISearchController(searchResultsController: controller)
            controller.close = {
                self.searchController.isActive = false
            }
        }
        
        setupNavBar()
        setupCollectionView()
        setupSearchBar()
        getLooksFromServer()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress))
        longPress.minimumPressDuration = 0.5
        longPress.delegate = self
        longPress.delaysTouchesBegan = false
        self.collectionVw?.addGestureRecognizer(longPress)
        
        NotificationCenter.default.addObserver(self,selector: #selector(self.friendsAdded),name: NSNotification.Name(rawValue: lookAddedString),object: nil)

        
    }
    
    
    
    @objc private func friendsAdded(notification: NSNotification) {
        getLooksFromServer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.Diwi.h1b]
        self.navigationItem.title = "Did I Wear It?!"
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //self.navigationItem.searchController?.isActive = false
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func addLookButton(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func filterButtonTapped(_ sender: Any) {
        
    }
    
    @objc func buttonClicked(_ sender: UIButton?) {
        if toggleState == 1 {
            toggleState = 2
            filterCustomButton.setBackgroundImage(nil, for: .normal)
            filterCustomButton.setBackgroundImage(UIImage(named: "descending_gray"), for: .normal)
            if let sortedArray = self.looksArr?.sorted(by: { $0.id ?? .zero > $1.id ?? .zero })
            {
                self.looksArr = sortedArray
            }
            self.collectionVw.reloadData()
        } else {
            toggleState = 1
            filterCustomButton.setBackgroundImage(nil, for: .normal)
            filterCustomButton.setBackgroundImage(UIImage(named: "ascending_gray"), for: .normal)
            if let sortedArray = self.looksArr?.sorted(by: { $0.id ?? .zero < $1.id ?? .zero })
            {
                self.looksArr = sortedArray
            }
            self.collectionVw.reloadData()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    func getLooks() {
        self.showEmptyLooksPlaceholder()
        self.collectionVw.reloadData()
    }
    
    private func getLooksFromServer() {
        Loader.show()
        APIManager.fetchLooks { (looksvm, error) in
            Loader.hide()
            if error == nil {
                if let allLooks = looksvm {
                    self.looksArr = allLooks.looks
                    if let sortedArray = self.looksArr?.sorted(by: { $0.id ?? .zero > $1.id ?? .zero })
                    {
                        self.looksArr = sortedArray
                        self.contentContainerView.isHidden = false
                    }
                    if (self.looksArr?.count ?? 0) == 0
                    {
                        self.contentContainerView.isHidden = true
                    }
                    self.collectionVw.reloadData()
                }else
                {
                    self.contentContainerView.isHidden = true
                }
            }else
            {
                AlertController.alert(message: "Something went wrong.")
            }
        }
    }
    
    func amimateTabBarIndicator() {
        tabBarIndicator.isOpaque = true
        tabBarIndicator.backgroundColor = UIColor.Diwi.barney
        tabBarIndicatorWidth.constant = self.view.frame.width / 3
    }
    
    func setupNavBar() { // TODO: split off to it's own extension
        if #available(iOS 13.0, *) {
            let buttonAppearance = UIBarButtonItemAppearance()
            buttonAppearance.configureWithDefault(for: .plain)
            buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
            
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithOpaqueBackground()
            navigationBarAppearance.backgroundColor = UIColor.Diwi.barney
            navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            
            navigationBarAppearance.backButtonAppearance = buttonAppearance
            navigationBarAppearance.buttonAppearance = buttonAppearance
            navigationBarAppearance.doneButtonAppearance = buttonAppearance
            
            navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
            navigationController?.navigationBar.compactAppearance = navigationBarAppearance
            navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        } else {
            navigationController?.navigationBar.barTintColor = UIColor.Diwi.barney
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
            navigationController?.navigationBar.tintColor = .white
        }
        navigationController?.navigationBar.tintColor = .white
        self.navigationItem.searchController = searchController
        self.navigationController?.hideHairline()
    }
    
    func setupSearchBar() {
        
        self._resultsTableController = GlobalSearchVC(style: .plain)
        self.navigationItem.searchController = UISearchController(searchResultsController: self._resultsTableController)
        self.navigationItem.searchController?.searchResultsUpdater = self
        self.navigationItem.searchController?.delegate = self
        definesPresentationContext = true
        self.navigationItem.searchController?.dimsBackgroundDuringPresentation = false
        self.navigationItem.searchController?.searchBar.delegate = self
        
        let textField = self.navigationItem.searchController?.searchBar.value(forKey: "searchField") as! UITextField
        let glassIconView = textField.leftView as! UIImageView
        glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
        glassIconView.tintColor = UIColor.white
        textField.textColor = UIColor.white
        
        let clearButton = textField.value(forKey: "clearButton") as! UIButton
        clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        clearButton.tintColor = UIColor.white
        
        let searchTextField: UITextField? = self.navigationItem.searchController?.searchBar.value(forKey: "searchField") as? UITextField
        if searchTextField!.responds(to: #selector(getter: UITextField.attributedPlaceholder)) {
            let attributeDict = [NSAttributedString.Key.foregroundColor: UIColor.white]
            searchTextField!.attributedPlaceholder = NSAttributedString(string: TextContent.Placeholders.searchBy, attributes: attributeDict)
        }
        searchTextField?.font = UIFont.Diwi.h1
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white], for: .normal)
        
        self.navigationItem.searchController?.searchBar.searchBarStyle = .prominent
        self.navigationItem.searchController?.searchBar.isTranslucent = false
        self.navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
        let textFieldInsideSearchBar = self.navigationItem.searchController?.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = UIColor.Diwi.barney
        textFieldInsideSearchBar?.layer.borderColor = UIColor.white.cgColor
        textFieldInsideSearchBar?.layer.borderWidth = 1
        textFieldInsideSearchBar?.layer.cornerRadius = 18
        self.navigationItem.searchController?.searchBar.barTintColor = UIColor.white
        textFieldInsideSearchBar?.font = UIFont.Diwi.h1
        textFieldInsideSearchBar?.textColor = UIColor.white
        
        //        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: nil)
        //        cancelButton.tintColor = .white
        //        self.navigationItem.rightBarButtonItem = cancelButton
    }
    
    func setupCollectionView() {
        
        self.refresher = UIRefreshControl()
        self.refresher.addTarget(self, action: #selector(didPullToRefresh(_:)), for: .valueChanged)
        collectionVw.alwaysBounceVertical = true
        collectionVw.refreshControl = self.refresher
        
        self.collectionVw.dataSource = self
        self.collectionVw.delegate = self
        collectionVw.register(UINib.init(nibName: "LooksCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LooksCollectionViewCell")
    }
    
    @objc
    private func didPullToRefresh(_ sender: Any) {
        getLooksFromServer()
        self.refresher.endRefreshing()
    }
    
}

// MARK: - CollectionView Delegate
extension LooksViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CollectionHeaderCell", for: indexPath) as? CollectionHeaderCell
            {
                filterCustomButton.removeFromSuperview()
                headerView.addSubview(filterCustomButton)
                if toggleState == 1 {
                    headerView.nameLabel.text = "All looks, newest to oldest"
                } else {
                    headerView.nameLabel.text = "All looks, oldest to newest"
                }
                return headerView
            }
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CollectionHeaderCell", for: indexPath)
            return footerView
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.looksArr?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LooksCollectionViewCell", for: indexPath) as! LooksCollectionViewCell
        
        if self.looksArr?.count == 0 {
            collectionView.isHidden = true
            showEmptyLooksPlaceholder()
        }
        
        cell.contentView.layer.cornerRadius = 25
        cell.backgroundImageView.contentMode = .scaleAspectFill
        cell.backgroundImageView.backgroundColor = .lightText
        if let imgUrl = URL.init(string: webApiBaseURL + (self.looksArr?[indexPath.row].thumbnail ?? "")) {
            cell.backgroundImageView.sd_setShowActivityIndicatorView(true)
            cell.backgroundImageView.sd_setIndicatorStyle(.gray)
            cell.backgroundImageView.sd_setImage(with: imgUrl, placeholderImage: UIImage.init(named: "placeholderImage.png"), options: .highPriority) { (image, error, type, url) in
                if error == nil {
                }
            }
        }
        
        cell.backgroundImageView.accessibilityLabel = self.looksArr?[indexPath.row].title
        cell.contentView.layer.masksToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Cell TAapped")
        self.navigationItem.title = ""
        self.tabBarController?.tabBar.isHidden = true
        if let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LookDetailVC") as? LookDetailVC
        {
            vc.lookID = "\(self.looksArr?[indexPath.row].id ?? 0)"
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func handleLongPress(gestureRecognizer : UILongPressGestureRecognizer){
        if (gestureRecognizer.state == UIGestureRecognizer.State.began) {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            touchPoints = gestureRecognizer.location(in: self.view)
            let p = gestureRecognizer.location(in: self.collectionVw)
            if let indexPath : IndexPath = (self.collectionVw?.indexPathForItem(at: p)){
                let storyboard = UIStoryboard(name:"Preview", bundle:nil)
                if let controller = storyboard.instantiateViewController(withIdentifier: "PreviewViewController") as? PreviewViewController {
                    controller.transitioningDelegate = self
                    controller.modalPresentationStyle = .custom
                    controller.modalPresentationCapturesStatusBarAppearance = true
                    controller.interactiveTransition = interactiveTransition
                    if let cell = self.collectionVw.cellForItem(at: indexPath) as? LooksCollectionViewCell
                    {
//                        let cgrect = CGRect(x: (self.view.bounds.width - 60)/2, y: (self.view.bounds.height - 500)/2, width: self.view.bounds.width - 60, height: 500)
//                        let rect = AVMakeRect(aspectRatio: cell.backgroundImageView.image!.size, insideRect: cgrect)
//                        controller.viewWidth = rect.width
//                        controller.viewHeight = rect.height
                        //controller.image = UIImage.init(named: "placeholderImage.png")
                        controller.titleStr = cell.backgroundImageView.accessibilityLabel
                        controller.imageURL = self.looksArr?[indexPath.row].image ?? ""
                        controller.lookID = "\(self.looksArr?[indexPath.row].id ?? 0)"
                    }
                    interactiveTransition.attach(to: controller)
                    self.present(controller, animated: true, completion: nil)
                }
            }
        }
    }
    
}

extension LooksViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = collectionView.bounds.width / 3 - 6
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 2, bottom: 5, right: 2) //.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }

}

// MARK: - UISearchBar Delegate
extension LooksViewController: UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate  {
    
    func willPresentSearchController(_ searchController: UISearchController) {
        //globalSearch()
    }
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let text = self.navigationItem.searchController?.searchBar.text else {
            return
        }
        if text.count > 2
        {
            self._resultsTableController?.updateSearchResults(searchString: text)
        }
    }
}

//MARK: - PlaceHolder View
extension LooksViewController: EmptyLooksViewDelegate {
    func createNewLook() {
        
    }
    
    func showEmptyLooksPlaceholder() {
        emptyView = EmptyLooksView()
        contentContainerView.addSubview(emptyView)
    }
}

extension UINavigationController {
    func hideHairline() {
        if let hairline = findHairlineImageViewUnder(navigationBar) {
            hairline.isHidden = true
        }
    }
    func restoreHairline() {
        if let hairline = findHairlineImageViewUnder(navigationBar) {
            hairline.isHidden = false
        }
    }
    func findHairlineImageViewUnder(_ view: UIView) -> UIImageView? {
        if view is UIImageView && view.bounds.size.height <= 1.0 {
            return view as? UIImageView
        }
        for subview in view.subviews {
            if let imageView = self.findHairlineImageViewUnder(subview) {
                return imageView
            }
        }
        return nil
    }
    
    func removeViewController(_ controller: UIViewController.Type) {
        if let viewController = viewControllers.first(where: { $0.isKind(of: controller.self) }) {
            viewController.removeFromParent()
        }
    }
}

extension LooksViewController: UIViewControllerTransitioningDelegate
{
    // MARK: UIViewControllerTransitioningDelegate
    
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = touchPoints//(self.navigationController?.view.center)!
        transition.bubbleColor = UIColor.white
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = touchPoints//(self.navigationController?.view.center)!
        transition.bubbleColor = UIColor.white
        return transition
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition
    }
}

