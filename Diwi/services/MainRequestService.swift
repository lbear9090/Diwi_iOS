
import Foundation
import ObjectMapper
import RxSwift
import Alamofire

class MainRequestService {
    var errorData: ApiResponseData?
    
    func newRequestWithKeyPath<T: Mappable> (route: URLRequestConvertible, keypath: String) -> Observable<T> {
        return Observable<T>.create { observer in
            let request = APIClient.session
                .request(route)
                .validate()
                .responseObject(keyPath: keypath) { (response: DataResponse<T>) in
                    switch response.result {
                    case .success(let value):
                        observer.onNext(value)
                        observer.onCompleted()
                    case .failure(_):
                        if let data = response.data {
                            let decoder = JSONDecoder()
                            do {
                                self.errorData =  try decoder.decode(ApiResponseData.self, from: data)
                                let errorObject = ErrorResponseObject(status: response.response!.statusCode, data: self.errorData)
                                observer.onError(errorObject)
                            } catch {
                                let errorObject = ErrorResponseObject(status: 500, data: nil)
                                observer.onError(errorObject)
                            }
                            
                        }
                    }
            }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    func newRequestWithKeyPathArrayResponse<T: Mappable> (route: URLRequestConvertible, keypath: String) -> Observable<[T]> {
        return Observable<[T]>.create { observer in
            let request = APIClient.session
                .request(route)
                .validate()
                .responseArray(keyPath: keypath) { (response: DataResponse<[T]>) in
                    switch response.result {
                    case .success(let value):
                        observer.onNext(value)
                        observer.onCompleted()
                    case .failure(_):
                        if let data = response.data {
                            let decoder = JSONDecoder()
                            do {
                                self.errorData =  try decoder.decode(ApiResponseData.self, from: data)
                                let errorObject = ErrorResponseObject(status: response.response!.statusCode, data: self.errorData)
                                observer.onError(errorObject)
                            } catch {
                                let errorObject = ErrorResponseObject(status: 500, data: nil)
                                observer.onError(errorObject)
                            }
                            
                        }
                    }
                    
            }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    func newRequestWithoutKeyPath<T: Mappable> (route: URLRequestConvertible) -> Observable<T> {
        return Observable<T>.create { observer in
            let request = APIClient.session
                .request(route)
                .validate()
                .responseObject { (response: DataResponse<T>) in
                    switch response.result {
                    case .success(let value):
                        observer.onNext(value)
                        observer.onCompleted()
                    case .failure(_):
                        if let data = response.data {
                            let decoder = JSONDecoder()
                            do {
                                self.errorData =  try decoder.decode(ApiResponseData.self, from: data)
                                let errorObject = ErrorResponseObject(status: response.response!.statusCode, data: self.errorData)
                                observer.onError(errorObject)
                            } catch {
                               let errorObject = ErrorResponseObject(status: 500, data: nil)

                               observer.onError(errorObject)
                            }
                            
                        }
                    }
                    
            }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
