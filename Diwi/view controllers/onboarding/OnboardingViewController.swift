//
//  OnboardingViewController.swift
//  Diwi
//
//  Created by Dominique Miller on 1/28/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

final class OnboardingViewController: UIViewController {
    
    // MARK: - View prop
    let sliderContainer = UIView()
    let slider          = HorizontalScrollerView()
    let bottomContainer = UIView()
    let slideText       = UILabel()
    let skipThis        = UIButton()
    let pageControl     = UIPageControl()
    
    // MARK: - Internal Props
    let disposeBag = DisposeBag()
    var slides: [OnboardingSlide] = []
    let sliderWidth = (UIScreen.main.bounds.width * 4)
    var finished: (() -> Void)?
    var currentIndex: Driver<Int> { return _currentIndex.asDriver() }
    private let _currentIndex = BehaviorRelay<Int>(value: 0)
    var toSmall: JXPageControlScale!
    weak var coordinator: MainCoordinator?

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let customView = Bundle.main.loadNibNamed("PageControl", owner: self, options: nil)?.first as? PageControl {
//            pageControl = customView
//            pageControl.frame.size.height = 50;
//            pageControl.frame.size.width = 160;
//            pageControl.backgroundColor = .gray
//        }
        
        pageControl.transform = CGAffineTransform(scaleX: 2, y: 2)
        self.pageControl.pageIndicatorTintColor = .white

        slider.dataSource = self
        slider.delegate = self
        setupSlides()
        setupView()
        setupBindings()
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
            
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        reloadPlayerSlider()
    }
    
    private func reloadPlayerSlider() {
        slider.reload(0)
    }
    
    func setupSlides() {
        let whatSlide = OnboardingSlide(titleImage: OnboardingData.What.titleImage,
                                        background: OnboardingData.What.backgroundImage,
                                        text: OnboardingData.What.text,
                                        indicatorColor: OnboardingData.What.indicatorColor)
        
        slides.append(whatSlide)
        
        let whereSlide = OnboardingSlide(titleImage: OnboardingData.Where.titleImage,
                                        background: OnboardingData.Where.backgroundImage,
                                        text: OnboardingData.Where.text,
                                        indicatorColor: OnboardingData.What.indicatorColor)
        
        slides.append(whereSlide)
        
        let whenSlide = OnboardingSlide(titleImage: OnboardingData.When.titleImage,
                                        background: OnboardingData.When.backgroundImage,
                                        text: OnboardingData.When.text,
                                        indicatorColor: OnboardingData.What.indicatorColor)
        
        slides.append(whenSlide)
        
        let whoSlide = OnboardingSlide(titleImage: OnboardingData.Who.titleImage,
                                       background: OnboardingData.Who.backgroundImage,
                                       text: OnboardingData.Who.text,
                                       indicatorColor: OnboardingData.What.indicatorColor)
        
        slides.append(whoSlide)
    }
    
    func setupBindings() {
        currentIndex.drive(onNext: { [unowned self] value in
            self.slideText.text = self.slides[value].text
            self.pageControl.currentPage = value
            self.pageControl.currentPageIndicatorTintColor = self.slides[value].indicatorColor
        }).disposed(by: disposeBag)
        
        skipThis.rx.tap.bind { [unowned self] in
            self.finished?()
        }.disposed(by: disposeBag)
    }
    
    private func startWithoutOnboarding() {
        NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: "", userInfo: nil)
        self.navigationController?.popToRootViewController(animated: false)
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
            
        if (sender.direction == .left) {
            let index: Int = slider.currentShownIndex + 1
            guard index < slides.count else { return }
            
            slider.scrollToView(at: index)
            _currentIndex.accept(index)
            
        }
            
        if (sender.direction == .right) {
            let index: Int = slider.currentShownIndex - 1
            guard index >= 0 else { return }
            
            slider.scrollToView(at: index)
            _currentIndex.accept(index)
            
        }
    }
}

// MARK: - Setup View
extension OnboardingViewController {
    private func setupView() {
        setupBottomContainer()
        setupSliderContainer()
        setupSlideText()
        setupPageControl()
        setupSkipThisButton()
        setupSlider()
    }
    
    private func setupBottomContainer() {
        bottomContainer.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.backgroundColor = .black
        
        view.addSubview(bottomContainer)
        
        NSLayoutConstraint.activate([
            bottomContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
            bottomContainer.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomContainer.heightAnchor.constraint(equalToConstant: 210),
            bottomContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupSliderContainer() {
        sliderContainer.translatesAutoresizingMaskIntoConstraints = false
        sliderContainer.backgroundColor = .black
        
        view.addSubview(sliderContainer)
        
        NSLayoutConstraint.activate([
            sliderContainer.leftAnchor.constraint(equalTo: view.leftAnchor),
            sliderContainer.rightAnchor.constraint(equalTo: view.rightAnchor),
            sliderContainer.topAnchor.constraint(equalTo: view.topAnchor),
            sliderContainer.bottomAnchor.constraint(equalTo: bottomContainer.topAnchor)
        ])
    }
    
    private func setupSlideText() {
        slideText.translatesAutoresizingMaskIntoConstraints = false
        slideText.numberOfLines = 0
        slideText.textColor = .white
        slideText.font = UIFont.Diwi.textField
        slideText.textAlignment = .center
        
        bottomContainer.addSubview(slideText)
        
        NSLayoutConstraint.activate([
            slideText.widthAnchor.constraint(equalToConstant: 256),
            slideText.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: 0),
            slideText.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupPageControl() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        
        pageControl.addTarget(self, action: #selector(handlePageControlTap), for: .valueChanged)
        
        bottomContainer.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: bottomContainer.centerXAnchor),
            pageControl.widthAnchor.constraint(equalToConstant: 175),
            pageControl.topAnchor.constraint(equalTo: slideText.bottomAnchor, constant: 50)
        ])
    }
    
    @objc func handlePageControlTap(sender: UIPageControl) {
        slider.scrollToView(at: sender.currentPage)
        _currentIndex.accept(sender.currentPage)
    }
    
    private func setupSkipThisButton() {
        skipThis.translatesAutoresizingMaskIntoConstraints = false
        skipThis.setTitle(TextContent.Onboarding.skipThis, for: .normal)
        skipThis.setTitleColor(.white, for: .normal)
        skipThis.titleLabel?.font = UIFont.Diwi.h1
        
        bottomContainer.addSubview(skipThis)
        
        NSLayoutConstraint.activate([
            skipThis.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            skipThis.heightAnchor.constraint(equalToConstant: 17),
            skipThis.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 50)
        ])
    }
    
    private func setupSlider() {
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.isScrollEnabled = false
        slider.isTapEnabled = false
        
        sliderContainer.addSubview(slider)
        
        NSLayoutConstraint.activate([
            slider.topAnchor.constraint(equalTo: sliderContainer.topAnchor),
//            slider.widthAnchor.constraint(equalToConstant: sliderWidth),
            slider.rightAnchor.constraint(equalTo: sliderContainer.rightAnchor),
            slider.leftAnchor.constraint(equalTo: sliderContainer.leftAnchor),
            slider.bottomAnchor.constraint(equalTo: sliderContainer.bottomAnchor)
        ])
    }
}

// MARK: - Slider delagte / data source
extension OnboardingViewController: HorizontalScrollerViewDelegate,
                                    HorizontalScrollerViewDataSource {
    
    func numberOfViews(in horizontalScrollerView: HorizontalScrollerView) -> Int {
        return slides.count
    }
    
    func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView,
                                didSelectViewAt index: Int, view: UIView) {}
    
    func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView,
                                didScrollViewTo index: Int) {
        _currentIndex.accept(index)
    }
    func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView, viewAt index: Int) -> UIView {
        
        let view = setupSlideView(with: slides[index])
        return view
    }
    
    private func setupSlideView(with slide: OnboardingSlide) -> UIView {
        let slideView = UIView()
        
        let backgroundView = UIImageView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.image = slide.background
        
        let headerImage = UIImageView()
        headerImage.translatesAutoresizingMaskIntoConstraints = false
        headerImage.image = slide.titleImage
        
        let height = (UIScreen.main.bounds.height - 167)
        let width = UIScreen.main.bounds.width
        
        slideView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        slideView.addSubview(backgroundView)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: slideView.topAnchor),
            backgroundView.leftAnchor.constraint(equalTo: slideView.leftAnchor),
            backgroundView.rightAnchor.constraint(equalTo: slideView.rightAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: slideView.bottomAnchor,constant: -70)
        ])
        
        slideView.addSubview(headerImage)

        NSLayoutConstraint.activate([
            headerImage.topAnchor.constraint(equalTo: slideView.topAnchor, constant: 50),
            headerImage.centerXAnchor.constraint(equalTo: slideView.centerXAnchor),
            headerImage.heightAnchor.constraint(equalToConstant: 54)
        ])
        
        return slideView
    }
    
}
