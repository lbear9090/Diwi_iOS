import Foundation
import RxSwift

protocol ClothingItemInfoService {
    func index() -> Observable<[ClothingItem]>
    func show(id: Int) -> Observable<ClothingItem>
    func update(clothingItem: ClothingItem) -> Observable<ClothingItem>
    func delete(id: Int) -> Observable<ApiResponseData>
}
