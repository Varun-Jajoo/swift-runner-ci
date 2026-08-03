//
//  BookingListTableViewCell.swift
//  MyPT
//
//  Created by techsaga corp on 16/12/24.
//

import UIKit

class BookingListTableViewCell: UITableViewCell {

    //MARK: --------------------IBOUTLET
    @IBOutlet weak var cellMBV: UIView!
    @IBOutlet weak var gymProfileImgView: UIImageView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var forwarImgView: UIImageView!
    @IBOutlet weak var workoutMBV: UIStackView!
    @IBOutlet weak var lineMBV: UIView!
    @IBOutlet weak var trainerDetailsMBV: UIStackView!
    @IBOutlet weak var rescheduledMBV: UIView!
    @IBOutlet weak var workoutFocusTitleLbl: UILabel!
    @IBOutlet weak var workoutFocusDescLbl: UILabel!
    @IBOutlet weak var sessionTypeTitleLbl: UILabel!
    @IBOutlet weak var sessionDescLbl: UILabel!
    @IBOutlet weak var durationTitleLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var lineLbl: UILabel!
    @IBOutlet weak var myTrainerTitleLbl: UILabel!
    @IBOutlet weak var trainerNameLbl: UILabel!
    @IBOutlet weak var trainerLocTitleLbl: UILabel!
    @IBOutlet weak var trainingLocDesc: UILabel!
    @IBOutlet weak var rescheduledBtn: UIButton!
    
    @IBOutlet weak var lineV: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        self.addLeftBorder(borderColor: UIColor.appYellow)
        self.setupUI()
        self.setUpFont()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func setupUI(){
        DispatchQueue.main.async {
            self.cellMBV.addGradient(colors: UIColor.appMultiColor(.gradientColor), locations: [0,1], startPoint: CGPoint(x: 1, y: 1), endPoint: CGPoint(x: 0, y: 1), cornerRadius: 12.0)
            self.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.rescheduledBtn.addGradient(colors: [UIColor(red: 255/255.0, green: 198/255.0, blue: 6/255.0, alpha: 1.0), UIColor(red: 153/255.0, green: 119/255.0, blue: 4/255.0, alpha: 1)], locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 12.0)
           
            self.rescheduledBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.lineLbl.backgroundColor = .clear
            self.lineV.backgroundColor = UIColor.clear
            self.lineV.addGradient(colors: UIColor.appMultiColor(.lineVGradient2), locations: [0,0.3,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 0.2)
            self.contentView.setNeedsLayout()
            self.contentView.layoutIfNeeded()
            
            /*
             [
                 UIColor(red: 42.0/255.0, green: 45.0/255.0, blue: 47.0/255.0, alpha: 0.2),
                 UIColor(red: 52.0/255.0, green: 55.0/255.0, blue: 57.0/255.0, alpha: 1),
                 UIColor(red: 42.0/255.0, green: 45.0/255.0, blue: 47.0/255.0, alpha: 0.2)]
             */
            
//            self.lineV.drawLine(start: CGPoint(x: 0, y: 1), toPoint: CGPoint(x: 1, y: 1.0))
        }
    }
    
    //MARK: -----------FONT SETUP
    private func setUpFont(){
        self.dateLbl.font = AppFont.semibold.size(18, familyName: familyManrope)
        
        [
            self.workoutFocusDescLbl,
            self.sessionDescLbl,
            self.timeLbl,
            self.trainerNameLbl,
            self.trainingLocDesc
        ].forEach({[weak self] in
            guard self != nil else { return }
            $0?.font = AppFont.semibold.size(14, familyName: familyManrope)
        })
        
        [
            self.workoutFocusTitleLbl,
            self.sessionTypeTitleLbl,
            self.durationTitleLbl,
            self.myTrainerTitleLbl,
            self.trainerLocTitleLbl,
            self.rescheduledBtn.titleLabel
        ].forEach({[weak self] in
            guard self != nil else { return  }
            $0?.font = AppFont.semibold.size(12, familyName: familyManrope)
        })
    }
    
    func addLeftBorder(borderColor: UIColor? = UIColor.clear) {
           let leftBorder = CALayer()
        self.cellMBV.layer.sublayers?.removeAll(where: { $0.name == "left_border" })
        leftBorder.name = "left_border"
        leftBorder.backgroundColor = borderColor?.cgColor // Set your border color
        DispatchQueue.main.async {
            leftBorder.frame = CGRect(x: 0, y: 0, width: 3.0, height: self.cellMBV.frame.height) // Adjust width as needed
        }
        self.cellMBV.layer.addSublayer(leftBorder)
        self.setupUI()
       }
    
    
    //MARK: --------------SETUP CELL DATA
    func setUpCell(inputData: BookingDataModel?, type:Int? = 2){
        guard let inputData = inputData, let type = type else { return }
        self.rescheduledBtn.isHidden = true
        self.dateLbl.text = inputData.timing?.value
//        self.workoutFocusDescLbl.text = inputData.workoutFocus?.joined(separator: ",")
        self.workoutFocusDescLbl.text = inputData.bookingType
        self.sessionDescLbl.text = inputData.sessionType?.value
        self.timeLbl.text = inputData.duration?.value
        self.trainerNameLbl.text = inputData.trainer?.value

        // Group-class rows show only the studio name, matching Android's
        // `UpcomingAdapter.onBindViewHolder`: `location.substringBefore(",")`
        // when the row is a group class and the location actually contains a
        // comma (e.g. "DSO Club, Dubai" -> "DSO Club"). Every other row keeps
        // the full location string.
        let rawLocation = inputData.location?.value ?? ""
        if inputData.isGroupClass, let commaRange = rawLocation.range(of: ",") {
            self.trainingLocDesc.text = String(rawLocation[..<commaRange.lowerBound]).trimmingCharacters(in: .whitespaces)
        } else {
            self.trainingLocDesc.text = rawLocation
        }

        if type == 2{
            if let isReschedule = inputData.isReschedule, isReschedule {
                self.rescheduledBtn.isHidden = false
                self.rescheduledBtn.setTitle(inputData.msg, for: .normal)
                self.addLeftBorder(borderColor: UIColor.appRatingYellow)
                
                let text = inputData.timing?.value ?? ""
                let dot = " ●"
                // Text attributes
                let textAttributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.appWhite
                ]
                let textAttributed = NSAttributedString(string: text, attributes: textAttributes)

                // Dot attributes
                let dotAttributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: UIColor.appRatingYellow
                ]
                let dotAttributed = NSAttributedString(string: dot, attributes: dotAttributes)

                // Combine them
                let finalString = NSMutableAttributedString()
                finalString.append(textAttributed)
                finalString.append(dotAttributed)
                self.dateLbl.attributedText = finalString
                                
            }else{
                self.addLeftBorder(borderColor: UIColor(red: 93.0/255.0, green: 182.0/255.0, blue: 195.0/255.0, alpha: 1))
            }
        } else if type == 0{
            self.addLeftBorder(borderColor: UIColor.appRed)
        } else if type == 1{
            self.addLeftBorder(borderColor: UIColor.appGreen)
        }
        self.contentView.setNeedsLayout()
        self.contentView.layoutIfNeeded()
        self.setupUI()
    }
           
}
