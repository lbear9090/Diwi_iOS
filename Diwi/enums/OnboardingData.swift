//
//  OnboardingData.swift
//  Diwi
//
//  Created by Dominique Miller on 1/28/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import UIKit

enum OnboardingData {
    case What, When, Where, Who
    
    var backgroundImage: UIImage {
        switch self {
        case .What: return UIImage.Diwi.whatBackground
        case .When: return UIImage.Diwi.whenBackground
        case .Where: return UIImage.Diwi.whereBackground
        case .Who: return UIImage.Diwi.whoBackground
        }
    }
    
    var titleImage: UIImage {
        switch self {
        case .What: return UIImage.Diwi.whatOnboarding
        case .When: return UIImage.Diwi.whenOnboarding
        case .Where: return UIImage.Diwi.whereOnboarding
        case .Who: return UIImage.Diwi.whoOnboarding
        }
    }
        
    var text: String {
        switch self {
        case .What: return TextContent.Onboarding.whatText
        case .When: return TextContent.Onboarding.whenText
        case .Where: return TextContent.Onboarding.whereText
        case .Who: return TextContent.Onboarding.whoText
        }
    }
        
    var indicatorColor: UIColor {
        switch self {
        case .What: return UIColor.Diwi.barney
        case .When: return UIColor.Diwi.yellow
        case .Where: return UIColor.Diwi.azure
        case .Who: return .white
        }
    }
}
