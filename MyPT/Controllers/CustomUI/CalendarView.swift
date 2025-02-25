//
//  CalendarView.swift
//  MyPT
//
//  Created by techsaga corp on 26/11/24.
//

import UIKit

@objc protocol CustomCalendarDelegate: AnyObject {
    @objc optional func didSelecteed(withValue value:String?)
    @objc optional func didDeselecteed(withValue value: String?)
}

class CalendarView: UIView {
    
    weak var delegate: CustomCalendarDelegate?
    private var isScroll: Bool = true
    
    // Properties
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    private var getSelectedInd:IndexPath = IndexPath(row: -1, section: 0)
    
    var selectedDate: Date? = nil  {
        didSet {
            if let selectedDate = selectedDate {
                let currentIndx = self.getIndexForDateUsingFilter(targetDate: selectedDate)
                print("currentIndx: = ", currentIndx as Any)
                getSelectedInd = IndexPath(row: currentIndx ?? -1, section: 0)
                self.collectionView.selectItem(at: self.getSelectedInd, animated: true, scrollPosition: .centeredHorizontally)
                self.collectionView.reloadData()
            }
        }
    }
    private var currentMonth: Date = Date()
    private var daysInCurrentMonth: Int = 0
    private var firstDayOfMonth: Date?
    private var lastDayOfMonth: Date?
    
    
    // MARK: - UI Elements
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        let collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        layout.scrollDirection = .horizontal
        
        collectionView.backgroundColor = .clear
        collectionView.register(CalendarCell.self, forCellWithReuseIdentifier: "CalendarCell")
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        return collectionView
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        collectionView.delegate = self
        collectionView.dataSource = self
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Setup
    private func setupView()
    {
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo:
                                                    topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
            
        ])
        
        // Calculate initial data
        calculateDaysInMonth()
        calculateFirstAndLastDayOfMonth()
    }
    
    // MARK: - getAllDaysOfCurrentMonth
    func getAllDaysOfCurrentMonth() -> [Date] {
        let calendar = Calendar.current
        
        // Get the range of days in the current month
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
              let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }
        
        // Generate all days
        return range.compactMap { day -> Date? in
            var components = DateComponents()
            components.year = calendar.component(.year, from: currentMonth)
            components.month = calendar.component(.month, from: currentMonth)
            components.day = day
            return calendar.date(from: components)
        }
    }
    
    // MARK: - Calculations
    private func calculateDaysInMonth() {
        let range = Calendar.current.range(of: .day, in: .month, for: currentMonth)
        guard let range = range else { return }
        daysInCurrentMonth = range.count
    }
    
    private func calculateFirstAndLastDayOfMonth() {
        var components = Calendar.current.dateComponents([.year, .month], from: currentMonth)
        components.day = 1
        firstDayOfMonth = Calendar.current.date(from: components)
        
        components.day = daysInCurrentMonth
        lastDayOfMonth = Calendar.current.date(from: components)
    }
    
    // MARK: - Public Methods
    func setCurrentMonth(_ month: Int, year: Int) {
        var components = DateComponents()
        components.month = month
        components.year = year
        currentMonth = Calendar.current.date(from: components) ?? Date()
        
        calculateDaysInMonth()
        calculateFirstAndLastDayOfMonth()
        collectionView.reloadData()
    }
    
    
    // MARK: - Private Methods
    private func configureCalendarCell(_ cell: CalendarCell, at indexPath: IndexPath) -> CalendarCell {
        let date = calculateDateForIndexPath(indexPath)
        
        // Format the day to show in the label
        let day = Calendar.current.component(.day, from: date)
        cell.dateLabel.text = "\(day)"
        
        // Normalize `date` and `today` to remove the time component
        let today = Calendar.current.startOfDay(for: Date())
        let normalizedDate = Calendar.current.startOfDay(for: date)
        
        // Highlight today's cell
        if normalizedDate == today {
            cell.backgroundColor = .blue // Highlight today
            cell.dateLabel.textColor = .white
        } else {
            cell.backgroundColor = .clear
            cell.dateLabel.textColor = .black
        }
        
        return cell
    }
    
    private func calculateDateForIndexPath(_ indexPath: IndexPath) -> Date {
        // Get the weekday of the first day of the month
        guard let firstDayOfMonth = firstDayOfMonth else { return Date() }
        let weekdayOfFirstDay = Calendar.current.component(.weekday, from: firstDayOfMonth)
        
        
        // Calculate the offset to the first visible cell
        let offset = weekdayOfFirstDay - 1 // Assuming week starts on Sunday
        
        // Add the item's index, adjusted for the offset
        var components = DateComponents()
        components.day = indexPath.item - offset
        
        // Calculate the target date
        guard let date = Calendar.current.date(byAdding: components, to: firstDayOfMonth) else {
            fatalError("Failed to calculate date for indexPath")
        }
        
        return date
    }
    
    private func startOfDay(for date: Date) -> Date {
        return Calendar.current.startOfDay(for: date)
    }
    
    // Your main function to find the index using `filter`
    func getIndexForDateUsingFilter(targetDate: Date) -> Int? {
        let allDays = getAllDaysOfCurrentMonth()
        
        // Use `filter` to find all dates that match the targetDate
        let filteredDays = allDays.filter { Calendar.current.isDate($0, inSameDayAs: targetDate) }
        
        // If the filteredDays array contains matching dates, get the index
        if let firstMatchingDate = filteredDays.first {
            // Find the index of the first matching date in the original `allDays` array
            if let index = allDays.firstIndex(of: firstMatchingDate) {
                return index
            }
        }
        
        return nil  // Return nil if no matching date is found
    }
    
}

extension CalendarView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection
                        section: Int) -> Int {
        //        guard let firstDayOfMonth = firstDayOfMonth else { return 0 }
        //
        //        let numberOfItemsBeforeFirstDayOfMonth = Calendar.current.component(.weekday, from: firstDayOfMonth) - 1
        //        let totalItems = daysInCurrentMonth + numberOfItemsBeforeFirstDayOfMonth
        //        return totalItems
        //        print("daysInCurrentMonth",self.getAllDaysOfCurrentMonth().count)
        
        return self.getAllDaysOfCurrentMonth().count //daysInCurrentMonth
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        
        if getSelectedInd.row == indexPath.row {
            DispatchQueue.main.async {
                cell.dotMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: cell.dotMBV.frame.size.height/3.0)
                
                cell.cellMBV.backgroundColor = UIColor.appCard
                cell.cellMBV.layerGradient(startPoint: .topRight, endPoint: .bottomRight, colorArray: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0).cgColor, UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor], type: .axial)
                
                cell.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1.0), cornerRadious: 12.0)
            }
        }else{
            DispatchQueue.main.async {
                cell.cellMBV.backgroundColor = UIColor.appCard
                cell.cellMBV.layerGradient(startPoint: .topRight, endPoint: .bottomRight, colorArray: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 019.0/255.0, alpha: 1.0).cgColor, UIColor(red: 71/255.0, green: 77/255.0, blue: 96/255.0, alpha: 1).cgColor], type: .axial)
                
                cell.cellMBV.setCornerRadius(borderWidth: 1, borderColor: UIColor.appBorder, cornerRadious: 12.0)
                cell.cellMBV.setGradientBorder(cornerRadious:12.0,width: 1.0, colors: [UIColor(red: 187/255.0, green: 187/255.0, blue: 187/255.0, alpha: 1.0),UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1.0)])
                
                cell.dotMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: cell.dotMBV.frame.size.height/3.0)
            }
        }
        
        let allDays = getAllDaysOfCurrentMonth()
        
        cell.dayLabel.text = getDate(dateString: "\(allDays[indexPath.row])").dayName
        cell.dayLabel.textColor = UIColor.txtDarkGray
        cell.dayLabel.textAlignment = .center
        cell.dateLabel.text = getDate(dateString: "\(allDays[indexPath.row])").numDate
        cell.dateLabel.textColor = UIColor.appWhite
        cell.dateLabel.textAlignment = .center
        
        cell.dotMBV.backgroundColor = UIColor.appLightYellow
        
        return cell
        
        //        return configureCalendarCell(cell, at: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        getSelectedInd = indexPath
        for i in getAllDaysOfCurrentMonth().enumerated() {
            if i.offset == indexPath.row {
                delegate?.didSelecteed?(withValue: "\(getAllDaysOfCurrentMonth()[indexPath.row])")
            }
        }
        
        // Handle date selection here
        //        let selectedDate = calculateDateForIndexPath(indexPath)
        //        print("Selected Date: \(selectedDate)")
//        getSelectedInd = indexPath
//        delegate?.didSelecteed?(withValue: "\(getAllDaysOfCurrentMonth()[indexPath.row])")
                
        //        print("get selected date",getAllDaysOfCurrentMonth()[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    
        for i in getAllDaysOfCurrentMonth().enumerated() {
            if i.offset == indexPath.row {
                delegate?.didDeselecteed?(withValue: "\(getAllDaysOfCurrentMonth()[indexPath.row])")
            }
        }
//                print("get deselected date",getAllDaysOfCurrentMonth()[indexPath.row])
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width*0.13, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if self.isScroll {
            self.isScroll = false
            self.collectionView.selectItem(at: self.getSelectedInd, animated: true, scrollPosition: .centeredHorizontally)
        }
    }
    
    //MARK: ----------- GET DATE
    func getDate(dateString:String) -> (dayName: String, numDate: String) {
        // Create a DateFormatter to parse the date string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZZ" // Matches the given date format
//        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = Locale(identifier: "UTC")
        
        // Parse the date string into a Date object
        if let date = dateFormatter.date(from: dateString) {
            // Get the day of the month
            let dayNumber = Calendar.current.component(.day, from: date)
            
            // Create another DateFormatter to get the day name
            let dayNameFormatter = DateFormatter()
            dayNameFormatter.dateFormat = "EE" //"EEEE" // Full day name (e.g., "Tuesday")
            let dayName = dayNameFormatter.string(from: date)
            
            return (dayName, "\(dayNumber)")
        } else {
            print("NA")
            return ("NA", "NA")
        }
    }
    
}

//MARK: --------------UICollectionViewCell
class CalendarCell: UICollectionViewCell {
    
    // MARK: - UI Elements
    lazy var cellMBV: UIView = {
        let cellV = UIView()
        
        return cellV
    }()
    
    lazy var dotMBV: UIView = {
        let cellV = UIView()
        
        return cellV
    }()
    
    lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupView()
    {
        
        contentView.addSubview(cellMBV)
        cellMBV.addSubview(dayLabel)
        cellMBV.addSubview(dateLabel)
        cellMBV.addSubview(dotMBV)
        
        cellMBV.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cellMBV.topAnchor.constraint(equalTo:
                                            contentView.topAnchor),
            cellMBV.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cellMBV.trailingAnchor.constraint(equalTo:
                                                contentView.trailingAnchor),
            cellMBV.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            
        ])
        
        
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            //            dayLabel.topAnchor.constraint(equalTo:
            //                                            cellMBV.topAnchor),
            dayLabel.topAnchor.constraint(equalTo: cellMBV.topAnchor, constant: 8),
            dayLabel.leadingAnchor.constraint(equalTo: cellMBV.leadingAnchor),
            dayLabel.trailingAnchor.constraint(equalTo:
                                                cellMBV.trailingAnchor)
        ])
        
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 5),
            dateLabel.leadingAnchor.constraint(equalTo: cellMBV.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo:
                                                    cellMBV.trailingAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: cellMBV.centerYAnchor)
        ])
        
        dotMBV.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            //            dotMBV.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 5),
            dotMBV.topAnchor.constraint(lessThanOrEqualToSystemSpacingBelow: dateLabel.bottomAnchor, multiplier: 5),
            dotMBV.centerXAnchor.constraint(equalTo: cellMBV.centerXAnchor),
            dotMBV.widthAnchor.constraint(equalToConstant: 10.0),
            dotMBV.heightAnchor.constraint(equalToConstant: 10.0),
            dotMBV.bottomAnchor.constraint(equalTo: cellMBV.bottomAnchor, constant: -8)
        ])
    }
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.cellMBV.backgroundColor = UIColor.appDarkGray
                self.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1.0), cornerRadious: 12.0)
            }
            else {
                self.cellMBV.setCornerRadius(borderWidth: 1, borderColor: UIColor.appBorder, cornerRadious: 12.0)
                self.cellMBV.setGradientBorder(cornerRadious:12.0,width: 1.0, colors: [UIColor(red: 187/255.0, green: 187/255.0, blue: 187/255.0, alpha: 1.0),UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1.0)])
            }
        }
    }
    
}
