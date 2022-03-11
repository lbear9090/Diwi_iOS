import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import RxSwift

class DeviceService: MainRequestService {
    
    func create(with device: Device) -> Observable<Device> {
        return newRequestWithKeyPath(route: DeviceRouter.create(device),
                                     keypath: "device")
    }
    
    func update(with device: Device) -> Observable<Device> {
        return newRequestWithKeyPath(route: DeviceRouter.update(device),
                                     keypath: "device")
    }
}
