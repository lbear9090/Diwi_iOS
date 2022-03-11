import UIKit
import RxSwift
import RxCocoa

class LoadingViewController: UIViewController {
    
    // MARK: - view props
    let logo = UIImageView()

    // MARK: - internal props
    weak var coordinator: MainCoordinator?
    let disposebag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        coordinator?.closet()
        loadClothingItems()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func loadClothingItems() {
//        ClothingItemService().index()
//            .observeOn(MainScheduler.instance)
//            .subscribe(onNext: { response in
////                print(response.count)
//                self.coordinator?.closet(clothingItems: response)
//            }, onError: { error in
//                print("error")
//            }).disposed(by: disposebag)
    }
    
}

// MARK: - Setup view
extension LoadingViewController {
    private func setupView() {
        
        setupLogo()
        
    }
    
    private func setupLogo() {
        let image : UIImage = UIImage.Diwi.logo2
        logo.image = image
        logo.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.Diwi.barney
        view.addSubview(logo)
        
        NSLayoutConstraint.activate([
            logo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logo.topAnchor.constraint(equalTo: view.topAnchor, constant: 50)
            ])
    
    }
    
   
}
