//
//  AddContactsViewModel.swift
//  Diwi
//
//  Created by Dominique Miller on 3/31/20.
//  Copyright © 2020 Trim Agency. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

struct AddContactsViewModel {
    
    let tags                      = BehaviorRelay<[Tag]>(value: [])
    let selectedTags              = BehaviorRelay<[Tag]>(value: [])
    let isLoading                 = BehaviorRelay<Bool>(value: false)
    let success                   = BehaviorRelay<Bool>(value: false)
    let errorStatus               = BehaviorRelay<Int>(value: 0)
    let duplicateTag              = BehaviorRelay<Bool>(value: false)
    let allExistingTags           = BehaviorRelay<[Tag]>(value: [])
    
    private let tagService: TagInfoService
    private let disposebag = DisposeBag()
    
    init(tagService: TagInfoService) {
        self.tagService = tagService
        getTags()
    }
    
    private func getTags() {
        tagService
            .index()
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                self.allExistingTags.accept(response)
            }).disposed(by: disposebag)
    }
    
    func createTags(completion: @escaping (() -> Void)) {
        setSelectedTags()
        guard numberOfTagsToBeCreated() > 0 else {
            completion()
            return
        }
        
        let group = DispatchGroup()
        
        for tag in selectedTags.value {
            if tag.id == nil {
                group.enter()
                tagService
                    .create(tag: tag)
                    .observeOn(MainScheduler.instance)
                    .subscribe(onNext: { response in
                        if let id = response.id {
                            tag.id = id
                        }
                        
                        group.leave()
                    }, onError: { error in
                        let errorObject = error as! ErrorResponseObject
                        self.errorStatus.accept(errorObject.status)
                        group.leave()
                    }).disposed(by: disposebag)
            }
        }
        
        group.notify(queue: .main, execute: {
            completion()
        })
    }
    
    func numberOfTagsToBeCreated() -> Int {
        return selectedTags.value.count
    }
    
    func setSelectedTags() {
        selectedTags.accept(tags.value.filter {$0.selected} )
    }
    
    func updateTagsArray(newName: String) {
        if allExistingTags.value.first(where: {$0.title?.lowercased() == newName.lowercased() }) != nil {
            duplicateTag.accept(true)
        } else {
            createNewTag(with: newName)
            setSelectedTags()
        }
    }
    
    private func sortTagsByTitle(for tags: [Tag]) -> [Tag] {
        return tags.sorted(by: { (a, b) -> Bool in
            a.title! < b.title!
        })
    }
    
    private func createNewTag(with name: String) {
        guard !name.isEmpty else { return }
        
        let newTag = Tag()
        newTag.title = name
        newTag.selected = true
        
        let allTags = tags.value + [newTag]
        let sortedTags = sortTagsByTitle(for: allTags)
        
        tags.accept(sortedTags)
        addToExistingTags(tag: newTag)
    }
    
    private func addToExistingTags(tag: Tag) {
        var tags = allExistingTags.value
        tags.append(tag)
        
        allExistingTags.accept(tags)
    }
    
    func getNumberOfTags() -> Int {
        return tags.value.count
    }
}
