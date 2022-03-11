import Foundation
import UIKit

extension UIImage {
    
    var highestQualityJPEGNSData: Data { return self.jpegData(compressionQuality: 1.0)! }
    var highQualityJPEGNSData: Data    { return self.jpegData(compressionQuality: 0.75)!}
    var mediumQualityJPEGNSData: Data  { return self.jpegData(compressionQuality: 0.5)! }
    var lowQualityJPEGNSData: Data     { return self.jpegData(compressionQuality: 0.25)!}
    var lowestQualityJPEGNSData: Data  { return self.jpegData(compressionQuality: 0.0)! }
    
    func compressTo(_ expectedSizeInMb:Int) -> UIImage? {
        let sizeInBytes = expectedSizeInMb * 1024 * 1024
        var needCompress:Bool = true
        var imgData:Data?
        var compressingValue:CGFloat = 1.0
        while (needCompress && compressingValue > 0.0) {
            if let data:Data = self.jpegData(compressionQuality: compressingValue) {
                if data.count < sizeInBytes {
                    needCompress = false
                    imgData = data
                } else {
                    compressingValue -= 0.1
                }
            }
        }
        
        if let data = imgData {
            if (data.count < sizeInBytes) {
                return UIImage(data: data)
            }
        }
        return nil
    }
    
    func encodeImageAsBase64Jpeg(compression: CGFloat) -> String? {
        guard let imageData = self.jpegData(compressionQuality: compression) else { return nil }
        
        let base64DataString = imageData.base64EncodedString()
        return "data:image/jpeg;base64," + base64DataString
    }
    
    enum Diwi {
        static let addEventWhite = UIImage(named: TextContent.Images.addEventWhite)!
        static let logo1: UIImage = UIImage(named: TextContent.Images.logo1)!
        static let logo2: UIImage = UIImage(named: TextContent.Images.logo2)!
        static let homepageBackground = UIImage(named: TextContent.Images.homepageBackground)!
        static let registrationBackground = UIImage(named: TextContent.Images.registrationBackground)!
        static let backIcon = UIImage(named: TextContent.Images.backIcon)!
        static let backIconWhite = UIImage(named: TextContent.Images.backIconWhite)!
        static let checkbox = UIImage(named: TextContent.Images.checkbox)!
        static let addIcon = UIImage(named: TextContent.Images.addIcon)!
        static let addIconBlue = UIImage(named: TextContent.Images.addIconblue)!
        static let addIconWhite = UIImage(named: TextContent.Images.addIconWhite)!
        static let addIcon_noBackground = UIImage(named: TextContent.Images.addIconNoBackground)!
        static let calendarIcon = UIImage(named: TextContent.Images.calendarIcon)!
        static let calendarIconGray = UIImage(named: TextContent.Images.calendarIconGray)!
        static let calendarIconActive = UIImage(named: TextContent.Images.calendarIconActive)!
        static let calendarSelected = UIImage(named: TextContent.Images.calendarSelected)!
        static let cameraIcon = UIImage(named: TextContent.Images.cameraIcon)!
        static let cameraUnselected = UIImage(named: TextContent.Images.cameraUnselected)!
        static let closetEmptyState = UIImage(named: TextContent.Images.closetEmptyState)!
        static let closetIcon = UIImage(named: TextContent.Images.closetIcon)!
        static let closetSelected = UIImage(named: TextContent.Images.closetSelected)!
        static let clockIcon = UIImage(named: TextContent.Images.clockIcon)!
        static let contactIconWhite = UIImage(named: TextContent.Images.contactIconWhite)!
        static let contactIcon = UIImage(named: TextContent.Images.contactIcon)!
        static let contactsLarge = UIImage(named: TextContent.Images.contactsLarge)!
        static let contactSelected = UIImage(named: TextContent.Images.contactSelected)!
        static let downArrowIcon = UIImage(named: TextContent.Images.downArrowIcon)!
        static let eventIcon = UIImage(named: TextContent.Images.eventIcon)!
        static let eventSelected = UIImage(named: TextContent.Images.eventSelected)!
        static let eventIconActive = UIImage(named: TextContent.Images.eventIconActive)!
        static let eventEmptyState = UIImage(named: TextContent.Images.eventEmptyState)!
        static let editItemIcon = UIImage(named: TextContent.Images.editItemButton)!
        static let homePageIcon = UIImage(named: TextContent.Images.homePageIcon)!
        static let hangerIconActive = UIImage(named: TextContent.Images.hangerIconActive)!
        static let hangerIconWhite = UIImage(named: TextContent.Images.hangerIconWhite)!
        static let hangerLarge = UIImage(named: TextContent.Images.hangerLarge)!
        static let profileIcon = UIImage(named: TextContent.Images.profileIcon)!
        static let leftArrow = UIImage(named: TextContent.Images.leftArrow)!
        static let rightArrow = UIImage(named: TextContent.Images.rightArrow)!
        static let rightArrowButton = UIImage(named: TextContent.Images.rightArrowButton)!
        static let cheersIcon = UIImage(named: TextContent.Images.cheersIcon)!
        static let moreIcon = UIImage(named: TextContent.Images.moreIcon)!
        static let searchIcon = UIImage(named: TextContent.Images.searchIcon)!
        static let searchIconBlue = UIImage(named: TextContent.Images.searchIconBlue)!
        static let searchArrow = UIImage(named: TextContent.Images.searchArrow)!
        static let checkboxBlue = UIImage(named: TextContent.Images.checkBoxBlue)!
        static let pinkDownArrow = UIImage(named: TextContent.Images.pinkDownArrow)!
        static let pinkChampagne = UIImage(named: TextContent.Images.pinkChampagne)!
        static let pinkHanger = UIImage(named: TextContent.Images.pinkHanger)!
        static let pinkContacts = UIImage(named: TextContent.Images.pinkContacts)!
        static let closeBtn = UIImage(named: TextContent.Images.closeBtn)!
        static let locationIcon = UIImage(named: TextContent.Images.location)!
        static let removePinkIcon = UIImage(named: TextContent.Images.removePink)!
        static let smallDelete = UIImage(named: TextContent.Images.smallDelete)!
        static let pinkIconEvent = UIImage(named: TextContent.Images.pinkIconEvent)!
        static let whatBubble = UIImage(named: TextContent.Images.whatBubble)!
        static let whatBackground = UIImage(named: TextContent.Images.whatBackground)!
        static let whatOnboarding = UIImage(named: TextContent.Images.whatOnboarding)!
        static let whenBubble = UIImage(named: TextContent.Images.whenBubble)!
        static let whenBackground = UIImage(named: TextContent.Images.whenBackground)!
        static let whenOnboarding = UIImage(named: TextContent.Images.whenOnboarding)!
        static let whereBubble = UIImage(named: TextContent.Images.whereBubble)!
        static let whereBackground = UIImage(named: TextContent.Images.whereBackground)!
        static let whereOnboarding = UIImage(named: TextContent.Images.whereOnboarding)!
        static let whoBubble = UIImage(named: TextContent.Images.whoBubble)!
        static let whoBackground = UIImage(named: TextContent.Images.whoBackground)!
        static let whoOnboarding = UIImage(named: TextContent.Images.whoOnboarding)!
		static let accountIcon = UIImage(named: TextContent.Images.accountIcon)!
		static let accountIconSelected = UIImage(named: TextContent.Images.accountIconSelected)!
        static let accountBlueIconSelected = UIImage(named: TextContent.Images.accountBlueIconSelected)!

        
        
    }
}

extension UIImageView {
    var contentClippingRect: CGRect {
        guard let image = image else { return bounds }
        guard contentMode == .scaleAspectFit else { return bounds }
        guard image.size.width > 0 && image.size.height > 0 else { return bounds }

        let scale: CGFloat
        if image.size.width > image.size.height {
            scale = bounds.width / image.size.width
        } else {
            scale = bounds.height / image.size.height
        }

        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        let x = (bounds.width - size.width) / 2.0
        let y = (bounds.height - size.height) / 2.0

        return CGRect(x: x, y: y, width: size.width, height: size.height)
    }
}
