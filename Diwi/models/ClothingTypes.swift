import ObjectMapper
import Foundation

class ClothingTypes: Mappable {
    
    var clothingTypes: [String]?
    
    init() {}
    
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
       clothingTypes        <- map["clothing_types"]
    }
}
