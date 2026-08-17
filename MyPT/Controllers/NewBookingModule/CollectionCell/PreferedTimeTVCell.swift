//
//  PreferedTimeTVCell.swift
//  MyPT
//
//  Created by Manik Goel on 09/06/26.
//

import UIKit

class PreferedTimeTVCell: UITableViewCell {

    @IBOutlet weak var viewBg: UIView!
    @IBOutlet weak var imgBg: UIImageView!
    @IBOutlet weak var lblDay: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var viewCircle: UIView!
    @IBOutlet weak var viewUnavailabel: UIView!
    @IBOutlet weak var view2Circle: UIView!
    @IBOutlet weak var lblUnavailableDay: UILabel!
    @IBOutlet weak var lblUnavailableText: UILabel!
    @IBOutlet weak var lblSeeOptions: UILabel!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        uiSetup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Dynamically find the private UISwipeActionPullView in the table view subviews
        // and adjust its frame height to match the visible card inside the cell.
        if let table = self.superview {
            let cardHeight = !viewBg.isHidden ? viewBg.frame.height : viewUnavailabel.frame.height
            
            for subview in table.subviews {
                let className = NSStringFromClass(type(of: subview))
                if className.contains("UISwipeActionPullView") {
                    // Update frame height to align with card height, leaving the bottom 8pt spacing clean
                    var frame = subview.frame
                    frame.size.height = cardHeight
                    subview.frame = frame
                    
                    subview.clipsToBounds = true
                    subview.layer.cornerRadius = 12
                    subview.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                    
                    // Also round the individual buttons inside to prevent color bleeding
                    for button in subview.subviews {
                        button.clipsToBounds = true
                        button.layer.cornerRadius = 12
                        button.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                    }
                }
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        lblDay.text = nil
        lblUnavailableDay.text = nil
        lblName.text = nil
        lblTime.text = nil
        lblUnavailableText.text = nil
    }

    // MARK: - UI Constants
    private func uiSetup() {
        lblDay.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        lblUnavailableDay.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        lblName.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        lblTime.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        lblUnavailableText.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        lblSeeOptions.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        viewCircle.makeCircular()
        view2Circle.makeCircular()
        viewBg.cornersWithBorder(radius: 12, corners: .allCorners)
        viewUnavailabel.cornersWithBorder(radius: 12, corners: .allCorners)
    }

    // MARK: - Configuration

    /// Primary configuration method — reads everything from `BookingDateState`.
    /// Zero business logic here; the cell only renders what the ViewModel provides.
    func configure(with state: BookingDateState) {
        // Shared labels
        lblDay.text = state.dateFormatted
        lblUnavailableDay.text = state.dateFormatted
        lblName.text = state.displayTrainerName
        lblTime.text = state.displayTimeText

        // Show the correct card based on availability state
        switch state.availabilityState {

        case .available, .manuallyResolved:
            // ✅ Show the available card; hide the unavailable card
            viewBg.isHidden = false
            viewUnavailabel.isHidden = true
            lblUnavailableText.text = nil

        case .unavailable:
            // ❌ Show the unavailable card; hide the available card
            viewBg.isHidden = true
            viewUnavailabel.isHidden = false
            lblUnavailableText.text = state.unavailableMessage
        }
    }
}
