import Foundation
import RxSwift

protocol AutocompleteDelegate {
    func didSelectTag(withId: Int)
    func didStartEditing()
    func didFinishEditing()
}
