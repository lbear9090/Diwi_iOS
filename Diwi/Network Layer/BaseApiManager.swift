//
//  BaseApiManager.swift
//  Apple
//
//  Created by Apple on 04/12/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation
import UIKit


/// This Class is the Base API manager which manages the basic request creation,
/// get data call and hit API calls.
internal class BaseAPIManager: NSObject {

    static func getErrorMsg(_ response: Any?) -> String? {
        if let data = response as? [String: Any] {
           return data["errors"] as? String
        }
        return nil
    }
    
    static func getErrorTitleMsg(_ response: Any?) -> String? {
        if let data = response as? [String: Any] {
            if let data = data["errors"] as? [String: Any] {
                if let title = data["title"] as? [String] {
                    if title.count > 0
                    {
                        return title[0]
                    }else
                    {
                        return "has already been taken"
                    }
                }
            }
        }
        return nil
    }
    
    static func getErrorPasswordMsg(_ response: Any?) -> String? {
        if let data = response as? [String: Any] {
            if let title = data["password"] as? [String] {
                if title.count > 0
                {
                    return title[0]
                }else
                {
                    return "has already been taken"
                }
            }
        }
        return nil
    }


    /// This method hit the API call with all the headers and parameters if any.
    ///
    /// - Parameters:
    ///   - apiUrl: API url to be requested
    ///   - apiMethod: Type of request
    ///   - parameters: If any parameters to be send with the request
    ///   - headers: Any headers to be attached with the request
    ///   - completionHandler: gives the response data or error if any
    ///   - result: response data
    ///   - error: error description if any
    internal static func hitAPI(_ apiUrl: String,
                                apiFullUrl: String? = nil,
                                apiMethod: MethodType,
                                parameters: [String: Any]?,
                                headers: [String: String]?,
                                completionHandler: @escaping (_ result: Any?,
                                                              _ error: String?) -> Void) {
        
        var finalData: Any?
        var errorString: String?
        let header = headers
        
        ServiceHelper.request(params: parameters ?? [:], method: apiMethod, apiName: apiUrl,apiURL: apiFullUrl, headers: header) { (result, error, _) in
            if let JSON = result {
                finalData = JSON
            } else if let ERROR = error {
                print("Error: \(ERROR)")
                errorString = ERROR.localizedDescription
            } else {
                errorString = "Unknown error occurred"
            }
            completionHandler(finalData, errorString)
        }
    }


    /// This method hit API without using the common Base url. It uses the full url to hit API rather than only API name.
    ///
    /// - Parameters:
    ///   - apiFullUrl: Full Url to hit API
    ///   - apiMethod: Type of request
    ///   - parameters: If any parameters to be send with the request
    ///   - headers: Any headers to be attached with the request
    ///   - completionHandler: gives the response data or error if any
    ///   - result: response data
    ///   - error: error description if any
    internal static func hitAPI(apiFullUrl: String,
                                apiMethod: MethodType,
                                parameters: [String: Any]?,
                                headers: [String: String]?,
                                completionHandler: @escaping (_ result: Any?,
        _ error: String?) -> Void) {
        //        if (APPDELEGATE.isReachable == false) {
        //            completionHandler(nil, NO_INTERNET_CONNECTION)
        //            return
        //        }
        var finalData: Any?
        var errorString: String?
        let header = headers

        ServiceHelper.request(params: parameters ?? [:], method: apiMethod, apiName: "", apiURL: apiFullUrl, headers: header) { (result, error, _) in
            if let JSON = result {
                //                print("JSON: \(JSON)")
                finalData = JSON
            } else if let ERROR = error {
                print("Error: \(ERROR)")
                errorString = ERROR.localizedDescription
            } else {
                errorString = "Unknown error occurred"
            }
            completionHandler(finalData, errorString)
        }
    }
    
    /// To upload the image
  internal static  func startUploadingImage(apiFullUrl: String,
                             apiMethod: MethodType,
                             parameters: [String: Any]?,
                             headers: [String: String]?,
                             completionHandler: @escaping (_ result: Any?,
        _ error: String?) -> Void) {
        let request: URLRequest
        let image = parameters?["image"] as? UIImage
        let filename = parameters?["fileName"] as? String
        let header = headers
        var errorString: String?
        
        do {
            request = try ServiceHelper.createRequest(url:apiFullUrl , headerContent: header ?? [:], fileName: filename ?? "", httpMethod: apiMethod, image: image ?? UIImage(), imageName: "test")
        } catch {
            return
        }
        
        

      //  let header = ["app_api_key":"90745E94FGETH3LCDA225KDF169G7", "session_token":"a32769a2250a153768d24662d61c461d"]
//        do {
//            request = try createRequest(url: "https://app.pawmoji.app/webservices/v1/pets/uploadPetPhoto", headerContent: header, fileName: "uploaded_photo", httpMethod: "POST", image: image)
//        } catch {
//            print(error)
//            return
//        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                // handle error here
                if let error = error {
                    errorString = error.localizedDescription
                }
                completionHandler(nil,errorString)
                return
            }
            do {
                let response = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject]
                completionHandler(response,nil)
            } catch {
                    errorString = "Unknown error occurred"
                completionHandler(nil,errorString)
            }

        }
        task.resume()
    }
}
    
