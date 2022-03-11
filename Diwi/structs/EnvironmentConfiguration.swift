import Foundation
import UIKit

struct EnvironmentConfiguration {
    lazy var environment: Constants =  {
        let configuration = Bundle.main.object(forInfoDictionaryKey: "Configuration") as! String
        return Constants(rawValue: configuration)!
    }()
}
