//
//  BadgesTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 24/06/25.
//

import UIKit

class BadgesTableViewCell: UITableViewCell {

    //---------------- VARIABLE
    var indicators: [ANSegmentIndicator] = []
    var timer: Timer?
    
    //---------------- IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var badgeImgView: UIImageView!
    @IBOutlet weak var badgeTitleLbl: UILabel!
    @IBOutlet weak var badgesDescLbl: UILabel!
    @IBOutlet weak var badgeProgressMBV: UIView!
    @IBOutlet weak var progressCountLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setupUI()
        self.setupFont()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.setupCircularProgrss()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupCircularProgrss() {
        var settings = ANSegmentIndicatorSettings()
        settings.defaultSegmentColor = UIColor(red: 49.0/255.0, green: 52.0/255.0, blue: 58.0/255.0, alpha: 1.0)
        settings.segmentBorderType = .butt
        settings.segmentsCount = 8
        settings.segmentWidth = 3
        settings.segmentColor = UIColor.appYellow
        let segment = ANSegmentIndicator(frame: CGRect(x: 0, y: 0, width: badgeProgressMBV.frame.size.width, height: badgeProgressMBV.frame.size.height))
        
        badgeProgressMBV.backgroundColor = UIColor.clear
        segment.settings = settings
        indicators.append(segment)
        self.badgeProgressMBV.addSubview(segment)
        
        //-------------------*******
        var progressInPercents = 1.0
        timer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { timer in
          
            if progressInPercents >= 30 {
                timer.invalidate()
                self.timer = nil
            }
            
            progressInPercents = progressInPercents + 5.0
            self.indicators.forEach {
                $0.updateProgress(percent: progressInPercents)
                self.progressCountLbl.text = "\(Int(progressInPercents))"
            }
        }
    }
    
    private func setupUI(){
        DispatchQueue.main.async {
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.badgeImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: self.badgeImgView.frame.size.height/2.0)
            self.badgeProgressMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: self.badgeProgressMBV.frame.size.height/2.0)
        }
    }
    
    private func setupFont(){
        self.badgeTitleLbl.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.badgesDescLbl.font = AppFont.medium.size(14.0, familyName: familyManrope)
        self.progressCountLbl.font = AppFont.bold.size(22.0, familyName: familyManrope)
    }
}
