//
//  DateFormatterHelper.swift
//  MyPT
//
//  Created by techsaga corp on 01/04/25.
//

import Foundation

class DateFormatterHelper {
    private init() {}
    static let shared = DateFormatterHelper()
    private let df = DateFormatter()
    
    /* formate
     "yyyy-MM-dd HH:mm:ss"
     "dd, MMM • EEE"
     "dd-MM-yyyy"
     */
    
    // 3. Static property to access the DateFormatter instance
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Or your desired format
        return formatter
    }()
    
    
    func getDateFromFormat(fromDate: String, fromFormat: String, toFormat: String) -> String? {
        //        let df = DateFormatter()
        df.dateFormat = fromFormat
        df.locale = Locale(identifier: "en_US_POSIX") // Ensures correct parsing
        let fromdDt = df.date(from: fromDate)
        let toDf = DateFormatter()
        toDf.dateFormat = toFormat
        if let fromdDt = fromdDt {
            return toDf.string(from: fromdDt)
        }
        
        return nil
    }
    
    func getFormatDate(fromDate: Date, toFormat: String) -> String? {
//        df.locale = Locale(identifier: "en_US_POSIX") // Ensures correct parsing
//        df.dateFormat = fromFormat
//        let toDf = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
//        toDf.dateFormat = toFormat
        df.dateFormat = toFormat
        return  df.string(from: fromDate)
    }
    
    func dateString(from date: Date, format: String) -> String? {
        df.dateFormat = format
        df.locale = Locale(identifier: "en_US_POSIX")
        return df.string(from: date)
    }
    
    private let mediumDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }()
    
    private let mediumTimeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .none
        df.timeStyle = .medium
        
        return df
    }()
    
    private let mediumDateTimeFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .medium
        
        return df
    }()
    
    func mediumDateString(from date: Date) -> String {
        return mediumDateFormatter.string(from: date)
    }
    
    func mediumTimeString(from date: Date) -> String {
        return mediumTimeFormatter.string(from: date)
    }
    
    func mediumDateTimeString(from date: Date) -> String {
        return mediumDateTimeFormatter.string(from: date)
    }
    
    func dateInsuffix(from inputDate: String, fromFormat: String, toFormat: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = fromFormat //"yyyy-MM-dd"

        if let date = inputFormatter.date(from: inputDate) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = toFormat //"d MMM yyyy"
            let day = Calendar.current.component(.day, from: date)
            let suffix = getDaySuffix(day)
            return "\(day)\(suffix) \(outputFormatter.string(from: date).dropFirst(2))"
        }
        return nil
    }

    private func getDaySuffix(_ day: Int) -> String {
        switch day {
        case 11, 12, 13: return "th"
        default:
            switch day % 10 {
            case 1: return "st"
            case 2: return "nd"
            case 3: return "rd"
            default: return "th"
            }
        }
    }

}
