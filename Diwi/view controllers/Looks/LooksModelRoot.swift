//
//	RootClass.swift
//
//	Create by Nitin Agnihotri on 26/1/2021
//	Copyright © 2021 Mobiloitte. All rights reserved.
//	Model file Generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation


class LooksModelRoot : NSObject, NSCoding{
    
    func encode(with coder: NSCoder) {
        if looks != nil{
            coder.encode(looks, forKey: "looks")
        }
    }
    

	var looks : [LookModel]!


	/**
	 * Instantiate the instance using the passed dictionary values to set the properties values
	 */
	init(fromDictionary dictionary: NSDictionary){
		looks = [LookModel]()
		if let looksArray = dictionary["looks"] as? [NSDictionary]{
			for dic in looksArray{
				let value = LookModel(fromDictionary: dic)
				looks.append(value)
			}
		}
	}

	/**
	 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> NSDictionary
	{
		var dictionary = NSMutableDictionary()
		if looks != nil{
			var dictionaryElements = [NSDictionary]()
			for looksElement in looks {
				dictionaryElements.append(looksElement.toDictionary())
			}
			dictionary["looks"] = dictionaryElements
		}
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
        looks = aDecoder.decodeObject(forKey: "looks") as? [LookModel]

	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
//    @objc func encodeWithCoder(aCoder: NSCoder)
//	{
//
//	}

}
