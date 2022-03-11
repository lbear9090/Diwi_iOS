//
//  GlobalSearchViewModel.swift
//  Diwi
//
//  Created by Dominique Miller on 4/15/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

struct GlobalSearchViewModel {
    private let _results        = BehaviorRelay<[Result]>(value: [])
    private let _errorMessage   = BehaviorRelay<String>(value: "")
    private let _selectedResult = BehaviorRelay<Result>(value: Result())
    
    let query                   = BehaviorRelay<String>(value: "")
    var results: Driver<[Result]> { return _results.asDriver() }
    var errorMessage: Driver<String> { return _errorMessage.asDriver() }
    var selectedResult: Driver<Result> { return _selectedResult.asDriver() }
    
    private let disposeBag = DisposeBag()
    private let searchService: GlobalSearchService
    
    init(searchService: GlobalSearchService) {
        self.searchService = searchService
        queryBinding()
    }
    
    private func queryBinding() {
        query
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance)
            .filter { return $0.count > 0 }
            .subscribe(onNext: { term in
                self.query(term: term)
        }).disposed(by: disposeBag)
    }
    
    private func query(term: String) {
        searchService
            .search(for: term)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                self.createResults(from: response)
            }, onError: { error in
                self._errorMessage.accept(TextContent.Errors.searchError)
            }).disposed(by: disposeBag)
    }
    
    private func createResults(from searchResult: SearchResult) {
        var results: [Result] = []
        
        if let events = searchResult.events {
            for event in events {
                let result = convertToResult(item: event)
                results.append(result)
            }
        }
        
        if let tags = searchResult.tags {
            for tag in tags {
                let result = convertToResult(item: tag)
                results.append(result)
            }
        }
        
        if let looks = searchResult.looks {
            for look in looks {
                let result = convertToResult(item: look)
                results.append(result)
            }
        }
        
        if let items = searchResult.clothingItems {
            for item in items {
                let result = convertToResult(item: item)
                results.append(result)
            }
        }
        
        // Using force unwrapping because title will always have a value
        // in this context
        let sorted: [Result] = results.sorted { $0.title! < $1.title! }
        _results.accept(sorted)
    }
    
    private func convertToResult<T: ModelDefault>(item: T) -> Result {
        var result = Result()
        result.id = item.id
        
        if let event = item as? Event {
            result.modelType = .Events
            result.title = isNilOrEmpty(string: event.name) ? TextContent.Models.event : event.name
            if let date = event.date {
                let now = Date()
                if date > now {
                    result.label = TextContent.SearchLabels.upcomingEvent
                } else if date < now {
                    result.label = TextContent.SearchLabels.pastEvent
                }
            }
        } else if let tag = item as? Tag {
            result.modelType = .Contacts
            result.title = isNilOrEmpty(string: tag.title) ? TextContent.Models.tag : tag.title
            result.label = TextContent.SearchLabels.contact
        } else if let look = item as? Look {
            result.modelType = .Looks
            result.label = TextContent.SearchLabels.look
            result.title = isNilOrEmpty(string: look.title) ? TextContent.Models.look : look.title
        } else if let clothingItem = item as? ClothingItem {
            result.modelType = .ClothingItems
            result.label = TextContent.SearchLabels.item
            result.title = isNilOrEmpty(string: clothingItem.title) ? TextContent.Models.clothingItem : clothingItem.title
        }
        
        guard let title = result.title else { return result }
        result.title = title.capitalized
        
        return result
    }
}

// MARK: - Convienance Methods
extension GlobalSearchViewModel {
    func setSelected(at index: Int) {
        let result = getResult(for: index)
        _selectedResult.accept(result)
    }
    
    func getSelected() -> Result {
        return _selectedResult.value
    }
    
    func getResultsCount() -> Int {
        return _results.value.count
    }
    
    func getResult(for index: Int) -> Result {
        return _results.value[index]
    }
    
    private func isNilOrEmpty(string: String?) -> Bool {
        return (string ?? "").isEmpty
    }
}
