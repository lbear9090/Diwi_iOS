//
//  DateExtension.swift
//  SEF
//
//  Created by Apple on 11/10/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

extension Calendar {
    static let gregorian = Calendar(identifier: .gregorian)
}

extension Date {

    var startOfWeek: Date? {
        return Calendar.gregorian.date(from: Calendar.gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
    }

    func getWeekStartDate(_ currenDate: Date) -> Date {
        var weekStartDate = self
        var previousWeek = weekStartDate
        while weekStartDate < currenDate {
            previousWeek = weekStartDate
            weekStartDate = weekStartDate.addWeeks(1)
        }
        return previousWeek
    }

    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
    func timestamp() -> String {
        return "\(self.timeIntervalSince1970)"
    }

    func onlyDateString(_ format: String = "yyyy-MM-dd") -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format

        return dateFormatter.string(from: self)
    }

    func onlyDateStringForEditProfile() -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"

        return dateFormatter.string(from: self)
    }

    func onlyTimeString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm" // a

        return dateFormatter.string(from: self)
    }

    func onlyHours() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh" // a

        return dateFormatter.string(from: self)
    }

    func onlyMinutes() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm" // a

        return dateFormatter.string(from: self)
    }

    func onlyTimeStringAmPm() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a" // a

        return dateFormatter.string(from: self)
    }
    func UTCStringFromDate() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"
        return dateFormatter.string(from: self)
    }
    func dateString(_ format: String = "dd-MM-yyyy") -> String {

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale.current
        dateFormatter.timeZone = TimeZone.ReferenceType.local
        return dateFormatter.string(from: self)
    }

    func addWeeks(_ number: Int) -> Date {
        let date = Calendar.current.date(byAdding: .weekOfYear, value: number, to: self)
        return date!
    }

    func addMonths(_ number: Int) -> Date {
        let date = Calendar.current.date(byAdding: .month, value: number, to: self)
        return date!
    }

    func yearsFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.year, from: date, to: self, options: []).year!
    }
    func monthsFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.month, from: date, to: self, options: []).month!
    }
    func weeksFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.weekOfYear, from: date, to: self, options: []).weekOfYear!
    }
    func daysFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.day, from: date, to: self, options: []).day!
    }
    func hoursFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.hour, from: date, to: self, options: []).hour!
    }
    func minutesFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.minute, from: date, to: self, options: []).minute!
    }
    func secondsFrom(_ date: Date) -> Int {
        return (Calendar.current as NSCalendar).components(.second, from: date, to: self, options: []).second!
    }
    func offsetFrom(_ date: Date) -> String {
        if yearsFrom(date)   > 0 { return "\(yearsFrom(date))Y"   }
        if monthsFrom(date)  > 0 { return "\(monthsFrom(date))M"  }
        if weeksFrom(date)   > 0 { return "\(weeksFrom(date))W"   }
        if daysFrom(date)    > 0 { return "\(daysFrom(date))d"    }
        if hoursFrom(date)   > 0 { return "\(hoursFrom(date))h"   }
        if minutesFrom(date) > 0 { return "\(minutesFrom(date))m" }
        if secondsFrom(date) > 0 { return "\(secondsFrom(date))s" }
        return "now"
    }

    // MARK: - Decomposing Dates

    func day() -> Int {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: self)
        return day
    }

    func month() -> Int {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: self)
        return month
    }

    func year() -> Int {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: self)
        return year
    }

    func hour() -> Int {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: self)
        return hour
    }

    func minute() -> Int {
        let calendar = Calendar.current
        let minute = calendar.component(.minute, from: self)
        return minute
    }

    // MARK: - Adjusting Dates

    func dateByAddingYears(_ dYears: Int) -> Date {

        var dateComponents = DateComponents()
        dateComponents.year = dYears

        return Calendar.current.date(byAdding: dateComponents, to: self)!
    }

    func dateByAddingMonths(_ dMonths: Int) -> Date {

        var dateComponents = DateComponents()
        dateComponents.month = dMonths

        return Calendar.current.date(byAdding: dateComponents, to: self)!
    }

    func dateByAddingWeeks(_ dWeeks: Int) -> Date {

        var dateComponents = DateComponents()
        dateComponents.weekOfYear = dWeeks

        return Calendar.current.date(byAdding: dateComponents, to: self)!
    }

    func dateBySubtractingYears(_ dYears: Int) -> Date {
        return dateByAddingYears(-dYears)
    }

    func dateBySubtractingMonths(_ dMonths: Int) -> Date {
        return dateByAddingMonths(-dMonths)
    }

    func dateBySubtractingWeeks(_ dWeeks: Int) -> Date {
        return dateByAddingWeeks(-dWeeks)
    }
      func dateBySubtractingHours(_ hours: Int) -> Date {
          return dateByAddingHours(-hours)
      }
    func dateByAddingHours(_ hours: Int) -> Date {

        var dateComponents = DateComponents()
        dateComponents.hour = hours

        return Calendar.current.date(byAdding: dateComponents, to: self)!
    }

    func dateByAddingDays(_ dDays: Int) -> Date {

        var dateComponents = DateComponents()
        dateComponents.day = dDays

        return Calendar.current.date(byAdding: dateComponents, to: self)!
    }

    func dateBySubtractingDays(_ dDays: Int) -> Date {
        return dateByAddingDays(-dDays)
    }

    /// return first moment date of day
    func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }

    /// return end of the day moment
    func endOfDay() -> Date {
        let dateAtMidnight = self.startOfDay()
        //For End Date
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: dateAtMidnight)!
    }

    func getDayName() -> String {
        let weekDay = Calendar.current.component(.weekday, from: self)
        switch weekDay {
        case 1:
            return "S"
        case 2:
            return "M"
        case 3:
            return "T"
        case 4:
            return "W"
        case 5:
            return "T"
        case 6:
            return "F"
        case 7:
            return "S"
        default:
            return "Nada"
        }
    }

    func setTimeToMidNight() -> Date? {
        return Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: self)
    }

    static func createDate(hour: Int, min: Int) -> Date? {
        var components = Calendar.current.dateComponents([.hour,.minute], from: Date())
        components.hour = hour
        components.minute = min
        components.timeZone = .current

        return Calendar.current.date(from: components)
    }
}

// Usage

/*
 let date1 = NSCalendar.currentCalendar().dateWithEra(1, year: 2014, month: 11, day: 28, hour: 5, minute: 9, second: 0, nanosecond: 0)!
 let date2 = NSCalendar.currentCalendar().dateWithEra(1, year: 2015, month: 8, day: 28, hour: 5, minute: 9, second: 0, nanosecond: 0)!
 
 let years = date2.yearsFrom(date1)     // 0
 let months = date2.monthsFrom(date1)   // 9
 let weeks = date2.weeksFrom(date1)     // 39
 let days = date2.daysFrom(date1)       // 273
 let hours = date2.hoursFrom(date1)     // 6,553
 let minutes = date2.minutesFrom(date1) // 393,190
 let seconds = date2.secondsFrom(date1) // 23,590,800
 
 let timeOffset = date2.offsetFrom(date1) // "9M"
 
 let date3 = NSCalendar.currentCalendar().dateWithEra(1, year: 2014, month: 11, day: 28, hour: 5, minute: 9, second: 0, nanosecond: 0)!
 let date4 = NSCalendar.currentCalendar().dateWithEra(1, year: 2015, month: 11, day: 28, hour: 5, minute: 9, second: 0, nanosecond: 0)!
 
 let timeOffset2 = date4.offsetFrom(date3) // "1y"
 
 let timeOffset3 = NSDate().offsetFrom(date3) // "54m"
 */
