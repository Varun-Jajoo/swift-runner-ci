//
//  AssessmentBookingDetailViewController.swift
//  MyPT
//
//  Created by Manik Goel on 31/03/26.
//

import UIKit

class AssessmentBookingDetailViewController: CommonViewController {

    var assesmentStatusData: AssesmentStatusData?
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var lblUpcomingSession: UILabel!
    @IBOutlet weak var btnBottom: UIButton!
    @IBOutlet weak var lblBottom: UILabel!
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblDateAndTime: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
        setNavUI()
        setData()
    }
    
    private func uiSetup() {
        DispatchQueue.main.async {
            self.lblTitle.font = AppFont.medium.size(30.0, familyName: familyClashDisplay)
            self.lblSubtitle.font = AppFont.regular.size(15.0, familyName: familyFunnelSans)
            self.lblUpcomingSession.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
            self.lblName.font = AppFont.medium.size(16.0, familyName: familyClashDisplay)
            self.lblDateAndTime.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
            self.lblAddress.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
            self.lblBottom.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
            self.lblStatus.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
            self.viewBottom.roundSideCorners(radius: 16, cornerSide: .bottomLeft)
            
            self.btnBottom.setTitle("  TALK TO SUPPORT ON WHATSAPP", for: .normal)
            self.btnBottom.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
            self.btnBottom.setImage(UIImage(named: "ic_Whatsapp"), for: .normal)
            self.btnBottom.semanticContentAttribute = .forceLeftToRight
            self.btnBottom.tintColor = .white
            self.btnBottom.cornersWithBorder(radius: 8, corners: .allCorners)
            self.btnBottom.setCornerRadius(borderWidth: 1, borderColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1))
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
        print("Back Nav Tag",sender.tag)
        self.navigationController?.popViewController(animated: false)
    }
    
    private func setData() {
        lblName.text = assesmentStatusData?.trainer_name
        lblDateAndTime.text = formatDateTime(date: assesmentStatusData?.date ?? "", time: assesmentStatusData?.start_time ?? "")
        lblAddress.text = assesmentStatusData?.address
        imgProfile.loadImage(urlString: assesmentStatusData?.profile, placeholder: UIImage())
        lblStatus.text = assesmentStatusData?.is_completed ?? false ? "COMPLETED" : "UPCOMING"
    }
    
    func formatDateTime(date: String, time: String) -> String {
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let combined = "\(date) \(time)"
        
        guard let dateObj = formatter.date(from: combined) else {
            return ""
        }
        
        let output = DateFormatter()
        output.locale = Locale(identifier: "en_US_POSIX")
        output.dateFormat = "EEE, MMM d yyyy, hh:mm a"
        
        return output.string(from: dateObj)
    }
    
    @IBAction func onTapWhatsapp(_ sender: Any) {
        let phoneNumber = "971504725319" // +971 50 472 5319
        
        if let whatsappURL = URL(string: "whatsapp://send?phone=\(phoneNumber)"),
           UIApplication.shared.canOpenURL(whatsappURL) {
            UIApplication.shared.open(whatsappURL, options: [:], completionHandler: nil)
            return
        }
        
        if let webFallbackURL = URL(string: "https://wa.me/\(phoneNumber)") {
            UIApplication.shared.open(webFallbackURL, options: [:], completionHandler: nil)
        }
    }
}
