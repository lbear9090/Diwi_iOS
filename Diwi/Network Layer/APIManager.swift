//
//  APIManager.swift
//
//
//  Created by Apple on 25/03/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import UIKit

class APIManager: BaseAPIManager {
    
    /// This method login user.
    ///
    /// - Parameters:
    ///   - parameters: paramters to login user
    ///   - comp: call back when user is authenticated and loggedin or error if any.
    static func addNewLook(parameters: [String: Any], comp: @escaping (_ sucessData: Bool?, _ error: String?) -> Void) {
        if let token = KeychainService().getUserJWT() {
            hitAPI(ApiURL.looks, apiMethod: .post, parameters: parameters, headers: ["Authorization":token]) { (result, error) in
                if let result = result as? [String: Any],
                   let look = result[ApiKeys.look] as? [String: Any] {
                    comp(true, error)
                } else if error == nil {
                    comp(nil, getErrorMsg(result))
                } else {
                    comp(nil, error)
                }
            }
        }
    }
    
    static func editLook(lookID: String, parameters: [String: Any], comp: @escaping (_ sucessData: Bool?, _ error: String?) -> Void) {
        if let token = KeychainService().getUserJWT() {
            let url = ApiURL.looks + "/\(lookID)"
            hitAPI(url, apiMethod: .patch, parameters: parameters, headers: ["Authorization":token]) { (result, error) in
                if let result = result as? [String: Any],
                   let look = result[ApiKeys.look] as? [String: Any] {
                    comp(true, error)
                } else if error == nil {
                    comp(nil, getErrorMsg(result))
                } else {
                    comp(nil, error)
                }
            }
        }
    }
    
    
    static func addFriend(parameters: [String: Any], comp: @escaping (_ sucessData: Bool?, _ error: String?) -> Void) {
        hitAPI(ApiURL.tags, apiMethod: .post, parameters: parameters, headers: [:]) { (result, error) in
            if let result = result as? [String: Any],
               let look = result[ApiKeys.tag] as? [String: Any] {
                comp(true, error)
            } else if error == nil {
                comp(nil, getErrorTitleMsg(result))
            } else {
                comp(nil, error)
            }
        }
    }
    
    static func deleteFriend(url:String, comp: @escaping (_ sucessData: Bool?, _ error: String?) -> Void) {
        if let token = KeychainService().getUserJWT() {
            hitAPI(url, apiMethod: .delete, parameters: nil, headers: ["Authorization":token]) { (result, error) in
                if let result = result as? [String: Any],
                   let look = result[ApiKeys.tag] as? [String: Any] {
                    comp(true, error)
                } else if error == nil {
                    comp(nil, getErrorMsg(result))
                } else {
                    comp(nil, error)
                }
            }
        } else {
            comp(nil,"Auth token not found!")
        }
        
    }
    
    static func fetchTags(comp: @escaping (_ tags: [FriendModel]?, _ error: String?, _ success: Bool?) -> Void) {
        hitAPI(ApiURL.tags, apiMethod: .get, parameters: nil, headers: [:]) { (result, error) in
            if let result = result as? [String: Any]
            {
                var tags = [FriendModel]()
                if let looksArray = result[ApiKeys.tags] as? [NSDictionary]{
                    for dic in looksArray{
                        let value = FriendModel(fromDictionary: dic)
                        tags.append(value)
                    }
                }
                comp(tags, "", true)
            } else if error == nil {
                comp(nil, getErrorMsg(result), false)
            } else {
                comp(nil, error, false)
            }
        }
    }
    
    static func fetchLooks(comp: @escaping (_ looksArray:LooksModelRoot?,_ error: String?) -> Void) {
        if let token = KeychainService().getUserJWT() {
            debugPrint("token----------\(token)")
            hitAPI(ApiURL.fetchLooks, apiMethod: .get, parameters: nil, headers: ["Authorization":token]) { (result, error) in
                if error == nil {
                    if let results = result as? [String: Any] {
                        let lookRootvm = LooksModelRoot(fromDictionary: results as NSDictionary)
                        comp(lookRootvm,nil)
                    }
                } else {
                    comp(nil,error)
                }
            }
        } else {
            comp(nil,"Auth token not found!")
        }
    }
    
    static func fetchFriendsLooks(parameters: [String: Any],comp: @escaping (_ looksArray:[LookModel]?,_ error: String?) -> Void) {
        if let token = KeychainService().getUserJWT() {
            let url = ApiURL.globalSearch
            hitAPI(url, apiMethod: .post, parameters: parameters, headers: ["Authorization":token]) { (result, error) in
                if error == nil {
                    if let results = result as? [String: Any] {
                        if let resultDict = results["results"] as? [String: Any] {
                            var looks = [LookModel]()
                            if let looksArray = resultDict["tags"] as? [NSDictionary]{
                                for dic in looksArray{
                                    let value = LookModel(fromDictionary: dic)
                                    looks.append(value)
                                }
                            }
                            comp(looks,nil)
                        }
                    }
                } else {
                    comp(nil,error)
                }
            }
        } else {
            comp(nil,"Auth token not found!")
        }
    }
    
    static func globalSearch(parameters: [String: Any],comp: @escaping (_ looksArray:[String: Any]?,_ error: String?) -> Void) {
        if let token = KeychainService().getUserJWT() {
            let url = ApiURL.globalSearch
            hitAPI(url, apiMethod: .post, parameters: parameters, headers: ["Authorization":token]) { (result, error) in
                if error == nil {
                    if let results = result as? [String: Any] {
                        if let resultDict = results["results"] as? [String: Any] {
                            comp(resultDict,nil)
                        }
                    }
                } else {
                    comp(nil,error)
                }
            }
        } else {
            comp(nil,"Auth token not found!")
        }
    }
    
    static func fetchLookDetail(url:String,comp: @escaping (_ lookDetail:NewLook?, _ look:Look?, _ error: String?) -> Void) {
        if let token = KeychainService().getUserJWT() {
            hitAPI(url, apiMethod: .get, parameters: nil, headers: ["Authorization":token]) { (result, error) in
                if error == nil {
                    if let results = result as? [String: Any] {
                        if let lookDict = results["look"] as?  [String : Any]{
                            let value = NewLook(fromDictionary: lookDict)
                            if let data = Look(JSON: lookDict) {
                                print("===============\n\(data)")
                                comp(value,data, nil)
                            }
                        }
                    }
                } else {
                    comp(nil,nil,error)
                }
            }
        } else {
            comp(nil,nil,"Auth token not found!")
        }
    }
    
    static func deleteLook(url:String, comp: @escaping (_ sucessData: Bool?, _ error: String?) -> Void) {
        if let token = KeychainService().getUserJWT() {
            hitAPI(url, apiMethod: .delete, parameters: nil, headers: ["Authorization":token]) { (result, error) in
                if let result = result as? [String: Any],
                   let message = result[ApiKeys.look] as? [String: Any] {
                    comp(true, message["message"] as? String ?? "Deleted successfully")
                } else if error == nil {
                    comp(nil, getErrorMsg(result))
                } else {
                    comp(nil, error)
                }
            }
        } else {
            comp(nil,"Auth token not found!")
        }
        
    }
    
    static func saveUser(url:String, parameters: [String:Any],comp: @escaping (_ sucessData: Bool?, _ error: String?) -> Void) {
        hitAPI(ApiURL.user,apiFullUrl:url, apiMethod: .patch, parameters: parameters, headers: [:]) { (result, error) in
            if let result = result as? [String: Any] {
                if let error = result["error"] {
                    comp(false, getErrorPasswordMsg(error))
                } else {
                    comp(true, nil)
                }
            } else if error == nil {
                comp(nil, getErrorMsg(result))
            } else {
                comp(nil, error)
            }
        }
    }
    
    //    static func fetchProfiles(comp: @escaping (_ tags: User?, _ error: String?, _ success: Bool?) -> Void) {
    //        hitAPI(ApiURL.user, apiMethod: .get, parameters: nil, headers: [:]) { (result, error) in
    //            if let result = result as? [String: Any]
    //            {
    //                var tags = [FriendModel]()
    //                if let looksArray = result[ApiKeys.tags] as? [NSDictionary]{
    //                    for dic in looksArray{
    //                        let value = User(fromDictionary: dic)
    //                        tags.append(value)
    //                    }
    //                }
    //                comp(tags, "", true)
    //            } else if error == nil {
    //                comp(nil, getErrorMsg(result), false)
    //            } else {
    //                comp(nil, error, false)
    //            }
    //        }
    //    }
}

