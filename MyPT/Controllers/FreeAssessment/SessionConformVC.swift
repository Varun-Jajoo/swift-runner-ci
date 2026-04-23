//
//  SessionConformVC.swift
//  MyPT
//
//  Created by Pratham Gupta on 15/03/26.
//

import UIKit

class SessionConformVC: CommonViewController {
    
    var reviewAssessmentData: ReviewAssessmentModel?
    var trainerData: SubscriptionSlotTrainer?
    var selectedSlot: SelectedSlot?
    var selectedDate: String?
    var fromQuickTrainerBook: Bool?
    
    @IBOutlet weak var lblSessionConform: UILabel!
    @IBOutlet weak var lblDetail: UILabel!
    @IBOutlet weak var lblYourSession: UILabel!
    @IBOutlet weak var lblDay: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var viewName: UIView!
    @IBOutlet weak var lblName: UILabel!
//    @IBOutlet weak var btnShowQRCOde: UIButton!
    @IBOutlet weak var btnAddToCalendar: UIButton!
//    @IBOutlet weak var lblChatDetail: UILabel!
//    @IBOutlet weak var viewBottom: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
        setNavUI()
        setData()
    }
    
    private func uiSetup() {
        DispatchQueue.main.async {
            self.lblSessionConform.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
            self.lblDetail.font = AppFont.regular.size(15.0, familyName: familyFunnelSans)
            self.lblYourSession.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
            self.lblDay.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
            self.lblTime.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
            self.lblName.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
//            self.lblChatDetail.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
//            self.viewBottom.roundSideCorners(radius: 16, cornerSide: .bottomLeft)
//            self.btnShowQRCOde.setTitle("SHOW QR CODE  ", for: .normal)
//            self.btnShowQRCOde.setImage(UIImage(named: "blackArrowRight"), for: .normal)
//            self.btnShowQRCOde.semanticContentAttribute = .forceRightToLeft
//            self.btnShowQRCOde.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
//            self.btnShowQRCOde.tintColor = .mainBg   // arrow color
//            self.btnShowQRCOde.backgroundColor = .appWhite
//            self.btnShowQRCOde.setTitleColor(.mainBg, for: .normal)
//            self.btnShowQRCOde.cornersWithBorder(radius: 8, corners: .allCorners)
            
            self.btnAddToCalendar.setTitle("VIEW BOOKING", for: .normal)
            self.btnAddToCalendar.setTitleColor(.black, for: .normal)

//            let arrowImage = UIImage(named: "blackRightArrow")?
//                .withRenderingMode(.alwaysOriginal)
//            self.btnAddToCalendar.setImage(arrowImage, for: .normal)

//            self.btnAddToCalendar.semanticContentAttribute = .forceRightToLeft
            self.btnAddToCalendar.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
            self.btnAddToCalendar.titleEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 8)
            self.btnAddToCalendar.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            self.btnAddToCalendar.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
            self.btnAddToCalendar.cornersWithBorder(radius: 8, corners: .allCorners)
            self.btnAddToCalendar.tintColor = .mainBg   // arrow color
            self.btnAddToCalendar.backgroundColor = .appWhite
            self.btnAddToCalendar.setTitleColor(.mainBg, for: .normal)
        }
    }
    
    func setNavUI() {
        self.setLeftMenu(leftImgs: [AppImages.backArrowWithBg], setTitle: [], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    // MARK: ---------------- SET IMAGE LEFT MENU BUTTONS WITH OPTIONAL TITLE
    override func setLeftMenu(leftImgs:[UIImage?] = [nil], setTitle:[String?] = [nil], setTintColor:UIColor? = .appWhite, setTitleColor:UIColor? = .appWhite){
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.hidesBackButton = false
        
        var backButton:[UIButton] = []
        backButton.removeAll()
        
        // 2. Clear previous buttons and store new ones
        leftNavButtons.removeAll()
        var leftBarButtonsArray:[UIBarButtonItem] = []
        leftBarButtonsArray.removeAll()
        
        for imgs in leftImgs.enumerated() {
            let backBtn = UIButton(type: .custom)
            backBtn.setImage(imgs.element, for: .normal)
//                backBtn.setTitle("back", for: .normal)
            backBtn.tintColor = setTintColor
            backBtn.setTitleColor(setTitleColor, for: .normal)
                        
            backBtn.sizeToFit()
            backBtn.tag = imgs.offset
            backBtn.addTarget(self, action: #selector(leftBtnActn(sender: )), for: .touchUpInside)
            
            backButton.append(backBtn)
            leftNavButtons.append(backBtn)
            leftBarButtonsArray.append(UIBarButtonItem(customView: backButton[imgs.offset]))
        }
        
        for titleStr in setTitle.enumerated() {
            if titleStr.offset < leftImgs.count {
                backButton[titleStr.offset].setTitle("  " + (titleStr.element ?? ""), for: .normal)
            }
        }
        
        
        navigationItem.leftBarButtonItems = leftBarButtonsArray
    }
    
    //MARK: ---------------- SET IMAGE LEFT MENU BUTTONS ACTION
    @objc override func leftBtnActn(sender: UIButton) {
        if fromQuickTrainerBook ?? false {
            print("👉 tabBar:", self.tabBarController as Any)
            
            // Option 1: TabBar mile to usse use karo
            if let tabBar = self.tabBarController as? CustomTabViewController {
                tabBar.selectedIndex = 0
                if let nav = tabBar.viewControllers?[0] as? UINavigationController {
                    nav.popToRootViewController(animated: false)
                }
                return
            }
            
            // Option 2: TabBar nahi mila — simple pop karo
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            if let tabBar = self.tabBarController as? CustomTabViewController {
                tabBar.selectedIndex = 0
                
                if let nav = tabBar.viewControllers?[0] as? UINavigationController {
                    nav.popToRootViewController(animated: false)
                }
            }
        }
    }
    
    private func setData() {
        if fromQuickTrainerBook ?? false {
            lblName.text = trainerData?.name
            lblDay.text = formatToWeekdayMonthDay(selectedDate ?? "")
            lblTime.text = selectedSlot?.startTime ?? ""
        } else {
            lblName.text = reviewAssessmentData?.trainer_name
            lblDay.text = formatReviewDate(date: reviewAssessmentData?.date ?? "")
            lblTime.text = formatReviewTime(timing: reviewAssessmentData?.timing ?? "")
        }
    }
    
    func formatToWeekdayMonthDay(_ dateString: String) -> String {
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "EEE, MMM d"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        
        return ""
    }
    
    func formatReviewDate(date: String) -> String {
        
        // 1. Extract start time (before "-")
//        let startTime = timing.components(separatedBy: "-").first ?? ""
        
        // 2. Combine date + current year + time
        let currentYear = Calendar.current.component(.year, from: Date())
        let fullDateString = "\(date) \(currentYear)"
        
        // 3. Input formatter
        let input = DateFormatter()
        input.locale = Locale(identifier: "en_US_POSIX")
        input.dateFormat = "d MMM yyyy"
        
        guard let dateObj = input.date(from: fullDateString) else {
            return ""
        }
        
        // 4. Output formatter
        let output = DateFormatter()
        output.locale = Locale(identifier: "en_US_POSIX")
        output.dateFormat = "EEE, MMM d"
        
        return output.string(from: dateObj)
    }
    
    func formatReviewTime(timing: String) -> String {
        
        // 1. Extract start time (before "-")
        let startTime = timing.components(separatedBy: "-").first ?? ""
        
        // 2. Combine date + current year + time
        let fullDateString = "\(startTime)"
        
        // 3. Input formatter
        let input = DateFormatter()
        input.locale = Locale(identifier: "en_US_POSIX")
        input.dateFormat = "hh:mm"
        
        guard let dateObj = input.date(from: fullDateString) else {
            return ""
        }
        
        // 4. Output formatter
        let output = DateFormatter()
        output.locale = Locale(identifier: "en_US_POSIX")
        output.dateFormat = "hh:mm a"
        
        return output.string(from: dateObj)
    }
    
    @IBAction func onTapShowQRCode(_ sender: Any) {
        if fromQuickTrainerBook ?? false {
            
            print("👉 tabBar:", self.tabBarController as Any)
            
            if let tabBar = self.tabBarController as? CustomTabViewController {
                tabBar.selectedIndex = 2
                return
            }
            
            // Fallback
            self.navigationController?.popToRootViewController(animated: true)
        } else {
            if let tabBar = self.tabBarController as? CustomTabViewController {
                tabBar.selectedIndex = 2
            }
        }
    }
}
