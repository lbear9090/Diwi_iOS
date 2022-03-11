import ObjectMapper

open class StringToURLTransform: TransformType {
    public typealias Object = URL
    public typealias JSON = String
    
    public init() {}
    
    open func transformFromJSON(_ value: Any?) -> URL? {
        return URL(string: value as! String)
    }
    
    open func transformToJSON(_ value: URL?) -> String? {
        return value?.absoluteString
    }
}

open class StringToFloatTransform: TransformType {
    public typealias Object = Float
    public typealias JSON = String
    
    public init() {}
    
    open func transformFromJSON(_ value: Any?) -> Float? {
        guard let num = value else { return nil }
        // Check is needed because rails will return 0.0 float
        // as 0 in serializer which gets parsed as an Int
        if num is String {
            return Float(num as! String)
        } else {
            return Float(num as! Int)
        }
    }
    
    open func transformToJSON(_ value: Float?) -> String? {
        guard let num = value else { return nil }
        return String(num)
    }
}

open class APIDateTransform: TransformType {
    public typealias Object = Date
    public typealias JSON = String
    
    public init() {}
    
    open func transformFromJSON(_ value: Any?) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        if (value != nil) {
            let date = dateFormatter.date(from: value as! String)
            return date
        } else {
            return nil
        }
    }
    
    open func transformToJSON(_ value: Date?) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss "
        if (value != nil) {
            return dateFormatter.string(from: value!)
        } else {
            return nil
        }
    }
}

open class APIDateTimeTransform: TransformType {
    public typealias Object = Date
    public typealias JSON = String
    
    public init() {}
    
    open func transformFromJSON(_ value: Any?) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if (value != nil) {
            return dateFormatter.date(from: value as! String)
        } else {
            return nil
        }
    }
    
    open func transformToJSON(_ value: Date?) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd h:mm a"
        if (value != nil) {
            return dateFormatter.string(from: value!)
        } else {
            return nil
        }
    }
}
