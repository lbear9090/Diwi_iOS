import UIKit

extension UIDevice {
    var hasNotch: Bool {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }

    static var deviceModel: String {
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 1136:
                return "iPhone 5 or 5S or 5C"
            case 1334:
                return "iPhone 6/6S/7/8"
            case 2208:
                return "iPhone 6+/6S+/7+/8+"
            case 2436:
                return "iPhone X"
            case 1792:
                return "iPhone XR"
            case 2688:
                return "iPhone XSMax"
            default:
                return "unknown"
            }
        }
        return "unknown"
    }

}
