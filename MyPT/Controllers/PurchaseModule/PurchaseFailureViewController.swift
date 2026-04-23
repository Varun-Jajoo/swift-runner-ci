//
//  PurchaseFailureViewController.swift
//  MyPT
//
//  Created by Manik Goel on 21/02/26.
//

import UIKit

class PurchaseFailureViewController: UIViewController {
    
    var flowGymwork: calendarFlow = .defaultFlow
    var failureData: CCPaymentData?

    @IBOutlet weak var lblPaymentFailed: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
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
    @IBOutlet weak var btnChangePaymentMethod: UIButton!
    @IBOutlet weak var btnBackToReviewPlan: UIButton!
    @IBOutlet weak var viewRound: UIView!
    @IBOutlet weak var viewCircle: UIView!
    @IBOutlet weak var lblReason: UILabel!
    @IBOutlet weak var lblReasonText: UILabel!
    @IBOutlet weak var lblSecondReason: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
        setupUI()
        setData()
        self.navigationItem.hidesBackButton = true
    }
    
    private func uiSetup() {
        self.lblPaymentFailed.font = AppFont.medium.size(32, familyName: familyClashDisplay)
        self.lblSubtitle.font = AppFont.regular.size(16, familyName: familyFunnelSans)
        self.lblsession.font = AppFont.medium.size(22, familyName: familyFunnelSans)
        self.lblGymMembershipPlanName.font = AppFont.medium.size(22, familyName: familyFunnelSans)
        //        self.viewSuccesfull.setCornerRadius(borderWidth: 0, borderColor: <#T##UIColor?#>, cornerRadious: 16)
        [self.lblTrainingName, self.lblSolo, self.lblHomeOrGym, self.lblGymMembershipStartDateData, self.lblGymMembershipEndDateData].forEach {
            $0?.font = AppFont.semibold.size(14, familyName: familyFunnelSans)
        }
//        self.lblPaymentSucesfull.font = AppFont.regular.size(12, familyName: familyFunnelSans)
        [self.lblYourPlan, self.lblGymMembershipYourPlan, self.lblTrainer, self.lblTypeofWorkout, self.lblTrainingMode, lblGymMembershipStartDate, lblGymMembershipEndDate, self.lblSecondReason].forEach {
            $0?.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        }
        [self.lblValidMonth, self.lblGymMembershipPlanTime,  self.lblPlanActive, self.lblReason, self.lblReasonText].forEach {
            $0?.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
        }
//        self.lblWhatNext.font = AppFont.medium.size(16, familyName: familyClashDisplay)
//        self.btnChangePaymentMethod.setTitle("CHANGE PAYMENT METHOD ", for: .normal)
//        self.btnChangePaymentMethod.setImage(UIImage(named: "blackArrowRight"), for: .normal)
//        self.btnChangePaymentMethod.semanticContentAttribute = .forceRightToLeft
//        self.btnChangePaymentMethod.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
//        self.btnChangePaymentMethod.tintColor = .mainBg   // arrow color
//        self.btnChangePaymentMethod.backgroundColor = .appWhite
//        self.btnChangePaymentMethod.setTitleColor(.mainBg, for: .normal)
        btnBackToReviewPlan.isHidden = true
        
        self.btnChangePaymentMethod.setTitle("GO TO HOME PAGE  ", for: .normal)
//        self.btnChangePaymentMethod.setTitle("CHANGE PAYMENT METHOD ", for: .normal)
        self.btnChangePaymentMethod.setImage(UIImage(named: "whiteRightArrow"), for: .normal)
        self.btnChangePaymentMethod.semanticContentAttribute = .forceRightToLeft
        self.btnChangePaymentMethod.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
        self.btnChangePaymentMethod.tintColor = .white   // arrow color
        self.btnChangePaymentMethod.backgroundColor = UIColor(red: 29/255, green: 30/255, blue: 29/255, alpha: 1)
        self.btnChangePaymentMethod.setTitleColor(.white, for: .normal)
        
        self.btnBackToReviewPlan.setTitle("GO BACK TO REVIEW PLAN ", for: .normal)
        self.btnBackToReviewPlan.setImage(UIImage(named: "whiteRightArrow"), for: .normal)
        self.btnBackToReviewPlan.semanticContentAttribute = .forceRightToLeft
        self.btnBackToReviewPlan.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
        self.btnBackToReviewPlan.tintColor = .white   // arrow color
        self.btnBackToReviewPlan.backgroundColor = UIColor(red: 29/255, green: 30/255, blue: 29/255, alpha: 1)
        self.btnBackToReviewPlan.setTitleColor(.white, for: .normal)
        self.viewRound.makeCircular()
        self.viewCircle.makeCircular()
        self.viewYourPlan.isHidden = flowGymwork == .withoutTrainerMembership ? true : false
        self.viewGymMembership.isHidden = flowGymwork == .withoutTrainerMembership ? false : true
//        self.viewBottom.isHidden = flowGymwork == .withoutTrainerMembership ? true : false
        heightOfYourPlanView.constant = flowGymwork == .withoutTrainerMembership ? 0 : 266
//        lblTrainingPlan.text = flowGymwork == .withoutTrainerMembership ? "Your membership plan is active." : "Your training plan is active."
    }

    private func setupUI() {
//        self.btnBookYourSession.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        self.btnChangePaymentMethod.setCornerRadius(borderWidth: 1, borderColor:  UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1), cornerRadious: 12.0)
        self.btnBackToReviewPlan.setCornerRadius(borderWidth: 1, borderColor:  UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.1), cornerRadious: 12.0)
    }
    
    private func setData() {
        lblsession.text = "\(failureData?.planDetails?.sessions ?? 0) Sessions"
        lblValidMonth.text = failureData?.planDetails?.validityDisplay ?? ""
        lblTrainingName.text = failureData?.planDetails?.primaryTrainer ?? ""
        lblSolo.text = failureData?.planDetails?.workoutType ?? ""
        lblHomeOrGym.text = failureData?.planDetails?.trainingMode ?? ""
        lblGymMembershipPlanName.text = failureData?.planDetails?.planName ?? ""
        lblGymMembershipPlanTime.text = failureData?.planDetails?.validityDisplay ?? ""
        lblGymMembershipStartDateData.text = failureData?.planDetails?.startDate ?? ""
        lblGymMembershipEndDateData.text = failureData?.planDetails?.endDate ?? ""
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
//["data": {
//    amount = 444;
//    currency = AED;
//    gateway = ccavenue;
//    "is_success" = 0;
//    "order_ref" = "CCA_20260222213300_6E7CB";
//    "payment_for" = subscription;
//    "payment_id" = 84;
//    "plan_details" =     {
//        "activation_note" = "Your selected plan is saved and will be activated once payment is completed";
//        "failure_note" = "This may happen due to network issue or bank verification";
//        "failure_reason" = "Cancel reason is not specified by the customer.";
//        "is_membership" = 0;
//        "plan_name" = "One-on-One";
//        "primary_trainer" = "Bhavish Kumar";
//        sessions = 20;
//        "sessions_display" = "20 Sessions";
//        "training_mode" = "Gym Training";
//        validity = "2 years";
//        "validity_display" = "Valid for 2 years";
//        "workout_type" = "Solo (1:1)";
//    };
//    status = cancelled;
//    "status_message" = "Cancel reason is not specified by the customer.";
//    "transaction_id" = 115075137789;
//}, "status": 1, "msg": Payment was cancelled.]
