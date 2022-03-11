//
//  NavigationCoordinator.swift
//  Diwi
//
//  Created by Shane Work on 11/10/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit

class NavigationCoordinator: Coordinator {
    var childCoordinators: [Coordinator]?
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        
    }
    
}
