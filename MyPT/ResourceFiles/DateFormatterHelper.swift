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
    
    func dateFromString(from dateString: String, format: String) -> Date? {
        df.dateFormat = format
        df.locale = Locale(identifier: "en_US_POSIX")
        return df.date(from: dateString)
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
    
    func getTimeOfDay(for date: Date = Date()) -> String {
        let hour = Calendar.current.component(.hour, from: date)

        switch hour {
        case 5..<12:
            return "Morning"
        case 12..<17:
            return "Afternoon"
        case 17..<21:
            return "Evening"
        default:
            return "Night"
        }
    }
    
    func getTodayDate(fromFormat: String) -> String{
        //fromFormat = "yyyy-MM-dd HH:mm:ss zzz"
        let date = Date()
        df.dateFormat = fromFormat
        df.timeZone = TimeZone.current
        return df.string(from: date)
    }
    
    func getDatesDays() -> [[String: String]] {
        let calendar = Calendar.current
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "dd MMM, EEE"
        
        let storageFormatter = DateFormatter()
        storageFormatter.dateFormat = "yyyy-MM-dd"
        
        let today = Date()
        let dates: [Date] = [
            calendar.date(byAdding: .day, value: -1, to: today)!, // yesterday
            today,
            calendar.date(byAdding: .day, value: 1, to: today)!,  // +1 days
            calendar.date(byAdding: .day, value: 2, to: today)!   // +2 days
        ]
        
        var result: [[String: String]] = []
        
        for date in dates {
            let display = calendar.isDateInToday(date) ? "Today" : displayFormatter.string(from: date)
            let storage = storageFormatter.string(from: date)
            
            result.append([
                "displayDate": display,       // For UI: "Today" or "21 Aug, Thu"
                "storageDate": storage        // For backend: "2025-08-21"
            ])
        }
        
        return result
    }

    
    /*
    func getDatesDays() -> [String]{
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, EEE"
        var dateStr:[String] = []
        let today = Date()
        let dates: [Date] = [
            calendar.date(byAdding: .day, value: -1, to: today)!, // yesterday
            today,
            calendar.date(byAdding: .day, value: 2, to: today)!,  // +2 days
            calendar.date(byAdding: .day, value: 3, to: today)!   // +3 days
        ]
        
        dateStr.removeAll()
        for date in dates {
            if calendar.isDateInToday(date) {
                dateStr.append("Today")
                print("Today")
            } else {
                dateStr.append(dateFormatter.string(from: date))
                print(dateFormatter.string(from: date))
            }
        }
        return dateStr
    }
    */
}
