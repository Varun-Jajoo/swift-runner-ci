//
//  DeleteAccPopupViewController.swift
//  MyPT
//
//  Created by techsaga corp on 17/06/25.
//

import UIKit

enum DeletePopFlow {
    case deyRequest
    case deleteDefault
}

class DeleteAccPopupViewController: UIViewController {

    //MARK: --------------VARIABLE
    var delPopUpFlow: DeletePopFlow = .deleteDefault
    var trainerData: TrainerDeyRequestModel?
    
    //MARK: ---------------IBOUTLET
    @IBOutlet weak var delPopupMBV: UIView!
    @IBOutlet weak var topTitleMBV: UIView!
    @IBOutlet weak var descMBV: UIView!
    @IBOutlet weak var profileTrainerMBV: UIView!
    @IBOutlet weak var cancelBtnMBV: UIView!
    @IBOutlet weak var deleteBtnMBV: UIView!
    @IBOutlet weak var topBarBtn: UIButton!
    @IBOutlet weak var dismissBtn: UIButton!
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var delBtn: UIButton!
    @IBOutlet weak var trainerImgView: UIImageView!
    @IBOutlet weak var trainerNameLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var landMarkLbl: UILabel!
    @IBOutlet weak var descLblBottomConstrnt: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupFont()
        self.setFlow()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }
    
    private func setFlow(){
        self.descMBV.isHidden = true
        self.profileTrainerMBV.isHidden = true
        self.cancelBtnMBV.isHidden = true
        self.deleteBtnMBV.isHidden = true
       
        
        switch delPopUpFlow {
        case .deyRequest:
            self.descMBV.isHidden = false
            self.profileTrainerMBV.isHidden = false
            self.deleteBtnMBV.isHidden = false
            self.descLblBottomConstrnt.constant = 18.0
            
            self.topTitleLbl.text = "Sure you want to decline the session request?"
            self.descLbl.text = trainerData?.scheduleMsg
            self.trainerImgView.loadImage(urlString: trainerData?.trainer_image, placeholder: AppImages.profile_placeholder, resize: CGSize(width: 60, height: 60))
            self.trainerNameLbl.text = trainerData?.trainer
            self.distanceLbl.text = trainerData?.distance
            self.landMarkLbl.text = trainerData?.location
            
            self.delBtn.setTitle("YES, DECLINE REQUEST", for: .normal)
            self.delBtn.setTitleColor(UIColor.appRed, for: .normal)
            
            break
            
        case .deleteDefault:
            self.descMBV.isHidden = false
            self.cancelBtnMBV.isHidden = false
            self.deleteBtnMBV.isHidden = false
            self.descLblBottomConstrnt.constant = 39.0
            
            self.topTitleLbl.text = "Sure you want to close your account and delete your data?"
            self.descLbl.text = "This action is permanent and cannot be undone. Your account, profile details, and all related data, including your booking history, goals, and progress will be permanently erased. You’ll no longer be able to access any part of your MyPT experience."
            self.cancelBtn.setTitle("CANCEL", for: .normal)
            self.delBtn.setTitle("DELETE MY ACCOUNT", for: .normal)
            self.delBtn.setTitleColor(UIColor.appWhite, for: .normal)
            
            break
        }
    }
    
    enum delBtnTag: Int {
    case topBar = 601, dismiss, cancel, deleteAcc
    }
    
    @IBAction func delCommonBtnActn(_ sender: UIButton) {
        
        switch sender.tag {
        case delBtnTag.topBar.rawValue:
            self.dismiss(animated: true)
            break
        case delBtnTag.dismiss.rawValue:
            self.dismiss(animated: true)
        case delBtnTag.cancel.rawValue:
            print("cancel btn")
            self.dismiss(animated: true)
        case delBtnTag.deleteAcc.rawValue:
            print("delete acc..")

            //---------------**********
            switch delPopUpFlow {
            case .deyRequest:
                print("Deny Request...")
                
                //MARK: -------------------DEY REQUEST BOOKING
                guard let bookingId = self.trainerData?.id else { return }
                     let params:[String:Any] = [
                        "id": bookingId ,
                        "reason": "yes"
                     ]
                    print("Cancelled params", params)
                    BookingVM.cancelSessionUpcomingApi(inputParams: params, completion: {[weak self] getResultData in
                        guard let self = self, let getResultData = getResultData else { return  }
                        print("getResultData: ", getResultData)
                        NotificationCenter.default.post(name: NSNotification.Name("refreshApiNotification"), object: "Deny Request")
                        if getResultData.status == true {
                            self.dismiss(animated: true)
                        }
                    })
                break
                
            case .deleteDefault:
                RegistrationVM.deleteUserAccApi(viewController: self, completion: {[weak self] getResultData in
                    guard self != nil else { return  }
                    print("getResultData account delete", getResultData as Any)
                    if appUserDefaults.clearUserDefault() {
                        appSceneDelegate?.goToMainView()
                    }
                })
                break
            }
            
        default:
            print("None.....")
            break
        }
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            self.delPopupMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            self.delPopupMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.black, shadowRadius: 12, opacity: 0.8, offset: .zero, cornerRadius: 12)
            
            self.cancelBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
//            self.delBtn.setCornerRadius(borderWidth: 1, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            self.trainerImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            
            switch self.delPopUpFlow {
            case .deyRequest:
                self.delBtn.setCornerRadius(borderWidth: 1, borderColor: UIColor.appRed, cornerRadious: 12.0)
                break
            case .deleteDefault:
                self.delBtn.setCornerRadius(borderWidth: 1, borderColor: UIColor.appWhite, cornerRadious: 12.0)
                print("None....")
                break
            }
        }
    }
    
    private func setupFont(){
        topTitleLbl.font = AppFont.semibold.size(18.0, familyName: familyManrope)
        descLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        
        [
            cancelBtn.titleLabel,
            delBtn.titleLabel
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: view)
            if !self.delPopupMBV.frame.contains(location) {
                      self.dismiss(animated: true, completion: nil)
                  }else{
                      print("tap at popup view.")
                  }
        }
    }
}
