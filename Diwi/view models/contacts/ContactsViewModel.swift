//
//  ContactsViewModel.swift
//  Diwi
//
//  Created by Dominique Miller on 3/26/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

struct ContactsViewModel {
    private let _tags                = BehaviorRelay<[Tag]>(value: [])
    private let _alphabetArray       = BehaviorRelay<[String]>(value: TextContent.Data.alphabet)
    private let _errorMessage        = BehaviorRelay<String>(value: "")
    private let _isLoading           = BehaviorRelay<Bool>(value: false)
    private let _indexPathToScrollTo = BehaviorRelay<IndexPath>(value: IndexPath(row: 0, section: 0))
    
    var contacts: Driver<[Tag]> { return _tags.asDriver() }
    var letters: Driver<[String]> { return _alphabetArray.asDriver() }
    var errorMessage: Driver<String> { return _errorMessage.asDriver() }
    var indexPathToScrollTo: Driver<IndexPath> { return _indexPathToScrollTo.asDriver() }
    var isLoading: Driver<Bool> { return _isLoading.asDriver() }
    var alphabetArray: [String] {
        return _alphabetArray.value
    }
    
    private var itemsToBeDeleted: [Int] = []
    private let disposebag = DisposeBag()
    private let tagService: TagInfoService
    
    init(tagService: TagInfoService) {
        self.tagService = tagService
        getTags()
    }
    
    mutating func resetTags() {
        // don't retrieve more tags if already doing so
        if !_isLoading.value {
            getTags()
        }
    }
    
    private func getTags() {
        _isLoading.accept(true)
        tagService
            .index()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                self._isLoading.accept(false)
                self.formatTags(for: response)
            }, onError: { error in
                self._isLoading.accept(false)
                self._errorMessage.accept(TextContent.Errors.tagIndexError)
            }).disposed(by: disposebag)
    }
    
    private func formatTags(for tags: [Tag]) {
        for tag in tags {
            if let name = tag.title {
                tag.title = formatName(input: name)
            }
        }
        
        var sorted = tags
        sorted.sort { $0.title! < $1.title! }
        
        _tags.accept(sorted)
    }
    
    // capitalize persons name
    private func formatName(input: String) -> String {
        let words = input.components(separatedBy: " ")
        var capitalizedWords: [String] = []
        
        for word in words {
            let cap = word.capitalized
            capitalizedWords.append(cap)
        }
        
        return capitalizedWords.joined(separator: " ")
    }
    
    func getContact(with index: Int) -> Tag {
        return _tags.value[index]
    }
    
    func scrollToIndexValue(for index: Int) {
        let letter = alphabetArray[index].capitalized
        let tagNames = _tags.value.map { $0.title! }
        if let matchedIndex = tagNames.firstIndex(where: { $0.prefix(1) == letter }) {
            let indexPath = IndexPath(row: matchedIndex, section: 0)
            self._indexPathToScrollTo.accept(indexPath)
        }
    }
    
    func numberOfContacts() -> Int {
        return _tags.value.count
    }
}

// MARK: - Removing tags
extension ContactsViewModel {
    mutating func addItemToBeDeleted(id: Int) {
        itemsToBeDeleted.append(id)
    }
    
    mutating func removeItemToBeDeleted(id: Int) {
        if let index = itemsToBeDeleted.firstIndex(of: id) {
            itemsToBeDeleted.remove(at: index)
        }
    }
    
    func getItemsToBeDeleted() -> [Int] {
        return itemsToBeDeleted
    }
}
