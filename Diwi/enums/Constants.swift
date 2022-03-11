import Foundation

enum Constants: String {
    case Development = "Development"
    case Staging = "Staging"
    case Release = "Release"
    
    var baseURL: String {
        switch self {
            // case .Development: return "https://diwi-api-staging.herokuapp.com"
            case .Development: return "https://diwi-api.ngrok.io"
            case .Staging: return "https://diwi-api-staging.herokuapp.com"
            case .Release: return "https://diwi-api.herokuapp.com"
        }
    }
}

class ApiURL {
    static let looks = "/api/v1/looks"
    static let tags = "/api/v1/tags"
    static let user = "/api/v1/users"
    static let fetchLooks = "/api/v1/looks"
    static let globalSearch = "/api/v1/global_search"
}

class ApiKeys {
    static let look = "look"
    static let tags = "tags"
    static let tag = "tag"
}

class AlertMsg {
   static let selectImg = "Please add atleast one image"
    static let addLocation = "Please add location"
    static let addTitle = "Please add title"
    static let selectdate = "Please select date"
    static let errorCreateLook = "Unable to save the data, Please try agin later"
    static let lookImageExceedMessage = "You can't add more then 10 images for a single look."
}

func delay(delay: Double, closure:@escaping () -> Void) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}


//var addfriends = [String]()
let friendsAddedString = "friendsAdded"
let lookAddedString = "lookAdded"
