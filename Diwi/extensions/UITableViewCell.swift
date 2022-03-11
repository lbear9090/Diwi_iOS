import Foundation
import UIKit

extension UITableViewCell {
    public static var reuseIdentifier: String {
        return String(describing: self)
    }
}

