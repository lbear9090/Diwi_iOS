//
//	RootClass.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


class NewLook : NSObject, NSCoding{

	var datesWorn : [String]!
	var location : String!
	var note : String!
	var photos : [String] = []
	var tagIds : [Int] = []
	var title : String!
    var tagsIdsToBeDeleted: [Int] = []
    var imageIdsToBeDeleted: [Int] = []
    
    override init() {
        datesWorn = []
        location = ""
        note = ""
        photos = []
        tagIds = []
        title = ""
        tagsIdsToBeDeleted = []
        imageIdsToBeDeleted = []
    }
    

	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: [String:Any]){
		datesWorn = dictionary["dates_worn"] as? [String]
		location = dictionary["location"] as? String
		note = dictionary["note"] as? String
        photos = dictionary["photos"] as? [String] ?? []
        tagIds = dictionary["tag_ids"] as? [Int] ?? []
		title = dictionary["title"] as? String
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
		if datesWorn != nil{
            
            var dates = [String]()
            for date in datesWorn
            {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                let date = dateFormatter.date(from: date) ?? Date()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let updatedDate = dateFormatter.string(from: date)
                dates.append(updatedDate)
            }
			dictionary["dates_worn"] = dates
		}
		if location != nil{
			dictionary["location"] = location
		}
		if note != nil{
			dictionary["note"] = note
		}
        if photos.count > 0{
			dictionary["photos"] = photos
		}
        if tagIds.count > 0{
			dictionary["tag_ids"] = tagIds
		}
		if title != nil{
			dictionary["title"] = title
		}
        if tagsIdsToBeDeleted.count > 0{
            dictionary["look_tag_ids_to_be_deleted"] = tagsIdsToBeDeleted
        }
        if imageIdsToBeDeleted.count > 0{
            dictionary["photo_ids_to_be_deleted"] = imageIdsToBeDeleted
        }
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
         datesWorn = aDecoder.decodeObject(forKey: "dates_worn") as? [String]
         location = aDecoder.decodeObject(forKey: "location") as? String
         note = aDecoder.decodeObject(forKey: "note") as? String
        photos = aDecoder.decodeObject(forKey: "photos") as? [String] ?? []
        tagIds = aDecoder.decodeObject(forKey: "tag_ids") as? [Int] ?? []
         title = aDecoder.decodeObject(forKey: "title") as? String

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    @objc func encode(with aCoder: NSCoder)
	{
		if datesWorn != nil{
			aCoder.encode(datesWorn, forKey: "dates_worn")
		}
		if location != nil{
			aCoder.encode(location, forKey: "location")
		}
		if note != nil{
			aCoder.encode(note, forKey: "note")
		}
        if photos.count > 0{
			aCoder.encode(photos, forKey: "photos")
		}
        if tagIds.count > 0{
			aCoder.encode(tagIds, forKey: "tag_ids")
		}
		if title != nil{
			aCoder.encode(title, forKey: "title")
		}

	}

}
