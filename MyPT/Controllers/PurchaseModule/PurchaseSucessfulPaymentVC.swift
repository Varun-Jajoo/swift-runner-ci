//
//  PurchaseSucessfulPaymentVC.swift
//  MyPT
//
//  Created by Pratham Gupta on 25/01/26.
//

import UIKit

class PurchaseSucessfulPaymentVC: UIViewController {
    
    var flowGymwork: calendarFlow = .defaultFlow
    var successData: CCPaymentData?

    @IBOutlet weak var lblAllSet: UILabel!
    @IBOutlet weak var lblTrainingPlan: UILabel!
    @IBOutlet weak var viewSuccesfull: UIView!
    @IBOutlet weak var imgCard: UIImageView!
    @IBOutlet weak var lblPaymentSucesfull: UILabel!
    @IBOutlet weak var viewCircle: UIView!
    @IBOutlet weak var lblReceipt: UILabel!
    @IBOutlet weak var viewYourPlan: UIView!
    @IBOutlet weak var lblYourPlan: UILabel!
    @IBOutlet weak var lblsession: UILabel!
    @IBOutlet weak var lblValidMonth: UILabel!
    @IBOutlet weak var lblTrainer: UILabel!
    @IBOutlet weak var lblTypeofWorkout: UILabel!
    @IBOutlet weak var lblTrainingName: UILabel!
    @IBOutlet weak var lblSolo: UILabel!
    @IBOutlet weak var lblTrainingMode: UILabel!
    @IBOutlet weak var lblHomeOrGym: UILabel!
    @IBOutlet weak var lblPlanActive: UILabel!
    @IBOutlet weak var lblWhatNext: UILabel!
    @IBOutlet weak var btnBookYourSession: UIButton!
    @IBOutlet weak var btnGoToHomePage: UIButton!
    @IBOutlet weak var viewRound: UIView!
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var viewGymMembership: UIView!
    @IBOutlet weak var lblGymMembershipYourPlan: UILabel!
    @IBOutlet weak var lblGymMembershipPlanName: UILabel!
    @IBOutlet weak var lblGymMembershipPlanTime: UILabel!
    @IBOutlet weak var lblGymMembershipStartDate: UILabel!
    @IBOutlet weak var lblGymMembershipStartDateData: UILabel!
    @IBOutlet weak var lblGymMembershipEndDate: UILabel!
    @IBOutlet weak var lblGymMembershipEndDateData: UILabel!
    @IBOutlet weak var heightOfYourPlanView: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
        setupUI()
        setData()
        self.navigationItem.hidesBackButton = true
    }
    
    private func uiSetup() {
        self.lblAllSet.font = AppFont.medium.size(32, familyName: familyClashDisplay)
        self.lblTrainingPlan.font = AppFont.regular.size(16, familyName: familyFunnelSans)
        self.lblsession.font = AppFont.medium.size(22, familyName: familyFunnelSans)
        self.lblGymMembershipPlanName.font = AppFont.medium.size(22, familyName: familyFunnelSans)
        //        self.viewSuccesfull.setCornerRadius(borderWidth: 0, borderColor: <#T##UIColor?#>, cornerRadious: 16)
        [self.lblTrainingName, self.lblSolo, self.lblHomeOrGym, self.lblGymMembershipStartDateData, self.lblGymMembershipEndDateData].forEach {
            $0?.font = AppFont.semibold.size(14, familyName: familyFunnelSans)
        }
        self.lblPaymentSucesfull.font = AppFont.regular.size(12, familyName: familyFunnelSans)
        [self.lblReceipt, self.lblYourPlan, self.lblGymMembershipYourPlan, self.lblTrainer, self.lblTypeofWorkout, self.lblTrainingMode, lblGymMembershipStartDate, lblGymMembershipEndDate].forEach {
            $0?.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        }
        [self.lblValidMonth, self.lblGymMembershipPlanTime,  self.lblPlanActive].forEach {
            $0?.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
        }
        self.lblWhatNext.font = AppFont.medium.size(16, familyName: familyClashDisplay)
        self.lblWhatNext.isHidden = true
        self.btnBookYourSession.isHidden = true
//        self.btnBookYourSession.setTitle("BOOK YOUR FIRST SESSION ", for: .normal)
//        self.btnBookYourSession.setImage(UIImage(named: "blackArrowRight"), for: .normal)
//        self.btnBookYourSession.semanticContentAttribute = .forceRightToLeft
//        self.btnBookYourSession.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
//        self.btnBookYourSession.tintColor = .mainBg   // arrow color
//        self.btnBookYourSession.backgroundColor = .appWhite
//        self.btnBookYourSession.setTitleColor(.mainBg, for: .normal)
        
        self.btnGoToHomePage.setTitle("GO TO HOME PAGE  ", for: .normal)
        self.btnGoToHomePage.setImage(UIImage(named: "whiteRightArrow"), for: .normal)
        self.btnGoToHomePage.semanticContentAttribute = .forceRightToLeft
        self.btnGoToHomePage.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
        self.btnGoToHomePage.tintColor = .white   // arrow color
        self.btnGoToHomePage.backgroundColor = UIColor(red: 29/255, green: 30/255, blue: 29/255, alpha: 1)
        self.btnGoToHomePage.setTitleColor(.white, for: .normal)
        self.viewRound.makeCircular()
        self.viewCircle.makeCircular()
        self.viewYourPlan.isHidden = flowGymwork == .withoutTrainerMembership ? true : false
        self.viewGymMembership.isHidden = flowGymwork == .withoutTrainerMembership ? false : true
//        self.viewBottom.isHidden = flowGymwork == .withoutTrainerMembership ? true : false
        heightOfYourPlanView.constant = flowGymwork == .withoutTrainerMembership ? 0 : 266
        lblTrainingPlan.text = flowGymwork == .withoutTrainerMembership ? "Your membership plan is active." : "Your training plan is active."
    }

    private func setupUI() {
        self.btnBookYourSession.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        self.btnGoToHomePage.setCornerRadius(borderWidth: 1, borderColor:  UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1), cornerRadious: 12.0)
    }
    
    private func setData() {
        lblsession.text = "\(successData?.planDetails?.sessions ?? 0) Sessions"
        lblValidMonth.text = successData?.planDetails?.validityDisplay ?? ""
        lblTrainingName.text = successData?.planDetails?.primaryTrainer ?? ""
        lblSolo.text = successData?.planDetails?.workoutType ?? ""
        lblHomeOrGym.text = successData?.planDetails?.trainingMode ?? ""
        lblGymMembershipPlanName.text = successData?.planDetails?.planName ?? ""
        lblGymMembershipPlanTime.text = successData?.planDetails?.validityDisplay ?? ""
        lblGymMembershipStartDateData.text = successData?.planDetails?.startDate ?? ""
        lblGymMembershipEndDateData.text = successData?.planDetails?.endDate ?? ""
    }
    
        
    @IBAction func onTapBookSession(_ sender: UIButton) {
        if let tabBar = self.tabBarController as? CustomTabViewController {
            tabBar.selectedIndex = 0
            
            if let nav = tabBar.viewControllers?[0] as? UINavigationController {
                nav.popToRootViewController(animated: false)
            }
        }
        if sender.tag == 0 {
            
        } else {
            
        }
    }
}

//{
//  "status" : true,
//  "data" : {
//    "amount" : "800",
//    "status" : "paid",
//    "payment_id" : 74,
//    "transaction_id" : "115075137348",
//    "is_success" : true,
//    "order_ref" : "CCA_20260222210730_BD802",
//    "payment_for" : "subscription",
//    "status_message" : "Approved",
//    "gateway" : "ccavenue",
//    "currency" : "AED",
//    "plan_details" : {
//      "validity_display" : "Valid for 4 months",
//      "workout_type" : "Solo (1:1)",
//      "training_mode" : "Home Training",
//      "failure_reason" : null,
//      "is_membership" : false,
//      "plan_name" : "One-on-One",
//      "activation_note" : "Your plan activates once you attend your first session",
//      "primary_trainer" : "Bekhzod Siddikov",
//      "failure_note" : null,
//      "sessions" : 10,
//      "validity" : "4 months",
//      "sessions_display" : "10 Sessions"
//    }
//  },
//  "msg" : "Payment successful!"
//}
