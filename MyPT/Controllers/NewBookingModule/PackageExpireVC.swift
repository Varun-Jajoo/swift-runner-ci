//
//  PackageExpireVC.swift
//  MyPT
//
//  Created by Manik Goel on 16/07/26.
//

import UIKit


class PackageExpireVC: UIViewController {
    
    var userPlans: PlanDetailsModel?

    @IBOutlet weak var lblPaymentFailed: UILabel!
    @IBOutlet weak var lblSubtitle: UILabel!
    @IBOutlet weak var viewYourPlan: UIView!
    @IBOutlet weak var lblYourPlan: UILabel!
    @IBOutlet weak var lblsession: UILabel!
    @IBOutlet weak var lblValidMonth: UILabel!
    @IBOutlet weak var lblTrainerPlanType: UILabel!
    @IBOutlet weak var lblMode: UILabel!
    @IBOutlet weak var lblTrainerPlanTypeData: UILabel!
    @IBOutlet weak var lblSolo: UILabel!
    @IBOutlet weak var lblValidity: UILabel!
    @IBOutlet weak var lblValidityData: UILabel!
    @IBOutlet weak var lblPlanActive: UILabel!
    @IBOutlet weak var viewRound: UIView!
    @IBOutlet weak var viewGymMembership: UIView!
    @IBOutlet weak var lblGymMemberYourPlan: UILabel!
    @IBOutlet weak var lblGymMemberYourPlanData: UILabel!
    @IBOutlet weak var lblGymMemberExpiryDate: UILabel!
    @IBOutlet weak var lblGymMemberPlanType: UILabel!
    @IBOutlet weak var lblGymMemberPlanTypeData: UILabel!
    @IBOutlet weak var lblGymMemberValidity: UILabel!
    @IBOutlet weak var lblGymMemberValidityData: UILabel!
    @IBOutlet weak var lblPlanExpired: UILabel!
    @IBOutlet weak var lblTotalSessions: UILabel!
    @IBOutlet weak var lblTotalSessionData: UILabel!
    @IBOutlet weak var heightOfTrainerPlan: NSLayoutConstraint!
    @IBOutlet weak var heightOfGymMembership: NSLayoutConstraint!
    @IBOutlet weak var lblGymRound: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSetup()
        setData()
        self.navigationItem.hidesBackButton = true
    }
    
    private func uiSetup() {
        self.lblPaymentFailed.font = AppFont.medium.size(32, familyName: familyClashDisplay)
        self.lblSubtitle.font = AppFont.regular.size(16, familyName: familyFunnelSans)
        self.lblsession.font = AppFont.medium.size(20, familyName: familyFunnelSans)
        self.lblGymMemberYourPlanData.font = AppFont.medium.size(20, familyName: familyFunnelSans)
     
        [self.lblTrainerPlanTypeData, self.lblSolo, self.lblValidityData, self.lblGymMemberPlanTypeData, self.lblTrainerPlanTypeData, self.lblGymMemberValidityData, self.lblTotalSessionData].forEach {
            $0?.font = AppFont.semibold.size(14, familyName: familyFunnelSans)
        }
        [self.lblYourPlan, self.lblGymMemberYourPlan, self.lblGymMemberPlanType, self.lblGymMemberValidity, self.lblTrainerPlanType, self.lblMode, self.lblValidity, self.lblTotalSessions].forEach {
            $0?.font = AppFont.regular.size(12.0, familyName: familyFunnelSans)
        }
        [self.lblValidMonth, self.lblPlanActive, lblPlanExpired, self.lblGymMemberExpiryDate].forEach {
            $0?.font = AppFont.regular.size(14.0, familyName: familyFunnelSans)
        }
        viewRound.makeCircular()
        lblGymRound.makeCircular()
    }
 
    private func setData() {
        heightOfTrainerPlan.constant = userPlans?.is_membership ?? false ? 0 : 280
        heightOfGymMembership.constant = userPlans?.is_membership ?? false ? 215 : 0
        viewGymMembership.isHidden = userPlans?.is_membership ?? false ? false : true
        viewYourPlan.isHidden = !(userPlans?.is_membership ?? false) ? false : true
        lblValidMonth.text = userPlans?.end_date?.value
        lblGymMemberYourPlanData.text = userPlans?.name?.value
        lblGymMemberExpiryDate.text = userPlans?.end_date?.value
        lblSolo.text = userPlans?.name?.value
        lblsession.text = userPlans?.name?.value
        lblTotalSessionData.text = userPlans?.sessions?.value
        lblValidityData.text = (userPlans?.validity_days?.value ?? "") + " Days"
        lblTrainerPlanTypeData.text = "Personal Training"
        lblGymMemberValidityData.text = (userPlans?.validity_days?.value ?? "") + " Days"
        lblGymMemberPlanTypeData.text = "Gym Membership"
        lblPlanActive.text = userPlans?.msg?.value
        lblPlanExpired.text = userPlans?.msg?.value
    }
    
    @IBAction func onTapNewPlan(_ sender: UIButton) {
        let vc:CreateTrainerViewController = CreateTrainerViewController.instantiate(appStoryboard: .booking)
        self.navigationController?.pushViewController(vc, animated: false)
//        let vc: NewBookingModuleVC = NewBookingModuleVC.instantiate(appStoryboard: .newBookingModule)
//        vc.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @IBAction func onTapHome(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func onTapRenew(_ sender: UIButton) {
        let bookingReviewPurchaseVC: BookingReviewPurchaseVC = BookingReviewPurchaseVC.instantiate(appStoryboard: .newBookingModule)
        bookingReviewPurchaseVC.inputParam = DetailsParam(
            type: self.userPlans?.type?.value
        )
        bookingReviewPurchaseVC.sessions = self.userPlans?.sessions?.value
        bookingReviewPurchaseVC.hidesBottomBarWhenPushed = true
        bookingReviewPurchaseVC.previousSubscriptionID = self.userPlans?.id?.value
        bookingReviewPurchaseVC.isGymMembership = self.userPlans?.is_membership ?? false
        self.navigationController?.pushViewController(bookingReviewPurchaseVC, animated: false)
    }
}
