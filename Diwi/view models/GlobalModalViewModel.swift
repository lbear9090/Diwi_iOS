//
//  SaveItemModalViewModel.swift
//  Diwi
//
//  Created by Dominique Miller on 12/4/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

struct GlobalModalViewModel {
    let leftButtonText     = BehaviorRelay<String>(value: "")
    let rightButtonText    = BehaviorRelay<String>(value: "")
    let headerText         = BehaviorRelay<String>(value: "")
    let cheersTextBoxText  = BehaviorRelay<String>(value: "")
    let itemImageUrl       = BehaviorRelay<String>(value: "")
    let isLoading          = BehaviorRelay<Bool>(value: false)
    let success            = BehaviorRelay<Bool>(value: false)
    let errorStatus        = BehaviorRelay<Int>(value: 0)
    let errorMsg           = BehaviorRelay<String>(value: "")
    let cheersIcon         = BehaviorRelay<UIImage>(value: UIImage.Diwi.cheersIcon)
    private let workflow   = BehaviorRelay<Workflow>(value: .saveItemToEvent)
    
    
    private let eventClothingItemService: EventClothingItemService
    private let clothingItemService: ClothingItemInfoService
    private let lookService: LookInfoService
    private let eventService: EventInfoService
    private let tagService: TagInfoService
    private let disposebag = DisposeBag()
    private let clothingItem: ClothingItem
    private let event: Event
    private let idsToRemove: [Int]
    
    init(workflow: Workflow,
         event: Event,
         clothingItem: ClothingItem,
         eventClothingItemService: EventClothingItemService,
         eventService: EventInfoService,
         tagService: TagInfoService,
         clothingItemService: ClothingItemInfoService,
         lookService: LookInfoService,
         idsToRemove: [Int]) {
        self.workflow.accept(workflow)
        self.eventClothingItemService = eventClothingItemService
        self.clothingItem = clothingItem
        self.event = event
        self.eventService = eventService
        self.tagService = tagService
        self.idsToRemove = idsToRemove
        self.clothingItemService = clothingItemService
        self.lookService = lookService
        setup(with: workflow)
    }
    
    private func setup(with workflow: Workflow) {
        if let imageUrl = clothingItem.image {
            itemImageUrl.accept(imageUrl)
        }
        
        leftButtonText.accept(workflow.globalModalLeftBtnText)
        rightButtonText.accept(workflow.globalModalRightBtnText)
        headerText.accept(workflow.globalModalHeaderText)
        
        if workflow == .saveItemToEvent {
            headerText.accept(saveItemText())
        }
        
        cheersIcon.accept(workflow.globalModalCheersIcon)
        cheersTextBoxText.accept(workflow.globalModalCheersBoxText)
    }
    
    func createEventItem() {
        if workflow.value == .saveItemToEvent {
            saveToApi()
        }
    }
    
    private func saveItemText() -> String {
        guard let dateString = event.datePretty() else {
            return TextContent.Labels.defaultSaveItemToEvent }
        
        let prefix = TextContent.Labels.saveThisItemToAnEventOn
        
        return prefix + dateString + "."
    }
    
    func currentWorkflow(is workflow: Workflow) -> Bool {
        return workflow == self.workflow.value
    }
    
    func getCurrentWorkflow() -> Workflow {
        return workflow.value
    }
    
    func handleRightButtonPress() {
        switch workflow.value {
        case .saveItemToEvent:
            createEventItem()
        case .removeEventFromCalendar:
            deleteEvent()
        case .removeContacts:
            deleteContacts()
        case .removeItems:
            deleteItems()
        case .removeLooks:
            deleteLooks()
        default:
            print("workflow not supported yet")
        }
    }
}

// MARK: - API Methods
extension GlobalModalViewModel {
    private func buildEventClothingItem() -> EventClothingItem {
        let eventClothingItem = EventClothingItem()
        eventClothingItem.eventId = event.id
        eventClothingItem.clothingItemId = clothingItem.id
        
        return eventClothingItem
    }
    
    private func saveToApi() {
        guard event.id != nil else {
            self.errorMsg.accept(TextContent.Errors.savingClothingItem)
            return }
        
        let eventClothingItem = buildEventClothingItem()
        
        isLoading.accept(true)
        eventClothingItemService
            .create(eventClothingItem: eventClothingItem)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                self.isLoading.accept(false)
                self.success.accept(true)
            }, onError: { error in
                self.isLoading.accept(false)
                self.errorMsg.accept(TextContent.Errors.savingClothingItem)
            }).disposed(by: disposebag)
    }
    
    func deleteEvent() {
        guard let id = event.id else {
            self.errorMsg.accept(TextContent.Errors.deletingEvent)
            return }
        
        isLoading.accept(true)
        
        eventService.delete(id: id)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { response in
                self.isLoading.accept(false)
                self.success.accept(true)
                
            }, onError: { error in
                self.isLoading.accept(false)
                guard let errorObject = error as? ErrorResponseObject else { return }
                self.errorStatus.accept(errorObject.status)
            }).disposed(by: disposebag)
    }
    
    private func deleteContacts() {
        isLoading.accept(true)
        for (index, id) in idsToRemove.enumerated() {
            tagService.delete(id: id)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { response in
                    if (index + 1) == self.idsToRemove.count {
                       self.isLoading.accept(false)
                        self.success.accept(true)
                    }
                }, onError: { error in
                    self.isLoading.accept(false)
                    guard let errorObject = error as? ErrorResponseObject else { return }
                    self.errorStatus.accept(errorObject.status)
                }).disposed(by: disposebag)
        }
    }
    
    private func deleteItems() {
        for (index, id) in idsToRemove.enumerated() {
            isLoading.accept(true)
            clothingItemService.delete(id: id)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { response in
                    if (index + 1) == self.idsToRemove.count {
                        self.isLoading.accept(false)
                        self.success.accept(true)
                    }
                }, onError: { error in
                    self.isLoading.accept(false)
                    guard let errorObject = error as? ErrorResponseObject else { return }
                    self.errorStatus.accept(errorObject.status)
                }).disposed(by: disposebag)
        }
    }
    
    private func deleteLooks() {
        for (index, id) in idsToRemove.enumerated() {
            isLoading.accept(true)
            lookService.delete(id: id)
                .observeOn(MainScheduler.instance)
                .subscribe(onNext: { response in
                    if (index + 1) == self.idsToRemove.count {
                        self.isLoading.accept(false)
                        self.success.accept(true)
                    }
                }, onError: { error in
                    self.isLoading.accept(false)
                    guard let errorObject = error as? ErrorResponseObject else { return }
                    self.errorStatus.accept(errorObject.status)
                }).disposed(by: disposebag)
        }
    }
    
}
