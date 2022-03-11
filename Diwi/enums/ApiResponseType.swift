
import Foundation

// add additional response types that
// the API could return, Usually found
// in exceptions.rb in API
enum ApiResponseType: Error {
    case ok
    case created
    case notFound
    case badRequest
    case unauthorized
    case internalServerError
    case recordInvalid
    case unknown
}
