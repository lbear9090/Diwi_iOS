import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper
import RxSwift

class ClothingItemService: MainRequestService {
    
    func index() -> Observable<[ClothingItem]> {
        return newRequestWithKeyPathArrayResponse(route: ClothingItemRouter.index, keypath: "clothing_items")
    }
    
    func show(id: Int) -> Observable<ClothingItem> {
        return newRequestWithKeyPath(route: ClothingItemRouter.show(id), keypath: "clothing_item")
    }
    
    func create(clothingItem: ClothingItem) -> Observable<ClothingItem> {
        return newRequestWithKeyPath(route: ClothingItemRouter.create(clothingItem), keypath: "clothing_item")
    }
    
    func update(clothingItem: ClothingItem) -> Observable<ClothingItem> {
        return newRequestWithKeyPath(route: ClothingItemRouter.update(clothingItem), keypath: "clothing_item")
    }
    
    func delete(id: Int) -> Observable<ApiResponseData> {
        return newRequestWithKeyPath(route: ClothingItemRouter.delete(id), keypath: "clothing_item")
    }
}

extension ClothingItemService: ClothingItemInfoService {
    
}
