//
//  AssesmentReiviewBookingVC.swift
//  MyPT
//
//  Created by Pratham Gupta on 15/03/26.
//

import UIKit

class AssesmentReiviewBookingVC: CommonViewController {
    
    var inputParam: DetailsParam?
    var slotId: String?
    var reviewAssessmentData: ReviewAssessmentModel?

//    @IBOutlet weak var lblReviewBooking: UILabel!
    @IBOutlet weak var lblSelectDate: UILabel!
    @IBOutlet weak var lblTrainerName: UILabel!
    @IBOutlet weak var lblFs1Trainer: UILabel!
    @IBOutlet weak var lblDay: UILabel!
    @IBOutlet weak var viewCircle: UIView!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblTrainingLocation: UILabel!
    @IBOutlet weak var lblHome: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblComplete: UILabel!
    @IBOutlet weak var btnBookTrainer: UIButton!
    @IBOutlet weak var btnForwardArrow: UIButton!
    @IBOutlet weak var btnLocation: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
        setNavUI()
        reviewAssessmentApi()
    }
    
    private func uiSetup() {
        DispatchQueue.main.async {
//            self.lblReviewBooking.font = AppFont.medium.size(18.0, familyName: familyFunnelSans)
            self.viewCircle.makeCircular()
            self.lblSelectDate.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
            self.lblTrainerName.font = AppFont.medium.size(18.0, familyName: familyFunnelSans)
            self.lblFs1Trainer.font = AppFont.medium.size(12.0, familyName: familyFunnelSans)
            self.lblDay.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
            self.lblTime.font = AppFont.semibold.size(12.0, familyName: familyFunnelSans)
            self.lblTrainingLocation.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
            self.lblHome.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
    
            self.lblAddress.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
            self.lblComplete.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
            self.btnBookTrainer.setTitle("BOOK THE TRAINER   ", for: .normal)
            self.btnBookTrainer.setImage(UIImage(named: "blackArrowRight"), for: .normal)
            self.btnBookTrainer.semanticContentAttribute = .forceRightToLeft
            self.btnBookTrainer.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
            self.btnBookTrainer.tintColor = .mainBg   // arrow color
            self.btnBookTrainer.backgroundColor = .appWhite
            self.btnBookTrainer.setTitleColor(.mainBg, for: .normal)
            self.btnBookTrainer.cornersWithBorder(radius: 8, corners: .allCorners)
        }
    }
    
    func setNavUI() {
        self.setLeftMenu(leftImgs: [AppImages.backArrowWithBg], setTitle: [AppStrings.reviewYourBooking], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    private func setData() {
        lblTrainerName.text = reviewAssessmentData?.trainer_name ?? ""
        lblDay.text = reviewAssessmentData?.date ?? ""
        lblTime.text = reviewAssessmentData?.timing ?? ""
        lblAddress.text = reviewAssessmentData?.location_name ?? ""
        lblHome.text = reviewAssessmentData?.type == "gym" ? "Gym" : "Home"
        btnForwardArrow.isHidden = reviewAssessmentData?.type == "gym"
        btnLocation.isUserInteractionEnabled = reviewAssessmentData?.type != "gym"
    }
    
    //MARK: ---------------- SET IMAGE LEFT MENU BUTTONS WITH OPTIONAL TITLE
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
    
    @IBAction func onTapBookTrainer(_ sender: UIButton) {
        bookAssessmentApi()
    }
    
    @IBAction func onTapAddress(_ sender: UIButton) {
        let vc: ChooseAddressPopUpVC = ChooseAddressPopUpVC.instantiate(appStoryboard: .purchase)
        vc.isModalInPresentation = true
        vc.modalPresentationStyle = .pageSheet
        if #available(iOS 15.0, *) {
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.selectedDetentIdentifier = .medium
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 20
            }
        } else {
            // Fallback on earlier versions
        }
        vc.selectedAddressCallBack = { currectAddress in
            var data = self.inputParam
            data?.addressId = currectAddress.id?.value
            data?.addressData = currectAddress
            self.inputParam = data
            self.reviewAssessmentApi()
        }
        TrainerVM.getAddressApi(viewController: self, inputParms: [:], completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            print("getResultData", getResultData.data as Any)
            vc.addressData?.append(contentsOf: getResultData.data ?? [])
            present(vc, animated: true)
        })
    }
    
    
    private func reviewAssessmentApi() {
        var baseParams: [String: String] {
            [
                "type": inputParam?.type ?? "",
                "slot_id": slotId ?? "1",
            ]
        }
        
        var params = baseParams
        
        if inputParam?.type == "home" {
            params["address_id"] = inputParam?.addressData?.id?.value
        } else {
            params["studio_id"] = inputParam?.studio_id ?? ""
        }
        
        if let trainer_id = inputParam?.trainer_id {
            params["trainer_id"] = trainer_id
        }
        
        TrainerVM.reviewAssessmentApi(viewController: self, inputParms: params, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }

            if let getData = getResultData.data {
                reviewAssessmentData = getData
                setData()
            }
        })
    }
    
    private func bookAssessmentApi() {
        var baseParams: [String: String] {
            [
                "type": inputParam?.type ?? "",
                "slot_id": slotId ?? "1",
            ]
        }
        
        var params = baseParams
        
        if inputParam?.type == "home" {
            params["address_id"] = inputParam?.addressData?.id?.value
        } else {
            params["studio_id"] = inputParam?.studio_id ?? ""
        }
        
        if let trainer_id = inputParam?.trainer_id {
            params["trainer_id"] = trainer_id
        }
        
        TrainerVM.bookAssessmentApi(viewController: self, inputParms: params, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }

            if let getData = getResultData.data {
//                reviewAssessmentData = getData
//                setData()
                let vc: SessionConformVC = SessionConformVC.instantiate(appStoryboard: .homepage)
                vc.reviewAssessmentData = reviewAssessmentData
                self.navigationController?.pushViewController(vc, animated: false)
            }
        })
    }
}
