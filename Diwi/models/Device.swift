import ObjectMapper

class Device: Mappable {
    var deviceToken: String?
    var platform: String?
    var id: Int?
    
    init() {
        self.platform = "apn"
    }
    required convenience init?(map: Map) { self.init() }
    
    func mapping(map: Map) {
        deviceToken         <- map["device_token"]
        platform            <- map["platform"]
        id                  <- map["id"]
    }
}

