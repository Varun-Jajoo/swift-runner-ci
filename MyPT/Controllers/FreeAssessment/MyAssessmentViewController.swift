//
//  MyAssessmentViewController.swift
//  MyPT
//
//  Created by Manik Goel on 31/03/26.
//

import UIKit

class MyAssessmentViewController: CommonViewController {
    
//    var assesmentStatusData: AssesmentStatusData?
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var lblContentTitle: UILabel!
    @IBOutlet weak var lblContentSubTitle: UILabel!
    @IBOutlet weak var btnViewPackage: UIButton!
    @IBOutlet weak var btnBottom: UIButton!
    @IBOutlet weak var lblBottom: UILabel!
    @IBOutlet weak var viewBottom: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
        setNavUI()
        setData()
    }
    
    private func uiSetup() {
        DispatchQueue.main.async {
            self.lblTitle.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
            self.lblSubtitle.font = AppFont.regular.size(15.0, familyName: familyFunnelSans)
            self.lblContentTitle.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
            self.lblContentSubTitle.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
            self.lblBottom.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
            self.viewBottom.roundSideCorners(radius: 16, cornerSide: .bottomLeft)
            
            self.btnBottom.setTitle("  TALK TO SUPPORT ON WHATSAPP", for: .normal)
            self.btnBottom.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
            self.btnBottom.setImage(UIImage(named: "ic_Whatsapp"), for: .normal)
            self.btnBottom.semanticContentAttribute = .forceLeftToRight
            self.btnBottom.tintColor = .white
            self.btnBottom.cornersWithBorder(radius: 8, corners: .allCorners)
            self.btnBottom.setCornerRadius(borderWidth: 1, borderColor: UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1))
            
//            self.btnBottom.setTitle(" TALK TO SUPPORT ON WHATSAPP", for: .normal)
//            self.btnBottom.setImage(UIImage(named: "ic_Whatsapp"), for: .normal)
//            self.btnBottom.semanticContentAttribute = .forceRightToLeft
//            self.btnBottom.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
//            self.btnBottom.tintColor = .mainBg   // arrow color
//            self.btnBottom.backgroundColor = .appWhite
//            self.btnBottom.setTitleColor(.mainBg, for: .normal)
//            self.btnBottom.cornersWithBorder(radius: 8, corners: .allCorners)
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
//        lblContentSubTitle.text = reviewAssessmentData?.trainer_name
//        lblContentTitle.text = convertToReadable(date: reviewAssessmentData?.date ?? "", time: reviewAssessmentData?.timing ?? "")
    }
    
    func convertToReadable(date: String, time: String) -> String? {
        let startTime = time.components(separatedBy: "-").first ?? ""
        let amPm = time.contains("PM") ? "PM" : "AM"
        
        let finalInput = "\(date) \(startTime) \(amPm)"
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd MMM hh:mm a"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "EEE, MMM d hh:mm a"
        
        if let dateObj = inputFormatter.date(from: finalInput) {
            return outputFormatter.string(from: dateObj)
        }
        return nil
    }
    
    @IBAction func onTapViewPackage(_ sender: Any) {
        let vc: CreateTrainerViewController = CreateTrainerViewController.instantiate(appStoryboard: .booking)
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @IBAction func onTapWhatsapp(_ sender: UIButton) {
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
