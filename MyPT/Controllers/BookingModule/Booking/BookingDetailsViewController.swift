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
    case bookingConfirm
    case defaultDetails
}

class BookingDetailsViewController: CommonViewController {
   
    //MARK: ------------ VARIBALE
    var inputBookSlotParams:BookSlotParamsModel? = nil
    var detailsFlow:BookingDetailsFlow = .defaultDetails
    var bookingIdStr: String?
    var typeStr: String?
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
    @IBOutlet weak var bookingStatusMBV: UIView!
    @IBOutlet weak var profileTrainerMBV: UIView!
    @IBOutlet weak var cancelledMBV:UIView!
    @IBOutlet weak var cancelRequestMBV: UIView!
    @IBOutlet weak var myTrainerTitleBtn: UIButton!
    @IBOutlet weak var bookingStatusBtn: UIButton!
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
    @IBOutlet weak var trackTrainerBtn: UIButton!
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
    @IBOutlet weak var cancelledOnMBV: UIView!
    @IBOutlet weak var cancelReasonMBV: UIView!
    @IBOutlet weak var cancelRefundMBV: UIView!
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
    @IBOutlet weak var customerSupportMBV: UIView!
    @IBOutlet weak var customerSupportBtn: UIButton!
    @IBOutlet weak var customerSupportBtnHeightConstrnt: NSLayoutConstraint!
    
    @IBOutlet weak var bookingQRMBV: UIView!
    @IBOutlet weak var bookingQRBtn: UIButton!
    
    @IBOutlet weak var locationMBV: UIView!
    @IBOutlet weak var locationSubMBV: UIView!
    @IBOutlet weak var locationTitleLbl: UILabel!
    @IBOutlet weak var locAddrsDescLbl: UILabel!
    @IBOutlet weak var locationEditBtn: UIButton!
    
    @IBOutlet weak var ptChargeMBV: UIView!
    @IBOutlet weak var showPTChargeBtn: UIButton!
    @IBOutlet weak var paymentMBV: UIView!
    @IBOutlet weak var freeAmtLbl: UILabel!
    @IBOutlet weak var breakDownLbl: UILabel!
    @IBOutlet weak var confirmBookingBtn: UIButton!
    @IBOutlet weak var trainerDetailsBottomConstrnt: NSLayoutConstraint!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.setUpUI()
        self.fontSetUP()
        self.setupFlowDetails()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleData(notification:)), name: NSNotification.Name("DataSlotselected"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(canceledBooking(notification:)), name: NSNotification.Name("bookingCancelled"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showDeliveryAddress(notification:)), name: NSNotification.Name("presenteDeliveryAddress"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getRatingData(notification:)), name: NSNotification.Name("getRatingData"), object: nil)
        
        self.bookingDetails(inputId: self.bookingIdStr)
        self.setInputData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setUpUI()
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
            self.bookingQRMBV.isHidden = true
            self.bookingQRBtn.isHidden = true
            self.cancelRefundMBV.isHidden = true
            
            self.cancelledbookingDetailsData = nil
            self.cancelledbookingDetailsData  = cancelledData as? BookingDetailsDataModel
            self.bookingDetailsData = nil
            self.bookingDetailsData = self.cancelledbookingDetailsData
            
            self.cancelledMBV.isHidden = false
            self.profileTrainerMBV.isHidden = true
            self.bookingRescheduleStckView.isHidden = true
            self.cancellationPolicyMBV.isHidden = true
            self.bookingAgainMBV.isHidden = false
            self.bookAgainBtn.isHidden = false
            self.trackTrainerBtn.isHidden = true
            self.cancelRequestMBV.isHidden = true
            self.cancelrequestBtn.isHidden = true
            self.sessionSuccessfullyDescLbl.textColor = UIColor.appWhite
            self.sessionSuccessfullyMBV.backgroundColor = UIColor(red: 169.0/255.0, green: 94.0/255.0, blue: 9.0/255.0, alpha: 1)
            
            //----------------******* Data set
            self.myTrainerTitleBtn.setImage(nil, for: .normal)
            self.myTrainerTitleBtn.setTitle(nil, for: .normal)
            self.myTrainerTitleBtn.isHidden = true
            
            self.bookingStatusBtn.setImage(UIImage(named: "ic_calendarCan"), for: .normal)
            self.bookingStatusBtn.setTitle(AppStrings.bookingStr + " " + AppStrings.cancelled , for: .normal)
            self.bookingStatusBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
            self.bookingStatusBtn.setTitleColor(UIColor.appWhite, for: .normal)
            
            self.sessionSuccessfullyDescLbl.text = cancelledbookingDetailsData?.bookingDetail?.msg?.value //"Your booking amount will be refunded back to the source of payment withing 24 hours"
            
             //------------------ Setup data
            self.requestCancellledDateLbl.text = "On " + (cancelledbookingDetailsData?.cancelledAtBooking?.value ?? "")
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
            self.cancelrequestBtn.isHidden = false
            self.trackTrainerBtn.isHidden = true
            self.bookingRescheduleStckView.isHidden = true
            self.sessionSuccessfullyDescLbl.text =  data //"Your booking will be rescheduled once the trainer approves the request."
            self.sessionSuccessfullyDescLbl.textColor = UIColor.appWhite
            self.sessionSuccessfullyMBV.backgroundColor = UIColor.appLightBlue
                        
            self.myTrainerTitleBtn.setImage(nil, for: .normal)
            self.myTrainerTitleBtn.setTitle(nil, for: .normal)
            self.myTrainerTitleBtn.isHidden = true
            
            self.bookingStatusBtn.setImage(UIImage(named: "ic_calendarCan"), for: .normal)
            self.bookingStatusBtn.setTitle(AppStrings.reschedule_Request + " " + AppStrings.pendingStr, for: .normal)
            self.bookingStatusBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
            self.bookingStatusBtn.setTitleColor(UIColor.appWhite, for: .normal)
            
        }
    }
    
    @objc func showDeliveryAddress(notification: Notification){
        if let _ = notification.object {
            self.showDeliveryAdd()
        }
    }
    
    @objc func getRatingData(notification: Notification){
        print(notification.object as? [String: Any] as Any)
        self.rateTrainerMBV.isHidden = true
        self.bookingDetails(inputId: self.bookingIdStr)
        
//        if let ratingData = notification.object as? [String: Any],
//           let resultData = ratingData["data"] as? [String: Any], let ratingVal = resultData["rating"] {
//             // Now you can use ratingV safely
//            print("Rating Data: \(ratingVal)")
//            self.rateTrainerMBV.isHidden = true
//            self.ratingBtn.setTitle("\(ratingVal)", for: .normal)
//         }
    }
    
    enum btntag: Int {
        case help = 2201, decline, accept, againBooking, reschedule, cancelBooking,cuctomSupprot,learMore, reviewRate, cancelRequest, bookingQR, trackTrainer, confirmBooking, editLocation
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
                let vc: CreateTrainerViewController = CreateTrainerViewController.instantiate(appStoryboard: .booking)
                self.navigationController?.pushViewController(vc, animated: false)
            } else {
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
            vc.cancellationDetails = bookingDetailsData?.cancellationPolicy
            self.navigationController?.present(vc, animated: true)
        case btntag.reviewRate.rawValue:
            let vc:ReviewRatePopupViewController = ReviewRatePopupViewController.instantiate(appStoryboard: .booking)
            vc.modalPresentationStyle = .automatic
            vc.navCtrl = self.navigationController
            vc.inputBookingId = self.bookingDetailsData?.booking_id?.value
            vc.inputTrainerId = self.bookingDetailsData?.trainerDetail?.trainer_id?.value
//            vc.navCtrl = self.navigationController
            self.present(vc, animated: true)
//            self.navigationController?.present(vc, animated: true)
            
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
            
        case btntag.bookingQR.rawValue:
            if let qrStr = bookingDetailsData?.bookingDetail?.qr?.value {
                let vc: BookingDetailsQRViewController = BookingDetailsQRViewController.instantiate(appStoryboard: .booking)
                vc.qrUrlStr = qrStr
                vc.modalPresentationStyle = .automatic
                self.present(vc, animated: true)
            }
            
            
        case btntag.trackTrainer.rawValue:
            let vc:ArrivingViewController = ArrivingViewController.instantiate(appStoryboard: .library)
            vc.inputBookingId = self.bookingIdStr
            self.navigationController?.pushViewController(vc, animated: true)
            
        case btntag.confirmBooking.rawValue:
            /*
             booking_id=>12(when accept/confirm of request),
             price=>123(if isPakcage is not true , then price else empty),
             transaction_id=>' when isPackage false , payment done,
             payment_type=>when isPackage false ,ccavenue, tabby,tamara(previous same),
             isPackage is in booking detail response
             */
            
            self.inputBookSlotParams = BookSlotParamsModel(type: bookingDetailsData?.bookingDetail?.type?.value, slot_id: bookingDetailsData?.slot_id?.value, address_id: bookingDetailsData?.bookingDetail?.address_id?.value, booking_id: bookingDetailsData?.booking_id?.value)
            
            if let isPackage = self.bookingDetailsData?.isPackage, isPackage{
                print("Goes to Welcome screen.....")
                print("booking Confirm Params: ",inputBookSlotParams?.getParams() ?? [:])
                self.bookSlot(inputParam: inputBookSlotParams?.getParams() ?? [:])
            }else{
                // Payment method flow setup
                if let pricePackage = self.bookingDetailsData?.price?.value,  let mainPrice = self.bookingDetailsData?.main_price?.value, let taxesRate = self.bookingDetailsData?.tax_amount?.value {
        //            let components = pricePackage.split(separator: " ")
                    let vc: PaymentMethodsViewController = PaymentMethodsViewController.instantiate(appStoryboard: .booking)
                    vc.totalPayableStr = pricePackage
                    vc.taxesStr = "\(taxesRate)"
                    vc.sessionCost = "\(mainPrice)"
                    
                    vc.paymentSuccess = {[weak self] (getStatus, getTransactionId, paymetMethod) in
                        guard let self = self else { return  }
                        
                        if paymetMethod == "ccavenue" {
                            if let pricePackage = self.bookingDetailsData?.bookingPrice?.value  {
                                let components = pricePackage.split(separator: " ")
                                let vc: CCAvenuePaymentViewController = CCAvenuePaymentViewController.instantiate(appStoryboard: .booking)
                                vc.modalPresentationStyle = .overFullScreen
                                vc.costAmt =  Double(components.first ?? "0.0")
                                
//                                vc.paymentSuccess = {[weak self] (getStatus, getTransactionId) in
//                                    guard let self = self, let getTransactionId = getTransactionId  else { return  }
//                                    inputBookSlotParams?.transaction_id = getTransactionId
//                                    inputBookSlotParams?.price = pricePackage
//                                    inputBookSlotParams?.payment_type = paymetMethod
//                                   
//                                    print("booking Confirm Params: ",inputBookSlotParams?.getParams() ?? [:])
//                                    
//                                    self.bookSlot(inputParam: inputBookSlotParams?.getParams() ?? [:])
//                                }
                                self.navigationController?.present(vc, animated: true)
                            }
                        }
                        else if paymetMethod == "tabby" {
                            inputBookSlotParams?.transaction_id = getTransactionId
                            inputBookSlotParams?.price = pricePackage
                            inputBookSlotParams?.payment_type = paymetMethod
                            
                            print("booking Confirm Params: ",inputBookSlotParams?.getParams() ?? [:])
                            self.bookSlot(inputParam: inputBookSlotParams?.getParams() ?? [:])
                        }
                    }
                    self.navigationController?.pushViewController(vc, animated: false)
                }
            }
            
            /*
            let vc:PaymentSuccessViewController = PaymentSuccessViewController.instantiate(appStoryboard: .booking)
//            vc.bookedDataModel = getResultData.data
            vc.billingViewFlow = .upcomingClass
            self.navigationController?.pushViewController(vc, animated: true)
            
            */
            
        case btntag.editLocation.rawValue:
            print("Edit location btn clicked..")
            self.showDeliveryAdd()
            
        default:
            print("Default is called")
        }
    }
    
    private func showDeliveryAdd(){
        let vc: SelectAddressPopupViewController = SelectAddressPopupViewController.instantiate(appStoryboard: .shop)
        vc.modalPresentationStyle = .automatic
        vc.makeAddrFlow = .editLocation
        vc.navCtrl = self.navigationController
        self.present(vc, animated: true)
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
    
    
    private func detailsData(){
        self.homeWorkoutTitleLbl.text = (bookingDetailsData?.bookingDetail?.type?.value?.localizedCapitalized ?? "") + " Workout"
        self.homeworkoutDate.text = bookingDetailsData?.bookedAt?.value
        self.trainerProfileImgV.loadImage(urlString: bookingDetailsData?.trainerDetail?.profile, placeholder: UIImage(named: "ic_profile_placeholder"))
        self.trainerNameLbl.text = bookingDetailsData?.trainerDetail?.name
        self.distanceLbl.text = bookingDetailsData?.trainerDetail?.distance
        self.addressLbl.text = bookingDetailsData?.trainerDetail?.location
        self.ratingBtn.setTitle(bookingDetailsData?.trainerDetail?.averageRating?.value, for: .normal)
        self.contactNumLbl.text = bookingDetailsData?.bookingDetail?.contact?.value
        self.amtPaidLbl.text = bookingDetailsData?.bookingDetail?.price?.value
        self.trainingLocLbl.text = bookingDetailsData?.bookingDetail?.location?.value
        self.trainingDateLbl.text = bookingDetailsData?.bookingDetail?.trainingDate?.value
        
//        self.bookingQRBtn.loadImage(urlString: bookingDetailsData?.bookingDetail?.qr?.value, placeholder: nil, imageSize: CGSize(width: 25.0, height: 25.0))
//        self.bookingQRBtn.setTitle("  " + AppStrings.booking_QR_code, for: .normal)
        bookingQRBtn.isUserInteractionEnabled = false
        self.bookingQRBtn.setTitle("Session OTP: " + (bookingDetailsData?.bookingDetail?.otp?.value ?? ""), for: .normal)
    }
    
    //MARK: ------------INPUT DATA SETUP
    private func setInputData(){
        switch detailsFlow {
        case .reschedule:
            print("reschedule flow")
            self.trainerRescheduleLbl.text = bookingDetailsData?.msg?.value
            self.detailsData()
            
        case .rescheduleConsumer:
            print("rescheduleConsumer")
            self.cancelRequestMBV.isHidden = false
            self.trackTrainerBtn.isHidden = true
            self.bookingRescheduleStckView.isHidden = true
            self.rescheduleMBV.isHidden = true
            self.sessionSuccessfullyMBV.isHidden = false
            self.sessionSuccessfullyDescLbl.text = "Your booking will be rescheduled once the trainer approves the request."
            self.sessionSuccessfullyDescLbl.textColor = UIColor.appWhite
            self.sessionSuccessfullyMBV.backgroundColor = UIColor.appLightBlue
            
            self.bookingStatusBtn.setImage(UIImage(named: "ic_calendarCan"), for: .normal)
            self.bookingStatusBtn.setTitle(AppStrings.reschedule_Request + " " + AppStrings.pendingStr, for: .normal)
            self.bookingStatusBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
            self.bookingStatusBtn.setTitleColor(UIColor.appWhite, for: .normal)
            
            self.cancellationDescLbl.text = bookingDetailsData?.cancellationPolicy?.shortDescription?.value
            
            self.detailsData()
            
        case .upcoming:
            print("upcoming flow")
//            self.trainerRescheduleLbl.text = bookingDetailsData?.cancellationPolicyMsg
        
            if let cancellationPolicyMsg = bookingDetailsData?.cancellationPolicyMsg?.value, !cancellationPolicyMsg.isEmpty {
                self.sessionSuccessfullyMBV.isHidden = false
                self.sessionSuccessfullyDescLbl.text = cancellationPolicyMsg
            }else{
                self.sessionSuccessfullyMBV.isHidden = true
            }
            
            self.cancellationDescLbl.text = bookingDetailsData?.cancellationPolicy?.shortDescription?.value
          
            self.detailsData()
            
        case .completed:
            print("completed flow")
            
            //-----------************* SESSION DATA SETUP
            self.sessionDateLbl.text = bookingDetailsData?.bookingDetail?.trainingDate?.value
            self.sessionTypeLbl.text = (bookingDetailsData?.bookingDetail?.type?.value ?? "").localizedCapitalized + " Workout"
            self.sessionLocLbl.text = bookingDetailsData?.bookingDetail?.location?.value
            
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
            
            self.costAmtLbl.text = bookingDetailsData?.bookingDetail?.price?.value
            
            self.detailsData()
            
        case .cancelled:
            print("cancelled flow")
            self.bookingQRMBV.isHidden = true
            self.bookingQRBtn.isHidden = true
            self.cancelRefundMBV.isHidden = true
            self.cancellationDateLbl.text = bookingDetailsData?.cancellationDetail?.cancelledOn
            self.reasonDescLbl.text = bookingDetailsData?.cancellationDetail?.reason
            self.refundAmtLbl.text = bookingDetailsData?.cancellationDetail?.refundAmount?.value
            self.sessionSuccessfullyDescLbl.text = bookingDetailsData?.cancellationDetail?.msg?.value  // "Booking amount will be refunded within 24 hours of cancellation"
            
            self.detailsData()
            
        case .bookingConfirm:
            print("Booking Confirm...")
            //-------------------------- Data setup
             self.trainerNameLbl.text = bookingDetailsData?.trainerDetail?.name
            self.setPTBalancePayAmtAttr(priceStr: bookingDetailsData?.bookingPrice?.value)
            self.distanceLbl.text = bookingDetailsData?.trainerDetail?.distance
            self.addressLbl.text = bookingDetailsData?.trainerDetail?.location
            self.ratingBtn.setTitle(bookingDetailsData?.trainerDetail?.averageRating?.value, for: .normal)
             
             //cancellationDetailsMBV = sessionOverviewSubMBV (Session Overview)
             self.cancellationDetailsTitleLbl.text = "Session Overview"
             self.canceledonTitleLbl.text = "Date & Time"
            self.cancellationDateLbl.text = bookingDetailsData?.bookingDetail?.trainingDate?.value
             self.reasonTitleLbl.text = "Session Type"
            self.reasonDescLbl.text = (bookingDetailsData?.bookingDetail?.type?.value ?? "").localizedCapitalized + " Session"
             self.refundTitleLbl.text = "Training preference"
            self.refundAmtLbl.text = (bookingDetailsData?.trainingPrefernce?.value ?? "").localizedCapitalized
            self.locAddrsDescLbl.text = bookingDetailsData?.bookingDetail?.location?.value
            self.costAmtLbl.text = (bookingDetailsData?.bookingPrice?.value ?? "") + " Credit"
            
            if let typeBooking = bookingDetailsData?.bookingDetail?.type?.value, typeBooking.lowercased() == "home" {
                self.locationEditBtn.isHidden = false
            }else{
                self.locationEditBtn.isHidden = true
            }
            
            //------------PACKAGE 1PT BALANCE
            if let isPackage = self.bookingDetailsData?.isPackage, isPackage{
                self.ptChargeMBV.isHidden = false
                self.confirmBookingBtn.setTitle("CONFIRM BOOKING", for: .normal)
            }else{
                self.ptChargeMBV.isHidden = true
                self.confirmBookingBtn.setTitle("CONFIRM & PAY", for: .normal)
            }
            
            //------------RATING VIEW
            if let isReviewed = self.bookingDetailsData?.isAlreadyReview, isReviewed{
                self.rateTrainerMBV.isHidden = true
            }else{
                self.rateTrainerMBV.isHidden = false
            }
            
        case .defaultDetails:
            print("defaultDetails flow")
        }
    }
    
    //MARK: ---------------SETUP FLOW
    private func setupFlowDetails(){
        
        self.trainerDetailsBottomConstrnt.constant = 27.0
        self.locationMBV.isHidden = true
        self.ptChargeMBV.isHidden = true
        self.paymentMBV.isHidden = true
        self.bookingStatusMBV.isHidden = false
        self.cancelledMBV.isHidden = true
        self.cancelRequestMBV.isHidden = true
        self.emptyBtnFindsTrainer.isHidden = true
        self.myTrainerTitleBtn.setTitleColor(UIColor.txtDarkGray, for: .normal)
        self.myTrainerTitleBtn.setImage(nil, for: .normal)
        self.myTrainerTitleBtn.setTitle(nil, for: .normal)
        self.myTrainerTitleBtn.isHidden = true
        self.myTrainerTitleBtn.contentEdgeInsets = UIEdgeInsets(top: 1, left: 0, bottom: 0, right: 0)
      
        switch detailsFlow {
            
        case .reschedule, .rescheduleConsumer:
            print("reschedule flow")
            self.sessionOverviewMBV.isHidden = true
//            self.sessionOverviewSubMBV.isHidden = true
            self.rateTrainerMBV.isHidden = true
            self.rescheduleMBV.isHidden = false
            self.bookingAgainMBV.isHidden = true
            self.trackTrainerBtn.isHidden = true
            self.sessionSuccessfullyMBV.isHidden = true
            self.bookingRescheduleStckView.isHidden = true
            self.cancellationDetailsMBV.isHidden = true
            self.cancellationPolicyMBV.isHidden = false
            self.exerciseLogMBV.isHidden = true
            self.costMBV.isHidden = true
            self.customerSupportMBV.isHidden = true
            self.customerSupportBtn.isHidden = true
            self.customerSupportBtnHeightConstrnt.constant = 1.0
        
            //-----------------------************
            self.bookingStatusBtn.setImage(UIImage(named: "ic_calendarCan"), for: .normal)
            self.bookingStatusBtn.setTitle(AppStrings.reschedule_Request, for: .normal)
            self.bookingStatusBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
            self.bookingStatusBtn.setTitleColor(UIColor.appWhite, for: .normal)
            
        case .upcoming:
            print("upcoming flow")
        
            self.sessionOverviewMBV.isHidden = true
//            self.sessionOverviewSubMBV.isHidden = true
            self.rateTrainerMBV.isHidden = true
            self.rescheduleMBV.isHidden = true
            self.bookingAgainMBV.isHidden = true
            self.bookAgainBtn.isHidden = true
            self.cancelRequestMBV.isHidden = false
            self.cancelrequestBtn.isHidden = true
            self.trackTrainerBtn.isHidden = false
            self.sessionSuccessfullyMBV.isHidden = false
            self.bookingRescheduleStckView.isHidden = false
            self.cancellationDetailsMBV.isHidden = true
            self.cancellationPolicyMBV.isHidden = false
            self.exerciseLogMBV.isHidden = true
            self.costMBV.isHidden = true
            self.customerSupportMBV.isHidden = true
            self.customerSupportBtn.isHidden = true
            self.customerSupportBtnHeightConstrnt.constant = 1.0
            
    
            //------------***********
            self.bookingStatusBtn.setImage(UIImage(named: "ic_calendarCan"), for: .normal)
            self.bookingStatusBtn.setTitle(AppStrings.booking_Accepted, for: .normal)
            self.bookingStatusBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
            self.bookingStatusBtn.setTitleColor(UIColor.appWhite, for: .normal)
            
//            self.sessionSuccessfullyDescLbl.text = "Free cancellation/reschedule before Wed, Sep 20, 01:00 AM. Know More"
          
         //-----------------------**************Track Trainer
            if let typeStr = typeStr, typeStr.lowercased() == "home" {
                self.trackTrainerBtn.isHidden = false
                self.cancelRequestMBV.isHidden = false
            }else{
                self.cancelRequestMBV.isHidden = true
                self.trackTrainerBtn.isHidden = true
            }
            
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
            self.myTrainerTitleBtn.setTitle("My Trainer", for: .normal)
            self.myTrainerTitleBtn.isHidden = false
            
            self.myTrainerTitleBtn.contentEdgeInsets = UIEdgeInsets(top: 23, left: 0, bottom: 11, right: 0)
            self.myTrainerTitleBtn.setTitleColor(UIColor.txtDarkGray, for: .normal)
            self.myTrainerTitleBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
            self.homeWorkoutMBV.isHidden = true
            self.bookingStatusMBV.isHidden = true
            self.sessionOverviewSubMBV.isHidden = false
            self.rateTrainerMBV.isHidden = false
            self.rescheduleMBV.isHidden = true
            self.bookingAgainMBV.isHidden = true
            self.trackTrainerBtn.isHidden = true
            self.sessionSuccessfullyMBV.isHidden = true
            self.bookingRescheduleStckView.isHidden = true
            self.bookingDetailsMBV.isHidden = true
            self.cancellationDetailsMBV.isHidden = false
            self.cancellationPolicyMBV.isHidden = true
            self.exerciseLogMBV.isHidden = false
            self.costMBV.isHidden = false
            self.customerSupportMBV.isHidden = true
            self.customerSupportBtn.isHidden = true
            self.customerSupportBtnHeightConstrnt.constant = 1.0 //45.0
            self.bookingQRMBV.isHidden = true
            
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
            self.bookingQRMBV.isHidden = true
            self.bookingQRBtn.isHidden = true
            self.sessionOverviewMBV.isHidden = true
//            self.sessionOverviewSubMBV.isHidden = true
            self.rateTrainerMBV.isHidden = true
            self.rescheduleMBV.isHidden = true
            self.bookingAgainMBV.isHidden = false
            self.bookAgainBtn.isHidden = false
            self.trackTrainerBtn.isHidden = true
            self.sessionSuccessfullyMBV.isHidden = false
            self.bookingRescheduleStckView.isHidden = true
            self.cancellationDetailsMBV.isHidden = false
            self.cancellationPolicyMBV.isHidden = true
            self.exerciseLogMBV.isHidden = true
            self.costMBV.isHidden = true
            self.customerSupportMBV.isHidden = true
            self.customerSupportBtn.isHidden = true
            self.customerSupportBtnHeightConstrnt.constant = 1.0
            self.cancelRefundMBV.isHidden = true
            
            //----------------******* Data set
            self.bookingStatusBtn.setImage(UIImage(named: "ic_calendarCan"), for: .normal)
            self.bookingStatusBtn.setTitle(AppStrings.session_Cancelled, for: .normal)
            self.bookingStatusBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
            self.bookingStatusBtn.setTitleColor(UIColor.appWhite, for: .normal)
            
//            self.sessionSuccessfullyDescLbl.text = bookingDetailsData?.cancellationDetail?.msg?.value  // "Booking amount will be refunded within 24 hours of cancellation"
          
//            self.sessionSuccessfullyDescLbl.textColor = UIColor.appLightGray
//            self.sessionSuccessfullyMBV.backgroundColor = UIColor(red: 28.0/255.0, green: 31.0/255.0, blue: 33.0/255.0, alpha: 1)
            
        case .bookingConfirm:
            print("Booking confirm...")
            
            self.trainerDetailsBottomConstrnt.constant = 2.0
            self.locationMBV.isHidden = false
            self.ptChargeMBV.isHidden = true
            self.paymentMBV.isHidden = false
            self.myTrainerTitleBtn.setTitle("My Trainer", for: .normal)
            self.myTrainerTitleBtn.isHidden = false
            
            self.myTrainerTitleBtn.contentEdgeInsets = UIEdgeInsets(top: 23, left: 0, bottom: 11, right: 0)
            self.myTrainerTitleBtn.setTitleColor(UIColor.txtDarkGray, for: .normal)
            self.myTrainerTitleBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
           
            self.cancelledMBV.isHidden = true
            self.homeWorkoutMBV.isHidden = true
            self.bookingStatusMBV.isHidden = true
            self.sessionOverviewMBV.isHidden = true
            self.sessionOverviewSubMBV.isHidden = true
            self.rescheduleMBV.isHidden = true
            self.bookingAgainMBV.isHidden = true
            self.trackTrainerBtn.isHidden = true
            self.sessionSuccessfullyMBV.isHidden = true
            self.bookingRescheduleStckView.isHidden = true
            self.bookingDetailsMBV.isHidden = true
            self.cancellationPolicyMBV.isHidden = true
            self.exerciseLogMBV.isHidden = true
            self.customerSupportMBV.isHidden = true
            self.customerSupportBtn.isHidden = true
            self.customerSupportBtnHeightConstrnt.constant = 1.0
            self.bookingQRBtn.isHidden = true
            self.bookingQRMBV.isHidden = true
            self.rateTrainerMBV.isHidden = false
            self.cancellationDetailsMBV.isHidden = false
            self.costMBV.isHidden = false
            self.locationEditBtn.isHidden = true
            
            
        case .defaultDetails:
            print("defaultDetails flow")
        }
    }
    
    private func setPTBalancePayAmtAttr(priceStr: String?){
        //-------------------- Attributed Text for Price
        let getAmount:String = priceStr ?? ""
        let balanceStr:String = "Balance"
//        if let pricePackage = packagecheckoutData?.packageDetail?.price {
//            let components = pricePackage.split(separator: " ")
//            getAmount = "\(components.first ?? "")"
//            currencyStr = "\(components.last ?? "")"
//        }
        
        let defaultAttributes = [
            .font: AppFont.bold.size(28.0, familyName: familyManrope),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let makeAttributes = [
            .font: AppFont.regular.size(14.0, familyName: familyManrope),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let priceAttributed = [
            getAmount,
            NSAttributedString(string: balanceStr,
                               attributes: makeAttributes)
        ] as [AttributedStringComponent]
        
        self.freeAmtLbl.attributedText = NSAttributedString(from: priceAttributed, defaultAttributes: defaultAttributes)
    }
    
    //MARK: ----------------SETUPUI
    func setUpUI(){
        
        DispatchQueue.main.async {
            
            self.showPTChargeBtn.roundSideCorners(radius: 24.0, cornerSide: [.topLeft, .topRight])
            self.trainerProfileImgV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12)
            
            [
                self.helpBtn,
                self.bookingRescheduleBtn,
                self.declineBtn,
                self.customerSupportBtn,
                self.bookingQRBtn,
                self.confirmBookingBtn
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
                self.trackTrainerBtn,
                self.cancelBookingBtn,
                self.cancelrequestBtn,
                self.sessionSuccessfullyMBV,
                self.bookingDetailsSubMBV,
                self.cancellationSubMBV,
                self.cancellationPolicySubMBV,
                self.exerciseLogSubMBV,
                self.costCreditMBV,
                self.locationSubMBV
                    
            ].forEach({[weak self] in
                guard self != nil else { return  }
                $0?.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            })
            
            self.exerciseLineV.backgroundColor = UIColor.clear
            self.lineV.backgroundColor = UIColor.clear
            self.exerciseLineV.addGradient(colors: UIColor.appMultiColor(.lineVGradient), locations: [0,0.5,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 0.2)
            self.lineV.addGradient(colors: UIColor.appMultiColor(.lineVGradient), locations: [0,0.5,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 0.2)
        }
        
        //--------------*******************
        switch detailsFlow {
        case .reschedule, .rescheduleConsumer:
            ///
            break
        case .upcoming:
            DispatchQueue.main.async {
                self.cancelBookingBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appRed, cornerRadious: 12.0)
            }
        case .completed, .cancelled, .bookingConfirm, .defaultDetails:
            print("defaultDetails flow")
            break
        }
    }
    
    func fontSetUP(){
        self.showPTChargeBtn.titleLabel?.numberOfLines = 0
        
        self.customerSupportBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.bookingQRBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.confirmBookingBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.locationTitleLbl.font = AppFont.regular.size(14.0, familyName: familyManrope)
        self.locAddrsDescLbl.font = AppFont.bold.size(18.0, familyName: familyManrope)
        
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
            self.trackTrainerBtn.titleLabel,
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
            self.bookingStatusBtn.titleLabel,
            self.bookingDetailsTitleLbl,
            self.cancellationDetailsTitleLbl,
            self.cancellationPolicyTitleLbl,
            self.exerciseLogTitleLbl,
            self.showPTChargeBtn.titleLabel
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
            self.costAmtLbl,
            self.breakDownLbl
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
           
            var params:[String:String] = [
                "id": inputId ?? ""
            ]
            
            if let typeStr = typeStr, typeStr.lowercased() == "home" {
                params["long"] = ""
                params["lat"] = ""
            }else{
                params["long"] = long
                params["lat"] = lat
            }
            
            print("Booking Deatils params: ", params)
            
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
    
    //MARK: -----------------SLOT BOOKED API
    private func bookSlot(inputParam: [String:Any]){
        print("Book Slot inputParam: ", inputParam)
        
        TrainerVM.bookSlotApi(viewController: self, inputParams: inputParam, completion: {[weak self]  getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            
            print("Booked getResultData: ",getResultData)
            if getResultData.status == true {
                let vc:PaymentSuccessViewController = PaymentSuccessViewController.instantiate(appStoryboard: .booking)
                vc.bookedDataModel = getResultData.data
                vc.billingViewFlow = .defaultBilling
                self.navigationController?.pushViewController(vc, animated: true)
            }
          
        })
        
        /*
         let params:[String:Any] = [
         "studio_id": "",    //studio_id: 5, Studio id field is required if selecting from gym
         "type": "" ,        //type: gym, type will be home , gym
         "trainer_id": "",   //trainer_id: 1, trainer id filed is required
         "slot_id": "",      //slot_id: 23, slot id field is required
         "address_id": "",   //address_id: 1, address id is required if type is gym
         "is_package": "",   //is_package: 1, if hit through using package then 1 else blank
         "package_type": "", //package_type: 3, package type is required
         "date": "",         //date: 2025-03-28, start date is required
         "end_date": "",     //end_date: 2025-04-25, end date is required
         "sessions": "",     //sessions: 12, no of sessions
         "price": "",        //price: 320, price field is required
         "days": ""          //days: 30, no of days
         "transaction_id":"",
         "payment_type": ccavenue, tabby/tamara/ccavenue
         "booking_id": 345, booking id for accept booking
         ]
         */
    }
}
