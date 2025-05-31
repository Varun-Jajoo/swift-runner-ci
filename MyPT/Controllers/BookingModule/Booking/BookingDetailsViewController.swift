//
//  BookingDetailsViewController.swift
//  MyPT
//
//  Created by techsaga corp on 18/12/24.
//

import UIKit

enum BookingDetailsFlow {
    case reschedule
    case rescheduleConsumer
    case upcoming
    case completed
    case cancelled
    case defaultDetails
}

class BookingDetailsViewController: CommonViewController {
   
    //MARK: ------------ VARIBALE
    var detailsFlow:BookingDetailsFlow = .defaultDetails
    var bookingIdStr: String?
    var bookingDetailsData: BookingDetailsDataModel? = nil
    var cancelledbookingDetailsData: BookingDetailsDataModel? = nil
    
    private var acceptType: Int? = nil{
        didSet{
            if let acceptType = acceptType {
                self.bookingAcceptReject(inputIdStr: bookingIdStr, inputType: acceptType)
            }
        }
    }
    
    
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
        
        self.bookingDetails(inputId: self.bookingIdStr)
        self.setInputData()
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
        if let cancelledData = notification.object {
            //cancelledbookingDetailsData
            self.cancelledbookingDetailsData = nil
            self.cancelledbookingDetailsData  = cancelledData as? BookingDetailsDataModel
            self.bookingDetailsData = nil
            self.bookingDetailsData = self.cancelledbookingDetailsData
            
            self.cancelledMBV.isHidden = false
            self.profileTrainerMBV.isHidden = true
            self.bookingRescheduleStckView.isHidden = true
            self.cancellationPolicyMBV.isHidden = true
            self.bookingAgainMBV.isHidden = false
            self.sessionSuccessfullyDescLbl.textColor = UIColor.appWhite
            self.sessionSuccessfullyMBV.backgroundColor = UIColor(red: 169.0/255.0, green: 94.0/255.0, blue: 9.0/255.0, alpha: 1)
            
            //----------------******* Data set
            self.myTrainerTitleBtn.setImage(UIImage(named: "ic_calendarCan"), for: .normal)
            self.myTrainerTitleBtn.setTitle(AppStrings.bookingStr + " " + AppStrings.cancelled , for: .normal)
            self.myTrainerTitleBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
            self.myTrainerTitleBtn.setTitleColor(UIColor.appWhite, for: .normal)
            
            self.sessionSuccessfullyDescLbl.text = "Your booking amount will be refunded back to the source of payment withing 24 hours"
            
             //------------------ Setup data
            self.requestCancellledDateLbl.text = cancelledbookingDetailsData?.cancelledAtBooking
            self.detailsData()
        }
        
        /*
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
        */
    }
    
    @objc func handleData(notification: Notification) {
        if let data = notification.object as? String {
            print("Received data: \(data)")
            self.cancelRequestMBV.isHidden = false
            self.bookingRescheduleStckView.isHidden = true
            self.sessionSuccessfullyDescLbl.text =  data //"Your booking will be rescheduled once the trainer approves the request."
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
            
            self.bookingAcceptReject(inputIdStr: self.bookingIdStr, inputType: 2)
            
            /*
            self.rescheduleMBV.backgroundColor = UIColor.appLightBlue
            self.trainerRescheduleLbl.text = AppStrings.find_Trainers_DescStr
            self.declineBtn.isHidden = true
            self.acceptBtn.accessibilityHint = AppStrings.find_Trainers
            self.acceptBtn.setTitle(AppStrings.find_Trainers.uppercased(), for: .normal)
            self.acceptBtn.applyTransition(type: .moveIn, subtype: .fromRight, duration: 0.5, timingFunction: .easeInEaseOut){
                print("animation is done...")
                self.emptyBtnFindsTrainer.isHidden = false
                
            }
           */
            
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
                self.bookingAcceptReject(inputIdStr: self.bookingIdStr, inputType: 1)
                
                /*
                //-------------when is used to accept reschedule from trainer
                self.rescheduleMBV.isHidden = true
                self.sessionSuccessfullyMBV.isHidden = false
                self.sessionSuccessfullyMBV.animShow(duration: 0.3, delay: 0) {
                    print("animation done..")
                }
                */
            }

            
            //            let vc:CalendarPopViewController = CalendarPopViewController.instantiate(appStoryboard: .booking)
            //            vc.modalPresentationStyle = .automatic
            //            vc.navCtrl = self.navigationController
            //            self.navigationController?.present(vc, animated: true)
            
        case btntag.againBooking.rawValue:
            print("Again Booking btn clicked.")
            let vc:CreateTrainerViewController = CreateTrainerViewController.instantiate(appStoryboard: .booking)
            self.navigationController?.pushViewController(vc, animated: false)
            
        case btntag.reschedule.rawValue:
            print("Reschedule btn clicked.")
            let vc:FilterViewController = FilterViewController.instantiate(appStoryboard: .booking)
            vc.modalTransitionStyle = .coverVertical
            vc.flowUI = .reschedule
            vc.navFilterCtrl = self.navigationController
            vc.bookingIdStr =  self.bookingIdStr
            self.navigationController?.present(vc, animated: true)
        
        case btntag.cancelBooking.rawValue:
            print("Cancel Booking btn clicked.")
            
            let vc:ReschedulePopViewController = ReschedulePopViewController.instantiate(appStoryboard: .booking)
            vc.modalPresentationStyle = .automatic
            vc.rescheduleNavCtrl = self.navigationController
            vc.inputBookingIdStr = self.bookingIdStr
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
            print("BookingIdStr cancel request btn clicked..", self.bookingIdStr as Any)
            self.cancelRequestRescheduleConsumer(inputBookingId: self.bookingIdStr)
            
            /*
            AlertHelper.shared.showCustomeAlert(title: "", message: AppAlertStrings.cancel_AlertMsg, withCancel: true, completion: {[weak self] indx in
                guard let self = self, let indx = indx else { return  }
                if indx == 0{
                    self.cancelRequestRescheduleConsumer(inputBookingId: self.bookingIdStr)
                }
            })
            */
        default:
            print("Default is called")
        }
    }
    
    private func declineRescheduleTrainer(){
        self.rescheduleMBV.backgroundColor = UIColor.appLightBlue
        self.trainerRescheduleLbl.text = AppStrings.find_Trainers_DescStr
        self.declineBtn.isHidden = true
        self.acceptBtn.accessibilityHint = AppStrings.find_Trainers
        self.acceptBtn.setTitle(AppStrings.find_Trainers.uppercased(), for: .normal)
        self.acceptBtn.applyTransition(type: .moveIn, subtype: .fromRight, duration: 0.5, timingFunction: .easeInEaseOut){
            print("animation is done...")
            self.emptyBtnFindsTrainer.isHidden = false
            
        }
    }
    
    //MARK: ------------INPUT DATA SETUP
    private func setInputData(){
       
        switch detailsFlow {
        case .reschedule:
            print("reschedule flow")
            self.trainerRescheduleLbl.text = bookingDetailsData?.msg
            self.detailsData()
            
        case .rescheduleConsumer:
            print("rescheduleConsumer")
            self.cancelRequestMBV.isHidden = false
            self.bookingRescheduleStckView.isHidden = true
            self.rescheduleMBV.isHidden = true
            self.sessionSuccessfullyMBV.isHidden = false
            self.sessionSuccessfullyDescLbl.text = "Your booking will be rescheduled once the trainer approves the request."
            self.sessionSuccessfullyDescLbl.textColor = UIColor.appWhite
            self.sessionSuccessfullyMBV.backgroundColor = UIColor.appLightBlue
            
            self.myTrainerTitleBtn.setImage(UIImage(named: "ic_calendarCan"), for: .normal)
            self.myTrainerTitleBtn.setTitle(AppStrings.reschedule_Request + " " + AppStrings.pendingStr, for: .normal)
            self.myTrainerTitleBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
            self.myTrainerTitleBtn.setTitleColor(UIColor.appWhite, for: .normal)
            
            self.detailsData()
            
        case .upcoming:
            print("upcoming flow")
//            self.trainerRescheduleLbl.text = bookingDetailsData?.cancellationPolicyMsg
            self.sessionSuccessfullyDescLbl.text = bookingDetailsData?.cancellationPolicyMsg
            self.detailsData()
            
        case .completed:
            print("completed flow")
            
            //-----------************* SESSION DATA SETUP
            self.sessionDateLbl.text = bookingDetailsData?.bookingDetail?.trainingDate
            self.sessionTypeLbl.text = (bookingDetailsData?.bookingDetail?.type ?? "").localizedCapitalized + " Workout"
            self.sessionLocLbl.text = bookingDetailsData?.bookingDetail?.location
            
            //------------************* WORKOUT SUMMARY
            self.cancellationDetailsTitleLbl.text = "Workout Summary"
            self.canceledonTitleLbl.text = "Workout Focus"
            self.cancellationDateLbl.text = "" //"Chest & Back"
            self.reasonTitleLbl.text = "Calories Burned"
            self.reasonDescLbl.text = "" //"200kcal"
            self.refundTitleLbl.text = "Duration"
            self.refundAmtLbl.text = "" //"2h 30m"
            
            //------------************ EXERCISE LOG DETAILS
            self.exerciseLogTitleLbl.text = "Exercise Log"
            self.exercise1TitleLbl.text = "Exercise 1"
            self.exercise1DescLbl.text = ""
            self.exercise2TitleLbl.text = "Exercise 2"
            self.exercise2DescLbl.text = ""
            self.exercise3TitleLbl.text = "Exercise 3"
            self.exercise3DescLbl.text = ""
            
            self.costAmtLbl.text = bookingDetailsData?.bookingDetail?.price
            
            self.detailsData()
            
        case .cancelled:
            print("cancelled flow")
            
            self.cancellationDateLbl.text = bookingDetailsData?.cancellationDetail?.cancelledOn
            self.reasonDescLbl.text = bookingDetailsData?.cancellationDetail?.reason
            self.refundAmtLbl.text = bookingDetailsData?.cancellationDetail?.refundAmount
            self.detailsData()
            
        case .defaultDetails:
            print("defaultDetails flow")
        }
        
       
        
        /*
         self.sessionTitleLbl.text = ""
         self.sessionDateTitleLbl.text = ""
         self.sessionDateLbl.text = ""
         self.sessionTypeTitleLbl.text = ""
         self.sessionTypeLbl.text = ""
         self.sessionLocTitleLbl.text = ""
         self.sessionLocLbl.text = ""
         self.requestCancellledTitleLbl.text = ""
         self.requestCancellledDateLbl.text = ""
         self.sessionSuccessfullyDescLbl.text = ""
         self.bookingDetailsTitleLbl.text = ""
         self.contactNumTitleLbl.text = ""
         self.cancellationDetailsTitleLbl.text = ""
         self.canceledonTitleLbl.text = ""
         self.cancellationDateLbl.text = ""
         self.reasonTitleLbl.text = ""
         self.reasonDescLbl.text = ""
         self.refundTitleLbl.text = ""
         self.refundAmtLbl.text = ""
         self.cancellationPolicyTitleLbl.text = ""
         self.cancellationDescLbl.text = ""
         self.exerciseLogTitleLbl.text = ""
         self.exercise1TitleLbl.text = ""
         self.exercise1DescLbl.text = ""
         self.exercise2TitleLbl.text = ""
         self.exercise2DescLbl.text = ""
         self.exercise3TitleLbl.text = ""
         self.exercise3DescLbl.text = ""
         self.trainerFeedTitleBck.text = ""
         self.trainerFeedBckDescLbl.text = ""
         self.costTitleLbl.text = ""
         self.costAmtLbl.text = ""
         */
    }
    
    private func detailsData(){
        self.homeWorkoutTitleLbl.text = (bookingDetailsData?.bookingDetail?.type?.localizedCapitalized ?? "") + " Workout"
        self.homeworkoutDate.text = bookingDetailsData?.bookedAt
        self.trainerProfileImgV.loadImage(urlString: bookingDetailsData?.trainerDetail?.profile, placeholder: UIImage(named: ""))
        self.trainerNameLbl.text = bookingDetailsData?.trainerDetail?.name
        self.distanceLbl.text = bookingDetailsData?.trainerDetail?.distance
        self.addressLbl.text = bookingDetailsData?.trainerDetail?.location
        self.ratingBtn.setTitle(bookingDetailsData?.trainerDetail?.averageRating, for: .normal)
        self.contactNumLbl.text = bookingDetailsData?.bookingDetail?.contact
        self.amtPaidLbl.text = bookingDetailsData?.bookingDetail?.price
        self.trainingLocLbl.text = bookingDetailsData?.bookingDetail?.location
        self.trainingDateLbl.text = bookingDetailsData?.bookingDetail?.trainingDate
    }
    
    //MARK: ---------------SETUP FLOW
    private func setupFlowDetails(){
        
        self.cancelledMBV.isHidden = true
        self.cancelRequestMBV.isHidden = true
        self.emptyBtnFindsTrainer.isHidden = true
        self.myTrainerTitleBtn.setTitleColor(UIColor.txtDarkGray, for: .normal)
        self.myTrainerTitleBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        switch detailsFlow {
            
        case .reschedule, .rescheduleConsumer:
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
            
//            self.sessionSuccessfullyDescLbl.text = "Free cancellation/reschedule before Wed, Sep 20, 01:00 AM. Know More"
          
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
            
            /*
            //------------************* Data setup
            self.cancellationDetailsTitleLbl.text = "Workout Summary"
            self.canceledonTitleLbl.text = "Workout Focus"
            self.cancellationDateLbl.text = "Chest & Back"
            self.reasonTitleLbl.text = "Calories Burned"
            self.reasonDescLbl.text = "200kcal"
            self.refundTitleLbl.text = "Duration"
            self.refundAmtLbl.text = "2h 30m"
            */
            
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
            
            self.trainerProfileImgV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12)
            
            [
                self.helpBtn,
                self.bookingRescheduleBtn,
                self.declineBtn,
                self.customerSupportBtn
            ].forEach({[weak self] in
                guard self != nil else { return }
                $0.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
            })
            
            //--------------------*********
            [
                self.homeWorkoutMBV,
                self.sessionOverviewSubMBV,
                self.trainerSubMBV,
                self.homeWorkoutMBV,
                self.rescheduleMBV,
                self.acceptBtn,
                self.bookAgainBtn,
                self.cancelBookingBtn,
                self.cancelrequestBtn,
                self.sessionSuccessfullyMBV,
                self.bookingDetailsSubMBV,
                self.cancellationSubMBV,
                self.cancellationSubMBV,
                self.exerciseLogSubMBV,
                self.costCreditMBV
            ].forEach({[weak self] in
                guard self != nil else { return  }
                $0?.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            })
            
            self.exerciseLineV.backgroundColor = UIColor.clear
            self.lineV.backgroundColor = UIColor.clear
            self.exerciseLineV.addGradient(colors: UIColor.appMultiColor(.lineVGradient), locations: [0,0.5,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 0.2)
            self.lineV.addGradient(colors: UIColor.appMultiColor(.lineVGradient), locations: [0,0.5,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 0.2)
        }
    }
    
    func fontSetUP(){
        self.customerSupportBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        //_____________________#################
        [
            self.homeworkoutDate,
            self.distanceLbl,
            self.addressLbl,
            self.ratingBtn.titleLabel,
            self.requestCancellledDateLbl,
            self.sessionSuccessfullyDescLbl
        ].forEach({ [weak self] in
            guard self != nil else { return }
            $0?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        })
        
        //____________________################
        [
            self.trainerNameLbl,
            self.requestCancellledTitleLbl,
            self.declineBtn.titleLabel,
            self.acceptBtn.titleLabel,
            self.bookAgainBtn.titleLabel,
            self.cancelrequestBtn.titleLabel,
            self.bookingRescheduleBtn.titleLabel,
            self.cancelBookingBtn.titleLabel
        ].forEach({[weak self] in
            guard self != nil else { return  }
            $0?.font = AppFont.bold.size(14.0, familyName: familyManrope)
        })
        
        //____________________################
        [
            self.homeWorkoutTitleLbl,
            self.sessionTitleLbl,
            self.myTrainerTitleBtn.titleLabel,
            self.bookingDetailsTitleLbl,
            self.cancellationDetailsTitleLbl,
            self.cancellationPolicyTitleLbl,
            self.exerciseLogTitleLbl
        ].forEach({[weak self] in
            guard self != nil else { return  }
            $0?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        })
        
        //____________________################
        [
            self.helpBtn.titleLabel,
            self.sessionDateLbl,
            self.sessionDateTitleLbl,
            self.sessionTypeTitleLbl,
            self.costAmtLbl,
            self.sessionTypeLbl,
            self.sessionLocTitleLbl,
            self.sessionLocLbl,
            self.rateTrainerBtn.titleLabel,
            self.contactNumTitleLbl,
            self.contactNumLbl,
            self.amtPaidTitleLbl,
            self.amtPaidLbl,
            self.trainingLocTitleLbl,
            self.trainingLocLbl,
            self.trainingDateTitleLbl,
            self.trainingDateLbl,
            self.canceledonTitleLbl,
            self.cancellationDateLbl,
            self.reasonTitleLbl,
            self.reasonDescLbl,
            self.refundTitleLbl,
            self.refundAmtLbl,
            self.cancellationDescLbl,
            self.learnMoreBtn.titleLabel,
            self.exercise1TitleLbl,
            self.exercise1DescLbl,
            self.exercise2TitleLbl,
            self.exercise2DescLbl,
            self.exercise3TitleLbl,
            self.exercise3DescLbl,
            self.trainerFeedTitleBck,
            self.trainerFeedBckDescLbl,
            self.costTitleLbl,
            self.costAmtLbl
        ].forEach({[weak self] in
            guard self != nil else { return  }
            $0?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        })
    }

}

//MARK: --------------------EXTENSION FOR API
extension BookingDetailsViewController{
    
    //MARK: -------------------------BOOKING DETAILS API
    private func bookingDetails(inputId: String?){
        if let lat = appUserDefaults.getLatLong()?.components(separatedBy: ",").first,  let long = appUserDefaults.getLatLong()?.components(separatedBy: ",").last{
           
            let params:[String:String] = [
                "id": inputId ?? "",
                "long": long,
                "lat": lat
            ]
            
            BookingVM.bookingDetailsApi(inputParams: params, completion: {[weak self] getResultData in
                guard let self = self, let getResultData = getResultData else { return  }
                print("getResultData: ", getResultData)
                self.bookingDetailsData = getResultData.data
                self.setInputData()
            })
        }
        
    }
    
    private func bookingAcceptReject(inputIdStr: String? , inputType: Int){
        let params:[String:Any] = [
            "id": inputIdStr ?? "", //id:1 , session id is required
            "type": inputType  // type:2 , 1=>accept , 2=>cancel
        ]
      
        BookingVM.acceptRejectBookingApi(inputParams: params, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
            print("getResultData: ", getResultData)
            
            if getResultData["status"] as? Bool == true {
                let detailData = getResultData["data"] as? [String:Any]
                let msgStr = detailData?["msg"] as? String //get date
               
                //------------flow accept/declone
                if let typeStr = detailData?["type"] as? String, typeStr.uppercased() == "accept".uppercased(){
                    self.sessionSuccessfullyDescLbl.text = "Your session has been successfully rescheduled to \(msgStr ?? "") We look forward to seeing you then!"
                    //"Your session has been successfully rescheduled to 3rd Jan, 2024 | 10:30 PM. We look forward to seeing you then!"
                    //-------------------------**************
                    self.rescheduleMBV.isHidden = true
                    self.sessionSuccessfullyMBV.isHidden = false
                    self.sessionSuccessfullyMBV.animShow(duration: 0.3, delay: 0) {
                        print("animation done..")
                    }
                    
                }else{
                    self.declineRescheduleTrainer()
                }
            }
        })
    }
    
    private func cancelRequestRescheduleConsumer(inputBookingId: String?){
        BookingVM.cancelRequstConsumerRescheduleApi(inputId: inputBookingId, completion: {[weak self] getResultData in
            guard let self = self else { return }
            
            self.navigationController?.popViewController(animated: true)
        })
    }
}
