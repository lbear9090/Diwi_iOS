
import Foundation

struct ErrorResponseObject: Error {
    var status: Int
    var data: ApiResponseData?
}
