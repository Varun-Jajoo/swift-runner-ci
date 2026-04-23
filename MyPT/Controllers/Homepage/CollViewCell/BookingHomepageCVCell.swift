//
//  BookingHomepageCVCell.swift
//  MyPT
//
//  Created by Pratham Gupta on 07/02/26.
//

import UIKit

class BookingHomepageCVCell: UICollectionViewCell {
    
    @IBOutlet weak var imgBackgrnd: UIImageView!
    @IBOutlet weak var imgTrainer: UIImageView!
    @IBOutlet weak var lblTrainerName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var viewDowinword: UIView!
    @IBOutlet weak var btnCheckIn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        uiSetup()
    }
    
    private func uiSetup() {
        self.lblTrainerName.font = AppFont.medium.size(16.0, familyName: familyFunnelSans)
        self.lblTime.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
        self.lblAddress.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
        self.lblStartTime.font = AppFont.regular.size(14.0, familyName: familyClashDisplay)
        self.viewDowinword.roundBottomCorners(radius: 16)
    }
    
    func setInputData(data: BookingDataModel?) {

        guard let data = data else { return }

        // Trainer Name
        lblTrainerName.text = data.trainer?.value ?? ""

        // Time Slot
        lblTime.text = data.selected_slot?.value

        // Address
        lblAddress.text = formatDate(data.timing?.value ?? "")

        // Starts In
        let startInTime = convertToDays(data.starts_in?.value ?? "")
        lblStartTime.text = "Starts in \(startInTime)"

        // Trainer Image
        imgTrainer.loadImage(urlString: data.trainer_image?.value,
                             placeholder: UIImage(named: "bookingTrainer"))
    }
    
    func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "MMM dd, yyyy, hh:mm a"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "dd MMM, yyyy"
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        
        return ""
    }
    
    func convertToDays(_ timeString: String) -> String {
        
        let components = timeString.split(separator: " ")
        
        var hours = 0
        var minutes = 0
        
        // Extract values
        for comp in components {
            if comp.contains("h") {
                hours = Int(comp.replacingOccurrences(of: "h", with: "")) ?? 0
            } else if comp.contains("m") {
                minutes = Int(comp.replacingOccurrences(of: "m", with: "")) ?? 0
            }
        }
        
        // Convert minutes to hours if needed
        hours += minutes / 60
        minutes = minutes % 60
        
        // Convert hours to days
        let days = hours / 24
        let remainingHours = hours % 24
        
        var parts: [String] = []
        
        if days > 0 {
            parts.append("\(days)D")
        }
        
        if remainingHours > 0 {
            parts.append("\(remainingHours)h")
        }
        
        if minutes > 0 {
            parts.append("\(minutes)m")
        }
        
        return parts.joined(separator: " ")
    }
}
