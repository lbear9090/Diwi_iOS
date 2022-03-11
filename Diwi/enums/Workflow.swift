//
//  Workflow.swift
//  Diwi
//
//  Created by Dominique Miller on 11/21/19.
//  Copyright © 2019 Trim Agency. All rights reserved.
//

import UIKit

enum Workflow {
    case addEvent,
         addEvents,
         addEventsToLook,
         addEventsToItem,
         addEventOrDateToClosetItem,
         addClosetItem,
         addClosetItemToEvent,
         addClosetItemToLook,
         addClosetLook,
         addDatesToFriend,
         addDatesToLook,
         addDatesToItem,
         addLooksToItem,
         addLooksToNewItem,
         addItemsToNewLook,
         addToEvent,
         addToCalendar,
         calendarIndex,
         closetIndex,
         defaultWorkflow,
         editEvent,
         editFriend,
         editLook,
         eventsIndex,
         retrieveEventInfo,
         noEventScheduledOnDay,
         removeEventFromCalendar,
         removeContacts,
         removeItems,
         removeLooks,
         saveItemToEvent
    
    // MARK: - UICollectionView Cells
    var calendarCellHighLightColor: UIColor {
        switch self {
        case .addDatesToFriend:
            return UIColor.Diwi.azureFaded
        case .addDatesToItem:
            return UIColor.Diwi.azureFaded
        case .addDatesToLook:
            return UIColor.Diwi.azureFaded
        case .calendarIndex:
            return UIColor.Diwi.yellowFaded
        default:
            return UIColor.Diwi.yellowFaded
        }
    }
}

// MARK: - Global Modal
extension Workflow {
    var globalModalLeftBtnText: String {
        switch self {
        case .addEventOrDateToClosetItem:
            return TextContent.Buttons.cancel
        default:
            return TextContent.Buttons.cancel
        }
    }
    
    var globalModalRightBtnText: String {
        switch self {
        case .addEventOrDateToClosetItem:
            return TextContent.Buttons.addToCalendar
        case .saveItemToEvent:
            return TextContent.Buttons.saveItemToEvent
        case .noEventScheduledOnDay:
            return TextContent.Buttons.createEvent
        case .removeEventFromCalendar:
            return TextContent.Labels.removeEvent
        case .removeContacts:
            return TextContent.Labels.removeFriends
        case .removeItems:
            return TextContent.Buttons.removeItems
        case .removeLooks:
            return TextContent.Buttons.removeLooks
        default:
            return ""
        }
    }
    
    var globalModalHeaderText: String {
        switch self {
        case .addEventOrDateToClosetItem:
            return TextContent.Labels.itemSaved
        default:
            return ""
        }
    }
    
    var globalModalCheersIcon: UIImage {
        switch self {
        case .addEventOrDateToClosetItem:
            return UIImage.Diwi.cheersIcon
        case .saveItemToEvent:
            return UIImage.Diwi.cheersIcon
        case .noEventScheduledOnDay:
            return UIImage.Diwi.cheersIcon
        case .removeEventFromCalendar:
            return UIImage.Diwi.cheersIcon
        case .removeContacts:
            return UIImage.Diwi.contactsLarge
        case .removeItems:
            return UIImage.Diwi.hangerLarge
        case .removeLooks:
            return UIImage.Diwi.hangerLarge
        default:
            return UIImage.Diwi.cheersIcon
        }
    }
    
    var globalModalCheersBoxText: String {
        switch self {
        case .noEventScheduledOnDay:
            return TextContent.Labels.noEventScheduledOnDay
        case .removeEventFromCalendar:
            return TextContent.Labels.removeEventFromCalendar
        case .removeContacts:
            return TextContent.Labels.removeFriendsInfo
        case .removeItems:
            return TextContent.Labels.removeClothingItemsFromCloset
        case .removeLooks:
            return TextContent.Labels.removeLooksFromCloset
        default:
            return ""
        }
    }
}

// MARK: - ClosetView
extension Workflow {
    var closetViewNavTitle: String {
        switch self {
        case .editFriend:
            return TextContent.Labels.addItemsWithFriend
        case .editLook:
            return TextContent.Labels.addItemsToLook
        case .removeLooks:
            return TextContent.Labels.removeLooks
        case .addLooksToItem:
            return TextContent.Labels.addLooksToItem
        default:
            return TextContent.Labels.closet
        }
    }
    
    var closetViewAddItemsBtnText: String {
        switch self {
        case .editFriend:
            return TextContent.Buttons.saveItemsWithFriend
        case .editLook:
            return TextContent.Buttons.saveItemsToLook
        case .addLooksToItem:
            return TextContent.Buttons.saveLooksToItem
        default:
            return TextContent.Buttons.saveItemsWithFriend
        }
    }
    
    var closetItemsRemoveBtnText:  String {
        switch self {
        case .removeItems:
            return TextContent.Labels.removeItemFromCloset
        case .removeLooks:
            return TextContent.Labels.removeLookFromCloset
        default:
            return TextContent.Buttons.saveItemsWithFriend
        }
    }
}

//MARK: - Events View
extension Workflow {
    var eventsViewNavTitle: String {
        switch self {
        case .addEvents:
            return TextContent.Labels.addEventsWithFriend
        case .addEventsToLook:
            return TextContent.Labels.addEventToLook
        default:
            return TextContent.Labels.addEventToItem
        }
    }
    
    var eventsViewSaveBtnText: String {
        switch self {
        case .addEvents:
            return TextContent.Buttons.saveEventsWithFriend
        case .addEventsToLook:
            return TextContent.Buttons.saveEventsToLook
        default:
            return TextContent.Buttons.saveEventsToItem
        }
    }
}

// MARK: - Choose New Date
extension Workflow {
    var chooseNewDateNavTitle:  String {
        switch self {
        case .addDatesToFriend:
            return TextContent.Labels.addDateToFriend
        case .addDatesToLook:
            return TextContent.Labels.addDateToLook
        case .addDatesToItem:
            return TextContent.Labels.addDateToItem
        default:
            return TextContent.Labels.whenIworeIt
        }
    }
    
    var chooseNewDateSaveBtnText: String {
        switch self {
        case .addDatesToFriend:
            return TextContent.Buttons.saveDateWithFriend
        case .addDatesToLook:
            return TextContent.Buttons.saveDateToLook
        case .addDatesToItem:
            return TextContent.Buttons.saveDateToItem
        default:
            return TextContent.Buttons.saveDateWithFriend
        }
    }
}

