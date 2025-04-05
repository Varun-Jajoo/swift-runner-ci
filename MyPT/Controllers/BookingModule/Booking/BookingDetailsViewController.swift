//
//  BookingDetailsViewController.swift
//  MyPT
//
//  Created by techsaga corp on 18/12/24.
//

import UIKit

enum BookingDetailsFlow {
    case reschedule
    case upcoming
    case completed
    case cancelled
    case defaultDetails
}

class BookingDetailsViewController: CommonViewController {
   
    //MARK: ------------ VARIBALE
    var detailsFlow:BookingDetailsFlow = .defaultDetails
    
    //MARK: -----------IBOUTLET
    @IBOutlet weak var homeWorkoutMBV: UIView!
    @IBOutlet weak var homeWorkoutSubMBV: UIView!
    @IBOutlet weak var homeWorkoutTitleLbl: UILabel!
    @IBOutlet weak var homeworkoutDate: UILabel!
    @IBOutlet weak var helpBtn: UIButton!
    @IBOutlet weak var sessionOverviewMBV: UIView!
    @IBOutlet weak var sessionOverviewSubMBV: UIView!
    @IBOutlet weak var sessionTitleLbl: UILabel!
    @IBOutlet weak var sessionDateTitleLbl: UILabel!
    @IBOutlet weak var sessionDateLbl: UILabel!
    @IBOutlet weak var sessionTypeTitleLbl: UILabel!
    @IBOutlet weak var sessionTypeLbl: UILabel!
    @IBOutlet weak var sessionLocTitleLbl: UILabel!
    @IBOutlet weak var sessionLocLbl: UILabel!
    @IBOutlet weak var trainerMBV: UIView!
    @IBOutlet weak var trainerSubMBV: UIView!
    @IBOutlet weak var profileTrainerMBV: UIView!
    @IBOutlet weak var cancelledMBV:UIView!
    @IBOutlet weak var cancelRequestMBV: UIView!
    @IBOutlet weak var myTrainerTitleBtn: UIButton!
    @IBOutlet weak var trainerProfileImgV: UIImageView!
    @IBOutlet weak var trainerNameLbl: UILabel!
    @IBOutlet weak var locImgView: UIImageView!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var addressImgView: UIImageView!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var ratingBtn: UIButton!
    @IBOutlet weak var rateTrainerMBV: UIView!
    @IBOutlet weak var lineV: UIView!
    @IBOutlet weak var rateTrainerBtn: UIButton!
    @IBOutlet weak var rescheduleMBV: UIView!
    @IBOutlet weak var bookingAgainMBV: UIView!
    @IBOutlet weak var sessionSuccessfullyMBV: UIView!
    @IBOutlet weak var requestCancellledTitleLbl: UILabel!
    @IBOutlet weak var requestCancellledDateLbl: UILabel!
    @IBOutlet weak var trainerRescheduleLbl: UILabel!
    @IBOutlet weak var declineBtn: UIButton!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var emptyBtnFindsTrainer: UIButton!
    @IBOutlet weak var bookAgainBtn: UIButton!
    @IBOutlet weak var cancelrequestBtn: UIButton!
    @IBOutlet weak var sessionSuccessfullyDescLbl: UILabel!
    @IBOutlet weak var bookingDetailsMBV: UIView!
    @IBOutlet weak var bookingDetailsSubMBV: UIView!
    @IBOutlet weak var cancellationDetailsMBV: UIView!
    @IBOutlet weak var cancellationPolicyMBV: UIView!
    @IBOutlet weak var exerciseLogMBV: UIView!
    @IBOutlet weak var costMBV: UIView!
    @IBOutlet weak var bookingDetailsTitleLbl: UILabel!
    @IBOutlet weak var contactNumTitleLbl: UILabel!
    @IBOutlet weak var contactNumLbl: UILabel!
    @IBOutlet weak var amtPaidTitleLbl: UILabel!
    @IBOutlet weak var amtPaidLbl: UILabel!
    @IBOutlet weak var trainingLocTitleLbl: UILabel!
    @IBOutlet weak var trainingLocLbl: UILabel!
    @IBOutlet weak var trainingDateTitleLbl: UILabel!
    @IBOutlet weak var trainingDateLbl: UILabel!
    @IBOutlet weak var bookingRescheduleStckView: UIStackView!
    @IBOutlet weak var cancellationSubMBV: UIView!
    @IBOutlet weak var cancellationPolicySubMBV: UIView!
    @IBOutlet weak var exerciseLogSubMBV: UIView!
    @IBOutlet weak var costCreditMBV: UIView!
    @IBOutlet weak var bookingRescheduleBtn: UIButton!
    @IBOutlet weak var cancelBookingBtn: UIButton!
    @IBOutlet weak var cancellationDetailsTitleLbl: UILabel!
    @IBOutlet weak var canceledonTitleLbl: UILabel!
    @IBOutlet weak var cancellationDateLbl: UILabel!
    @IBOutlet weak var reasonTitleLbl: UILabel!
    @IBOutlet weak var reasonDescLbl: UILabel!
    @IBOutlet weak var refundTitleLbl: UILabel!
    @IBOutlet weak var refundAmtLbl: UILabel!
    @IBOutlet weak var cancellationPolicyTitleLbl: UILabel!
    @IBOutlet weak var cancellationDescLbl: UILabel!
    @IBOutlet weak var learnMoreBtn: UIButton!
    
    @IBOutlet weak var exerciseLogTitleLbl: UILabel!
    @IBOutlet weak var exercise1TitleLbl: UILabel!
    @IBOutlet weak var exercise1DescLbl: UILabel!
    @IBOutlet weak var exercise2TitleLbl: UILabel!
    @IBOutlet weak var exercise2DescLbl: UILabel!
    @IBOutlet weak var exercise3TitleLbl: UILabel!
    @IBOutlet weak var exercise3DescLbl: UILabel!
    @IBOutlet weak var exerciseLineV: UILabel!
    @IBOutlet weak var trainerFeedTitleBck: UILabel!
    @IBOutlet weak var trainerFeedBckDescLbl: UILabel!
    @IBOutlet weak var costTitleLbl: UILabel!
    @IBOutlet weak var costAmtLbl: UILabel!
    @IBOutlet weak var customerSupportBtn: UIButton!
    @IBOutlet weak var customerSupportBtnHeightConstrnt: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.setUpUI()
        self.fontSetUP()
        self.setupFlowDetails()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleData(notification:)), name: NSNotification.Name("DataSlotselected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(canceledBooking(notification:)), name: NSNotification.Name("bookingCancelled"), object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        self.setUpUI()
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
            NotificationCenter.default.removeObserver(self)
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.booking_Details], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    @objc func canceledBooking(notification: Notification){
        if let data = notification.object as? String {
            print("Received data: \(data)")
            self.cancelledMBV.isHidden = false
            self.profileTrainerMBV.isHidden = true
            self.bookingRescheduleStckView.isHidden = true
            self.cancellationPolicyMBV.isHidden = true
            self.bookingAgainMBV.isHidden = false
            self.sessionSuccessfullyDescLbl.textColor = UIColor.appWhite
            self.sessionSuccessfullyMBV.backgroundColor = UIColor(red: 169.0/255.0, green: 94.0/255.0, blue: 9.0/255.0, alpha: 1)
            
            //rgba(169, 94, 9, 1)
            
            //----------------******* Data set
            self.myTrainerTitleBtn.setImage(UIImage(named: "ic_calendarCan"), for: .normal)
            self.myTrainerTitleBtn.setTitle(AppStrings.bookingStr + " " + AppStrings.cancelled , for: .normal)
            self.myTrainerTitleBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
            self.myTrainerTitleBtn.setTitleColor(UIColor.appWhite, for: .normal)
            
            self.sessionSuccessfullyDescLbl.text = "Your booking amount will be refunded back to the source of payment withing 24 hours"
            
        }
    }
    
    @objc func handleData(notification: Notification) {
        if let data = notification.object as? String {
            print("Received data: \(data)")
            self.cancelRequestMBV.isHidden = false
            self.bookingRescheduleStckView.isHidden = true
            self.sessionSuccessfullyDescLbl.text = "Your booking will be rescheduled once the trainer approves the request."
            self.sessionSuccessfullyDescLbl.textColor = UIColor.appWhite
            self.sessionSuccessfullyMBV.backgroundColor = UIColor.appLightBlue
            
            self.myTrainerTitleBtn.setImage(UIImage(named: "ic_calendarCan"), for: .normal)
            self.myTrainerTitleBtn.setTitle(AppStrings.reschedule_Request + " " + AppStrings.pendingStr, for: .normal)
            self.myTrainerTitleBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
            self.myTrainerTitleBtn.setTitleColor(UIColor.appWhite, for: .normal)
        }
    }
    
    
    enum btntag: Int {
        case help = 2201, decline, accept, againBooking, reschedule, cancelBooking,cuctomSupprot,learMore, reviewRate, cancelRequest
    }

    //MARK: -------------COMMON BTN ACTN
    @IBAction func commonBtnActn(_ sender: UIButton) {
        
        switch sender.tag {
        case btntag.help.rawValue:
            print("Help btn clicked.")
        case btntag.decline.rawValue:
            print("Decline btn clicked.")

            self.rescheduleMBV.backgroundColor = UIColor.appLightBlue
            self.trainerRescheduleLbl.text = AppStrings.find_Trainers_DescStr
            self.declineBtn.isHidden = true
            self.acceptBtn.accessibilityHint = AppStrings.find_Trainers
            self.acceptBtn.setTitle(AppStrings.find_Trainers.uppercased(), for: .normal)
            self.acceptBtn.applyTransition(type: .moveIn, subtype: .fromRight, duration: 0.5, timingFunction: .easeInEaseOut){
                print("animation is done...")
                self.emptyBtnFindsTrainer.isHidden = false
                
            }
           
            //            let vc:CancellationPolicyViewController = CancellationPolicyViewController.instantiate(appStoryboard: .booking)
            //            vc.modalPresentationStyle = .automatic
            //            self.navigationController?.present(vc, animated: true)
            
        case btntag.accept.rawValue:
            print("Accept btn clicked.")
            
            if self.acceptBtn.accessibilityHint == AppStrings.find_Trainers {
                print("find Trainers btn clicked..")
                let vc:CreateTrainerViewController = CreateTrainerViewController.instantiate(appStoryboard: .booking)
                self.navigationController?.pushViewController(vc, animated: false)
                
            }else{
                self.rescheduleMBV.isHidden = true
                self.sessionSuccessfullyMBV.isHidden = false
                self.sessionSuccessfullyMBV.animShow(duration: 0.3, delay: 0) {
                    print("animation done..")
                }
            }
            
            //            let vc:CalendarPopViewController = CalendarPopViewController.instantiate(appStoryboard: .booking)
            //            vc.modalPresentationStyle = .automatic
            //            vc.navCtrl = self.navigationController
            //            self.navigationController?.present(vc, animated: true)
            
        case btntag.againBooking.rawValue:
            print("Again Booking btn clicked.")
            
        case btntag.reschedule.rawValue:
            print("Reschedule btn clicked.")
            let vc:FilterViewController = FilterViewController.instantiate(appStoryboard: .booking)
            vc.modalTransitionStyle = .coverVertical
            vc.flowUI = .reschedule
            vc.navFilterCtrl = self.navigationController
            self.navigationController?.present(vc, animated: true)
        
        case btntag.cancelBooking.rawValue:
            print("Cancel Booking btn clicked.")
            
            let vc:ReschedulePopViewController = ReschedulePopViewController.instantiate(appStoryboard: .booking)
            vc.modalPresentationStyle = .automatic
            vc.rescheduleNavCtrl = self.navigationController
            self.navigationController?.present(vc, animated: true)
          
        case btntag.help.rawValue:
            print("Custom Support btn clicked.")
        case btntag.learMore.rawValue:
            let vc:CancellationPolicyViewController = CancellationPolicyViewController.instantiate(appStoryboard: .booking)
            vc.modalPresentationStyle = .automatic
            self.navigationController?.present(vc, animated: true)
        case btntag.reviewRate.rawValue:
            let vc:ReviewRatePopupViewController = ReviewRatePopupViewController.instantiate(appStoryboard: .booking)
            vc.modalPresentationStyle = .automatic
            vc.navCtrl = self.navigationController
            self.navigationController?.present(vc, animated: true)
        case btntag.cancelRequest.rawValue:
            print("print cancel request btn clicked..")
            
        default:
            print("Default is called")
        }
    }
    
    
    //MARK: ---------------SETUP FLOW
    func setupFlowDetails(){
        
        self.cancelledMBV.isHidden = true
        self.cancelRequestMBV.isHidden = true
        self.emptyBtnFindsTrainer.isHidden = true
        self.myTrainerTitleBtn.setTitleColor(UIColor.txtDarkGray, for: .normal)
        self.myTrainerTitleBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        switch detailsFlow {
            
        case .reschedule:
            print("reschedule flow")
            self.sessionOverviewMBV.isHidden = true
//            self.sessionOverviewSubMBV.isHidden = true
            self.rateTrainerMBV.isHidden = true
            self.rescheduleMBV.isHidden = false
            self.bookingAgainMBV.isHidden = true
            self.sessionSuccessfullyMBV.isHidden = true
            self.bookingRescheduleStckView.isHidden = true
            self.cancellationDetailsMBV.isHidden = true
            self.cancellationPolicyMBV.isHidden = false
            self.exerciseLogMBV.isHidden = true
            self.costMBV.isHidden = true
            self.customerSupportBtn.isHidden = true
            self.customerSupportBtnHeightConstrnt.constant = 1.0
            
            //-----------------------************
            self.myTrainerTitleBtn.setImage(UIImage(named: "ic_calendarCan"), for: .normal)
            self.myTrainerTitleBtn.setTitle(AppStrings.reschedule_Request, for: .normal)
            self.myTrainerTitleBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
            self.myTrainerTitleBtn.setTitleColor(UIColor.appWhite, for: .normal)
            
        case .upcoming:
            print("upcoming flow")
            
            self.sessionOverviewMBV.isHidden = true
//            self.sessionOverviewSubMBV.isHidden = true
            self.rateTrainerMBV.isHidden = true
            self.rescheduleMBV.isHidden = true
            self.bookingAgainMBV.isHidden = true
            self.sessionSuccessfullyMBV.isHidden = false
            self.bookingRescheduleStckView.isHidden = false
            self.cancellationDetailsMBV.isHidden = true
            self.cancellationPolicyMBV.isHidden = false
            self.exerciseLogMBV.isHidden = true
            self.costMBV.isHidden = true
            self.customerSupportBtn.isHidden = true
            self.customerSupportBtnHeightConstrnt.constant = 1.0
            
            //------------***********
            self.myTrainerTitleBtn.setImage(UIImage(named: "ic_calendarCan"), for: .normal)
            self.myTrainerTitleBtn.setTitle(AppStrings.booking_Acceepted, for: .normal)
            self.myTrainerTitleBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
            self.myTrainerTitleBtn.setTitleColor(UIColor.appWhite, for: .normal)
            
            self.sessionSuccessfullyDescLbl.text = "Free cancellation/reschedule before Wed, Sep 20, 01:00 AM. Know More"
          
            self.sessionSuccessfullyDescLbl.textColor = UIColor.appLightGray
            self.sessionSuccessfullyMBV.backgroundColor = UIColor(red: 28.0/255.0, green: 31.0/255.0, blue: 33.0/255.0, alpha: 1)
           
            DispatchQueue.main.async {
                self.cancelBookingBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appRed, cornerRadious: 12.0)
            }
            
            self.cancelBookingBtn.setTitleColor(UIColor.appRed, for: .normal)
            self.cancelBookingBtn.backgroundColor = UIColor.clear
//            DispatchQueue.main.async {
//                self.cancelBookingBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appRed, cornerRadious: 12.0)
//            }
         
        case .completed:
            print("completed flow")
            self.homeWorkoutMBV.isHidden = true
            self.sessionOverviewSubMBV.isHidden = false
            self.rateTrainerMBV.isHidden = false
            self.rescheduleMBV.isHidden = true
            self.bookingAgainMBV.isHidden = true
            self.sessionSuccessfullyMBV.isHidden = true
            self.bookingRescheduleStckView.isHidden = true
            self.bookingDetailsMBV.isHidden = true
            self.cancellationDetailsMBV.isHidden = false
            self.cancellationPolicyMBV.isHidden = true
            self.exerciseLogMBV.isHidden = false
            self.costMBV.isHidden = false
            self.customerSupportBtn.isHidden = false
            self.customerSupportBtnHeightConstrnt.constant = 45.0
            
            //------------************* Data setup
            self.cancellationDetailsTitleLbl.text = "Workout Summary"
            self.canceledonTitleLbl.text = "Workout Focus"
            self.cancellationDateLbl.text = "Chest & Back"
            self.reasonTitleLbl.text = "Calories Burned"
            self.reasonDescLbl.text = "200kcal"
            self.refundTitleLbl.text = "Duration"
            self.refundAmtLbl.text = "2h 30m"
            
        case .cancelled:
            print("cancelled flow")
            
            self.sessionOverviewMBV.isHidden = true
//            self.sessionOverviewSubMBV.isHidden = true
            self.rateTrainerMBV.isHidden = true
            self.rescheduleMBV.isHidden = true
            self.bookingAgainMBV.isHidden = false
            self.sessionSuccessfullyMBV.isHidden = false
            self.bookingRescheduleStckView.isHidden = true
            self.cancellationDetailsMBV.isHidden = false
            self.cancellationPolicyMBV.isHidden = true
            self.exerciseLogMBV.isHidden = true
            self.costMBV.isHidden = true
            self.customerSupportBtn.isHidden = true
            self.customerSupportBtnHeightConstrnt.constant = 1.0
            
            //----------------******* Data set
            self.myTrainerTitleBtn.setImage(UIImage(named: "ic_calendarCan"), for: .normal)
            self.myTrainerTitleBtn.setTitle(AppStrings.session_Cancelled, for: .normal)
            self.myTrainerTitleBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
            self.myTrainerTitleBtn.setTitleColor(UIColor.appWhite, for: .normal)
            
            self.sessionSuccessfullyDescLbl.text = "Booking amount will be refunded within 24 hours of cancellation"
          
//            self.sessionSuccessfullyDescLbl.textColor = UIColor.appLightGray
//            self.sessionSuccessfullyMBV.backgroundColor = UIColor(red: 28.0/255.0, green: 31.0/255.0, blue: 33.0/255.0, alpha: 1)
            
        case .defaultDetails:
            print("defaultDetails flow")
        }
    }
    
    //MARK: ----------------SETUPUI
    func setUpUI(){
        DispatchQueue.main.async {
            self.homeWorkoutMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.helpBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            self.bookingRescheduleBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            self.cancelBookingBtn.setCornerRadius(borderWidth: 0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            self.sessionOverviewSubMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.trainerSubMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.homeWorkoutMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.rescheduleMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.declineBtn.setCornerRadius(borderWidth: 1, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            self.acceptBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.bookAgainBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.cancelrequestBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.sessionSuccessfullyMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.bookingDetailsSubMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.cancellationSubMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.cancellationSubMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.exerciseLogSubMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.costCreditMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.customerSupportBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            
        }
    }
    
    func fontSetUP(){
        self.homeWorkoutTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.homeworkoutDate.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.helpBtn.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.sessionTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.sessionDateTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.sessionDateLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.sessionTypeTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.sessionTypeLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.sessionLocTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.sessionLocLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.myTrainerTitleBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.trainerNameLbl.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.distanceLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.addressLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.ratingBtn.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.requestCancellledTitleLbl.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.requestCancellledDateLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.rateTrainerBtn.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.declineBtn.titleLabel?.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.acceptBtn.titleLabel?.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.bookAgainBtn.titleLabel?.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.cancelrequestBtn.titleLabel?.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.sessionSuccessfullyDescLbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.bookingDetailsTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.contactNumTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.contactNumLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.amtPaidTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.amtPaidLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.trainingLocTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.trainingLocLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.trainingDateTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.trainingDateLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.bookingRescheduleBtn.titleLabel?.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.cancelBookingBtn.titleLabel?.font = AppFont.bold.size(14.0, familyName: familyManrope)
        self.cancellationDetailsTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.canceledonTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.cancellationDateLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.reasonTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.reasonDescLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.refundTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.refundAmtLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.cancellationPolicyTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.cancellationDescLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.learnMoreBtn.titleLabel?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.exerciseLogTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.exercise1TitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.exercise1DescLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.exercise2TitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.exercise2DescLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.exercise3TitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.exercise3DescLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.trainerFeedTitleBck.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.trainerFeedBckDescLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.costTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.costAmtLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.customerSupportBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }

}
