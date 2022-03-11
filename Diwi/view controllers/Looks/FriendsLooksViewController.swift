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

class FriendsLooksViewController: UIViewController {
    
    @IBOutlet weak var contentContainerView: UIView!
    @IBOutlet weak var tabBarIndicatorWidth: NSLayoutConstraint!
    @IBOutlet weak var tabBarIndicator: UIView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var filterDescriptionLabel: UILabel!
    @IBOutlet weak var collectionVw: UICollectionView!
    
    let searchController = UISearchController(searchResultsController: nil)
    var cellTapped: (() -> Void)?
    let rightBarButtonItem = UIBarButtonItem()
    var toggleState = 1
    let lookService = LookService()
    let disposebag = DisposeBag()
    var looks: [Look] = []
    var emptyView: EmptyLooksView!
    var filterIsDescending: Bool = false
    var filterAscending: UIBarButtonItem!
    var filterDescending: UIBarButtonItem!
    var looksArr:[LookModel]?
    var coordinator: MainCoordinator?
    var friendID = String()
    var descriptionText = String()
    var viewModel: GlobalSearchViewModel!
    let disposeBag = DisposeBag()
    let transition = BubbleTransition()
    let interactiveTransition = BubbleInteractiveTransition()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coordinator = MainCoordinator(navController: self.navigationController!)
        viewModel = GlobalSearchViewModel(searchService: GlobalSearchService())
        filterDescriptionLabel.text = descriptionText
        setupNavBar()
        setupCollectionView()
        setupSearchBar()
        setupFilterButton()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Search"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !friendID.isEmpty
        {
            getLooksFromServer()
        }
    }
    
    @IBAction func addLookButton(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func filterButtonTapped(_ sender: Any) {
        if toggleState == 1 {
            toggleState = 2
            filterButton.setImage(UIImage(named: "filter_descend")!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
            filterButton.tintColor = UIColor.darkGray
            if let sortedArray = self.looksArr?.sorted(by: { $0.id ?? .zero > $1.id ?? .zero })
            {
                self.looksArr = sortedArray
            }
            
            self.collectionVw.reloadData()
            
        } else {
            toggleState = 1
            filterButton.setImage(UIImage(named: "filter_ascend")!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
            filterButton.tintColor = UIColor.darkGray
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
        //self.showEmptyLooksPlaceholder()
        self.collectionVw.reloadData()
    }
    
    private func getLooksFromServer() {
        Loader.show()
        APIManager.fetchFriendsLooks(parameters: ["search":["search_term":friendID]]) { (looksvm, error) in
            DispatchQueue.main.async {
                Loader.hide()
                if error == nil {
                    if let allLooks = looksvm {
                        self.looksArr = allLooks
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
    }
    
    func amimateTabBarIndicator() {
        tabBarIndicator.isOpaque = true
        tabBarIndicator.backgroundColor = UIColor.Diwi.barney
        tabBarIndicatorWidth.constant = self.view.frame.width / 3
    }
    
    func setupFilterButton() {
        filterButton.setImage(UIImage(named: "filter_ascend")!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate), for: .normal)
        filterButton.tintColor = UIColor.darkGray
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
        self.navigationItem.title = "Did I Wear It?!"
        
        self.navigationController?.hideHairline()
    }
    
    func setupSearchBar() {
        /*
         Having to target items in the SearchController manually due to bug in iOS 13:
         https://stackoverflow.com/questions/33751292/cannot-change-search-bar-background-color/45739782
         */
        
        searchController.delegate = self
        let textField = searchController.searchBar.value(forKey: "searchField") as! UITextField
        
        let glassIconView = textField.leftView as! UIImageView
        glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
        glassIconView.tintColor = UIColor.white
        
        let clearButton = textField.value(forKey: "clearButton") as! UIButton
        clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        clearButton.tintColor = UIColor.white
        
        let searchTextField: UITextField? = searchController.searchBar.value(forKey: "searchField") as? UITextField
        if searchTextField!.responds(to: #selector(getter: UITextField.attributedPlaceholder)) {
            let attributeDict = [NSAttributedString.Key.foregroundColor: UIColor.white]
            searchTextField!.attributedPlaceholder = NSAttributedString(string: TextContent.Placeholders.searchBy, attributes: attributeDict)
        }
        searchTextField?.font = UIFont.Diwi.h1
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.white], for: .normal)
        
        searchController.searchBar.searchBarStyle = .prominent
        searchController.searchBar.isTranslucent = false
        let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.backgroundColor = UIColor.Diwi.barney
        textFieldInsideSearchBar?.layer.borderColor = UIColor.white.cgColor
        textFieldInsideSearchBar?.layer.borderWidth = 1
        textFieldInsideSearchBar?.layer.cornerRadius = 18
        searchController.searchBar.barTintColor = UIColor.white
        textFieldInsideSearchBar?.font = UIFont.Diwi.h1
    }
    
    func setupCollectionView() {
        self.collectionVw.dataSource = self
        self.collectionVw.delegate = self
        collectionVw.register(UINib.init(nibName: "LooksCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LooksCollectionViewCell")
    }
    
}

// MARK: - CollectionView Delegate
extension FriendsLooksViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.looksArr?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LooksCollectionViewCell", for: indexPath) as! LooksCollectionViewCell
        
        if self.looksArr?.count == 0 {
            collectionView.isHidden = true
            //showEmptyLooksPlaceholder()
        }
        
        cell.contentView.layer.cornerRadius = 25
        cell.backgroundImageView.contentMode = .scaleAspectFill
        cell.backgroundImageView.backgroundColor = .lightText
        if let imgUrl = URL.init(string: self.looksArr?[indexPath.row].thumbnail ?? "") {
            cell.backgroundImageView.sd_setShowActivityIndicatorView(true)
            cell.backgroundImageView.sd_setIndicatorStyle(.gray)
            cell.backgroundImageView.sd_setImage(with: imgUrl, placeholderImage: UIImage.init(named: "placeholderImage.png"), options: .highPriority) { (image, error, type, url) in
                if error == nil {
                }
            }
        }
        
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
    
    func globalSearch() {
                
        self.tabBarController?.tabBar.isHidden = true

        let vc = GlobalSearchViewController()
        let vm = GlobalSearchViewModel(searchService: GlobalSearchService())
        vc.viewModel = vm
        vc.comingFrom = "looksTab"
        vc.coordinator = coordinator
        vc.close = {
            vc.dismiss(animated: false)
        }
//
//        vc.goToResult = { [weak self] result in
//            guard let id = result.id else { return }
////            vc.dismiss(animated: true) {
//                switch result.modelType {
//                case .ClothingItems:
//                    let item = ClothingItem()
//                    item.id = id
//                    guard let coord = self?.coordinator else { return }
//                    coord.closetItem(item: item)
//                case .Contacts:
//                    debugPrint("")
//                    guard let coord = self?.coordinator else { return }
//                    coord.viewContact(with: id)
//                case .Events:
//                    let event = Event()
//                    event.id = id
//                case .Looks:
//                    debugPrint("")
//                    guard let coord = self?.coordinator else { return }
//                    coord.viewLook(with: id)
//                default:
//                    return
//                }
////            }
//        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
  }

extension FriendsLooksViewController: UICollectionViewDelegateFlowLayout {
    
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
extension FriendsLooksViewController: UISearchBarDelegate, UISearchControllerDelegate {
    
    func willPresentSearchController(_ searchController: UISearchController) {
        globalSearch()
    }
    
}

//MARK: - PlaceHolder View
extension FriendsLooksViewController: EmptyLooksViewDelegate {
    func createNewLook() {
        
    }
    
    func showEmptyLooksPlaceholder() {
//        emptyView = EmptyLooksView()
//        contentContainerView.addSubview(emptyView)
    }
}


extension FriendsLooksViewController: UIViewControllerTransitioningDelegate
{
    // MARK: UIViewControllerTransitioningDelegate
   
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
      transition.transitionMode = .present
        transition.startingPoint = (self.navigationController?.view.center)!
        transition.bubbleColor = UIColor.white
      return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
      transition.transitionMode = .dismiss
        transition.startingPoint = (self.navigationController?.view.center)!
        transition.bubbleColor = UIColor.white
      return transition
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
      return interactiveTransition
    }
}

