//
//	Look.swift
//
//	Create by Nitin Agnihotri on 26/1/2021
//	Copyright © 2021 Mobiloitte. All rights reserved.
//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


class FriendModel : NSObject, NSCoding {

	var createdAt : String!
	var datesWorn : [String]!
	var id : Int!
	var image : String!
	var thumbnail : String!
	var title : String!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: NSDictionary){
		createdAt = dictionary["created_at"] as? String
		datesWorn = dictionary["dates_worn"] as? [String]
		id = dictionary["id"] as? Int
		image = dictionary["image"] as? String
		thumbnail = dictionary["thumbnail"] as? String
		title = dictionary["title"] as? String
	}

	/**
	 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> NSDictionary
	{
        let dictionary = NSMutableDictionary()
		if createdAt != nil{
			dictionary["created_at"] = createdAt
		}
		if datesWorn != nil{
			dictionary["dates_worn"] = datesWorn
		}
		if id != nil{
			dictionary["id"] = id
		}
		if image != nil{
			dictionary["image"] = image
		}
		if thumbnail != nil{
			dictionary["thumbnail"] = thumbnail
		}
		if title != nil{
			dictionary["title"] = title
		}
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
        createdAt = aDecoder.decodeObject(forKey: "created_at") as? String
        datesWorn = aDecoder.decodeObject(forKey: "dates_worn") as? [String]
        id = aDecoder.decodeObject(forKey: "id") as? Int
        image = aDecoder.decodeObject(forKey: "image") as? String
        thumbnail = aDecoder.decodeObject(forKey: "thumbnail") as? String
        title = aDecoder.decodeObject(forKey: "title") as? String

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    func encode(with aCoder: NSCoder) {
		if createdAt != nil{
            aCoder.encode(createdAt, forKey: "created_at")
		}
		if datesWorn != nil{
            aCoder.encode(datesWorn, forKey: "dates_worn")
		}
		if id != nil{
            aCoder.encode(id, forKey: "id")
		}
		if image != nil{
            aCoder.encode(image, forKey: "image")
		}
		if thumbnail != nil{
            aCoder.encode(thumbnail, forKey: "thumbnail")
		}
		if title != nil{
            aCoder.encode(title, forKey: "title")
		}

	}

}
