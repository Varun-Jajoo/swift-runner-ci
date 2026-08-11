//
//  BookingListViewController.swift
//  MyPT
//
//  Created by techsaga corp on 16/12/24.
//

import UIKit

class BookingListViewController: CommonViewController {

    //MARK: ---------------- VARIABLE
    var isFromTab: Bool? = false
    private var filterSelectedDate:(filterSelectedDateStr:String?, bookingCatagory:Int?)?
    private var upcomingSelectedDate: String?
    private var cancelledSelected: String?
    private var completedSelected: String?
    
    var selectedIndex:NSIndexPath = NSIndexPath(row: 0, section: 0)
    var bookingData:[BookingDataModel]? = []
    var selectedTags: Int? = 2 {
        didSet{
            if let selectedTags = selectedTags {
                //-----Api called
                self.bookingListApi(typeStr: "\(selectedTags)", dateStr: nil, sessionType: nil, location: nil)
            }
        }
    }
    
//    var filterMont: String? {
//        didSet{
//            if let selectedTags = selectedTags {
//                self.bookingListApi(typeStr: "\(selectedTags)", dateStr: filterMont, sessionType: nil, location: nil)
//            }
//        }
//    }
    
    var filterData: (month:String?, sessionTypeStr: String?, locationStr: String?)  {
        didSet{
            if let selectedTags = selectedTags {
                self.bookingListApi(typeStr: "\(selectedTags)", dateStr: filterData.month, sessionType: filterData.sessionTypeStr, location: filterData.locationStr)
            }
        }
    }
    
    var loadShowSections: [FilterSection]? = []
    
    //MARK: ---------------- IBOUTLET
    @IBOutlet weak var bookingCategorySegm: UISegmentedControl!
    @IBOutlet weak var monthsBtn: UIButton!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var bookingListTbl: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpFont()
        self.selectedTags = 2
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setUpUI()
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
        
        let tags = self.selectedTags
        self.selectedTags = tags
         
    }
    
    private func setNavUI(){
        var navBckBtn: UIImage? = nil
        if let isFromTab = isFromTab {
            navBckBtn = (isFromTab ? nil : AppImages.backarrow)
        }
       
        self.setLeftMenu(leftImgs: [nil], setTitle: [AppStrings.booking_Listings], setTintColor: .black, setTitleColor: UIColor.appWhite)
//        self.setRighMenu(rightImgs: [AppImages.shareGymWorkout], setTitle: [""], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    private func setUpUI(){
        
        DispatchQueue.main.async {
            self.bookingCategorySegm.backgroundColor = UIColor.mainBg.withAlphaComponent(0.6)
            self.bookingCategorySegm.setTitleColor(UIColor.appWhite, state: .normal)
            self.bookingCategorySegm.setTitleColor(UIColor.mainBg, state: .selected)
            self.bookingCategorySegm.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.monthsBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.filterBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
        }
    }
    
    private func setUpFont(){
        //----------------------Tableview Register
        self.bookingListTbl.register(UINib(nibName: "BookingListTableViewCell", bundle: nil), forCellReuseIdentifier: "BookingListTableViewCell")
        
        //------------------------Setup segment
        self.bookingCategorySegm.setTitle(AppStrings.upcoming, forSegmentAt: 0) //for upcoming
        self.bookingCategorySegm.setTitle(AppStrings.cancelled, forSegmentAt: 1) //for cancelled
        self.bookingCategorySegm.setTitle(AppStrings.completed, forSegmentAt: 2) //for completed
        self.bookingCategorySegm.selectedSegmentIndex = 0
        
        //----------------------*********** Font
        self.bookingCategorySegm.setTitleFont(AppFont.semibold.size(14, familyName: familyManrope))
        self.monthsBtn.titleLabel?.font = AppFont.semibold.size(12, familyName: familyManrope)
        self.filterBtn.titleLabel?.font = AppFont.semibold.size(12, familyName: familyManrope)
    }
    
    //type: 0, 1 => completed, 2 => upcoming, 0 => cancel
    let segmentTags = [0: 2, 1: 0, 2: 1]
    
    @IBAction func bookingCategorySegActn(_ sender: UISegmentedControl) {
//        print("segment selected tag = ", sender.selectedSegmentIndex)
        selectedIndex = NSIndexPath(row: sender.selectedSegmentIndex, section: 0)
        
        if let tag = segmentTags[sender.selectedSegmentIndex] {
            print("Selected tag: \(tag)")
            self.loadShowSections?.removeAll()
            self.selectedTags = tag
            
            //---------------Filter Setup data
            if let cancelledSelected = cancelledSelected, let selectedTags = selectedTags , selectedTags == 0{
                self.bookingData?.removeAll()
                self.bookingListTbl.reloadData()
                self.filterData.month = DateFormatterHelper.shared.getDateFromFormat(fromDate: cancelledSelected, fromFormat: "dd/MM/yyyy", toFormat: "yyyy-MM")
            }
            if let completedSelected = completedSelected , let selectedTags = selectedTags, selectedTags == 1{
                self.bookingData?.removeAll()
                self.bookingListTbl.reloadData()
                self.filterData.month = DateFormatterHelper.shared.getDateFromFormat(fromDate: completedSelected, fromFormat: "dd/MM/yyyy", toFormat: "yyyy-MM")
            }
            if let upcomingSelectedDate = upcomingSelectedDate ,  let selectedTags = selectedTags, selectedTags == 2{
                self.bookingData?.removeAll()
                self.bookingListTbl.reloadData()
                self.filterData.month = DateFormatterHelper.shared.getDateFromFormat(fromDate: upcomingSelectedDate, fromFormat: "dd/MM/yyyy", toFormat: "yyyy-MM")
            }
            
        }
        
        
//        self.bookingListTbl.reloadData()
        
        /*
        if sender.selectedSegmentIndex == 0 {
//            self.bookingData?.append(1)
//            self.bookingData?.append(1)
//            self.bookingData?.append(1)
            self.bookingListTbl.reloadData()
        }else{
//            self.bookingData?.removeAll()
            self.bookingListTbl.reloadData()
        }
        */
    }
    
    @IBAction func monthsBtnAcn(_ sender: Any) {
        print("month btn clicked...")
        //type: 0, 1 => completed, 2 => upcoming, 0 => cancel
        let vc:SelectMonthViewController = SelectMonthViewController.instantiate(appStoryboard: .booking)
        vc.modalTransitionStyle = .coverVertical
        vc.filterMonth = {[weak self] getMonth, getSelectedDate in
            guard let self = self else { return  }
            print("getMonth", getMonth as Any)
            self.filterData.month = getMonth
//            self.filterSelectedDate = (getSelectedDate, selectedTags)
            
            if let selectedTags = selectedTags, selectedTags == 0{
                self.cancelledSelected = getSelectedDate
            }
            if let selectedTags = selectedTags, selectedTags == 1{
                self.completedSelected = getSelectedDate
            }
            if let selectedTags = selectedTags, selectedTags == 2{
                self.upcomingSelectedDate = getSelectedDate
            }
            
        }
        
        
        //-----------------Local selected date
        if let cancelledSelected = cancelledSelected, let selectedTags = selectedTags , selectedTags == 0{
            vc.localSelectedDate = cancelledSelected
        }
        if let completedSelected = completedSelected , let selectedTags = selectedTags, selectedTags == 1{
            vc.localSelectedDate = completedSelected
        }
        if let upcomingSelectedDate = upcomingSelectedDate ,  let selectedTags = selectedTags, selectedTags == 2{
            vc.localSelectedDate = upcomingSelectedDate
        }

        self.navigationController?.present(vc, animated: true)
    }
    
    @IBAction func filterBtnActn(_ sender: Any) {
        print("fliter btn clicked...")
        let vc:FilterViewController = FilterViewController.instantiate(appStoryboard: .booking)
        vc.modalTransitionStyle = .coverVertical
        vc.navFilterCtrl = self.navigationController
        vc.flowUI = .filterBooking
        vc.filterData = {[weak self] (sessionType, loc, localData) in
            guard let self = self else { return }
            print("getData: ", (sessionType, loc, localData))
            self.loadShowSections?.removeAll()
            self.loadShowSections?.append(contentsOf: localData ?? [])
            self.filterData.sessionTypeStr = sessionType
            self.filterData.locationStr = loc
        }
        vc.loadSections = self.loadShowSections
        self.navigationController?.present(vc, animated: true)
    }
    
}

//MARK: ----------------UITABLEVIEW DATASOURCE/DELEGATE

extension BookingListViewController: UITableViewDataSource, UITableViewDelegate{
   
    //MARK: ------------NO DATA FOUND CONFIGURATION
    func noSessionsConfig(inputTable:UITableView?, getCount:Int?) -> Int{
        let imgHeight = (self.bookingListTbl?.frame.size.height ?? 50) * 0.3
        let msgImage = UIImage(named: "ic_noSessions")?.resized(to: CGSize(width: imgHeight, height: imgHeight))
        
        guard let countReturn = inputTable?.numberOfRows(count: self.bookingData?.count, title: AppStrings.no_sessions_found, message: AppStrings.you_have_not_booked_session_yet, messageImage: msgImage, messageImageHeight: imgHeight, reloadSetTitle: AppStrings.book_session.uppercased(), target: self, action: #selector(reloadData(sender: )), fromTop: 12.0) else { return 0}
        
        /*
        if selectedTags == 0{
            let msgImage = UIImage(named: "ic_search_NoResult")?.resized(to: CGSize(width: imgHeight * 1.5, height: imgHeight * 1.5))
            guard let countReturn = inputTable?.numberOfRows(count: self.bookingData?.count, title: AppAlertStrings.no_results_found, message: "", messageImage: msgImage, messageImageHeight: msgImage?.size.height, fromCenter: -45.0) else { return 0}
           
            return countReturn
        }
        */
        
        return  countReturn
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return noSessionsConfig(inputTable: self.bookingListTbl, getCount: self.bookingData?.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:BookingListTableViewCell = bookingListTbl.dequeueReusableCell(withIdentifier: "BookingListTableViewCell", for: indexPath) as! BookingListTableViewCell
        cell.rescheduledBtn.isHidden = true
        cell.addLeftBorder(borderColor: UIColor.clear)
        cell.setUpCell(inputData: self.bookingData?[indexPath.row], type: self.selectedTags)
        
        /*
         cell.rescheduledBtn.isHidden = true
        if selectedIndex.row == 0 {
//            cell.addLeftBorder(borderColor: UIColor.appYellow)
            if indexPath.row == 0 {
                cell.rescheduledBtn.isHidden = false
                cell.addLeftBorder(borderColor: UIColor.appYellow)
            }else{
                cell.addLeftBorder(borderColor: UIColor(red: 93.0/255.0, green: 182.0/255.0, blue: 195.0/255.0, alpha: 1))
            }
            
        }else if selectedIndex.row == 1{
            cell.addLeftBorder(borderColor: UIColor.appRed)
        }else{
            cell.addLeftBorder(borderColor: UIColor.appGreen)
        }
        
        */
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        // Group-class rows push the read-only Slot Confirmed receipt instead of
        // the generic BookingDetailsViewController, matching Android's
        // UpcomingAdapter/UpcomingSessionsAdapter click listeners (both branch on
        // the identical isGroupClass condition, regardless of the selected tab).
        if let row = self.bookingData?[indexPath.row], row.isGroupClass {
            // Upcoming waitlist rows have a live claim state to show (plain
            // waitlist position, or the overlapping-waitlist priority window) -
            // routing them through the "your slot is confirmed" receipt like a
            // real booking hid that entirely. Cancelled/Completed rows have
            // nothing live left to show, so they keep using the generic
            // read-only receipt below regardless of type.
            if self.selectedTags == 2, row.isWaitlistRow {
                // A normal (non-special) waitlist entry whose spot has
                // already opened up gets the claim screen directly instead of
                // the static "you're waitlisted" receipt - no reason to make
                // the member re-discover that a spot they can already take is
                // sitting there.
                if !row.isSpecialWaitlist, row.hasOpenSpot == true, let scheduleId = row.scheduleId?.value, !scheduleId.isEmpty {
                    let controller = SlotOpenViewController()
                    controller.scheduleId = scheduleId
                    controller.hidesBottomBarWhenPushed = true
                    controller.onClaimed = { [weak self] classTitle, time, location, trainer in
                        let confirmed = SlotConfirmedViewController()
                        confirmed.classTitle = classTitle
                        confirmed.classTime = time
                        confirmed.classLocation = location
                        confirmed.trainerName = trainer
                        confirmed.hidesBottomBarWhenPushed = true
                        self?.navigationController?.pushViewController(confirmed, animated: true)
                    }
                    self.navigationController?.pushViewController(controller, animated: true)
                    return
                }

                // A special (overlapping-booking) entry still shows its own
                // priority-window explainer. A normal entry with no open spot
                // yet needs an actionable detail screen (LEAVE WAITLIST), not
                // the static "you're waitlisted" receipt with nothing to do
                // on it - SlotConfirmedViewController already fully supports
                // this via its own "wl-" bookingId handling (WAITLISTED pill,
                // LEAVE WAITLIST CTA wired to leave-waitlist), same as a real
                // booking's CANCEL BOOKING path just below.
                if row.isSpecialWaitlist {
                    let dbVc = DoubleBookingWaitlistConfirmedViewController()
                    let bookingType = row.bookingType?.trimmingCharacters(in: .whitespacesAndNewlines)
                    dbVc.classTitle = (bookingType?.isEmpty == false ? bookingType : row.sessionType?.value) ?? ""
                    dbVc.classTime = row.timing?.value ?? ""
                    dbVc.classLocation = row.location?.value ?? ""
                    dbVc.trainerName = row.trainer?.value ?? ""
                    dbVc.distance = row.distance?.value ?? ""
                    dbVc.studioLat = row.studioLat?.doubleValue ?? 0
                    dbVc.studioLng = row.studioLng?.doubleValue ?? 0
                    dbVc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(dbVc, animated: true)
                    return
                }

                let bookingType = row.bookingType?.trimmingCharacters(in: .whitespacesAndNewlines)
                let controller = SlotConfirmedViewController()
                controller.classTitle = (bookingType?.isEmpty == false ? bookingType : row.sessionType?.value) ?? ""
                controller.classTime = row.timing?.value ?? ""
                controller.classLocation = row.location?.value ?? ""
                controller.trainerName = row.trainer?.value ?? ""
                controller.distance = row.distance?.value ?? ""
                controller.classPrice = row.price?.value ?? ""
                controller.studioLat = Double(row.studioLat?.value ?? "") ?? 0
                controller.studioLng = Double(row.studioLng?.value ?? "") ?? 0
                controller.isReadOnly = true
                controller.bookingId = row.id?.value ?? ""
                controller.canCancelBooking = true
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(controller, animated: true)
                return
            }

            let bookingType = row.bookingType?.trimmingCharacters(in: .whitespacesAndNewlines)
            let resolvedTitle = (bookingType?.isEmpty == false ? bookingType : row.sessionType?.value) ?? ""

            // A class the admin cancelled outright (not the member's own
            // cancel) gets the dedicated rejection screen instead of the
            // usual receipt with a plain "CANCELLED" pill - see
            // ClassCancelledByAdminViewController's own doc comment for why.
            if row.bookingStatus == "cancelled", row.cancelledByAdmin == true {
                var input = ClassCancelledByAdminInput()
                input.classTitle = resolvedTitle
                input.classTime = row.timing?.value ?? ""
                input.classLocation = row.location?.value ?? ""
                input.trainerName = row.trainer?.value ?? ""
                input.distance = row.distance?.value ?? ""
                input.studioLat = row.studioLat?.doubleValue ?? 0
                input.studioLng = row.studioLng?.doubleValue ?? 0
                let controller = ClassCancelledByAdminViewController()
                controller.input = input
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(controller, animated: true)
                return
            }

            let controller = SlotConfirmedViewController()
            controller.classTitle = resolvedTitle
            controller.classTime = row.timing?.value ?? ""
            controller.classLocation = row.location?.value ?? ""
            controller.trainerName = row.trainer?.value ?? ""
            controller.distance = row.distance?.value ?? ""
            controller.classPrice = row.price?.value ?? ""
            controller.studioLat = Double(row.studioLat?.value ?? "") ?? 0
            controller.studioLng = Double(row.studioLng?.value ?? "") ?? 0
            controller.isReadOnly = true
            controller.bookingId = row.id?.value ?? ""
            controller.bookingStatus = row.bookingStatus ?? "confirmed"
            controller.noShowCount = row.noShowCount ?? 0
            controller.noShowBlockedUntil = row.noShowBlockedUntil ?? ""
            // Only the Upcoming sub-tab has anything left to cancel.
            controller.canCancelBooking = (self.selectedTags == 2)
            // This is a receipt-style full-screen push straight from the
            // Bookings tab's own stack, which is never hidden upstream (unlike
            // the Group-Classes booking flow, which hides it once on the Detail
            // screen and inherits that for everything pushed after it) — without
            // this the tab bar stayed visible over what should be a full page.
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
            return
        }

        let vc:BookingDetailsViewController = BookingDetailsViewController.instantiate(appStoryboard: .booking)

        if selectedTags == 2{
            if let isReschedule = self.bookingData?[indexPath.row].isReschedule, isReschedule, let isTrainerReschedule = self.bookingData?[indexPath.row].isTrainer {
                vc.detailsFlow = (isTrainerReschedule ? .reschedule : .rescheduleConsumer)
                
            }else{
                vc.detailsFlow = .upcoming
            }
        } else if selectedTags == 0{
            vc.detailsFlow = .cancelled
        } else if selectedTags == 1{
            vc.detailsFlow = .completed
        }
        vc.bookingIdStr = "\(self.bookingData?[indexPath.row].id?.value ?? "0")"
        vc.typeStr = self.bookingData?[indexPath.row].sessionType?.value
        self.navigationController?.pushViewController(vc, animated: true)
        
        
        //        let vc:BookingDetailsViewController = BookingDetailsViewController.instantiate(appStoryboard: .booking)
        //        self.navigationController?.pushViewController(vc, animated: true)
        
        
        /*
         if bookingCategorySegm.selectedSegmentIndex == 0 {
         let vc:BookingDetailsViewController = BookingDetailsViewController.instantiate(appStoryboard: .booking)
         
         if selectedIndex.row == 0 {
         
         if indexPath.row == 0 {
         vc.detailsFlow = .reschedule
         }else{
         vc.detailsFlow = .upcoming
         }
         
         self.navigationController?.pushViewController(vc, animated: true)
         }
         }
         else if bookingCategorySegm.selectedSegmentIndex == 1 {
         let vc:BookingDetailsViewController = BookingDetailsViewController.instantiate(appStoryboard: .booking)
         vc.detailsFlow = .cancelled
         self.navigationController?.pushViewController(vc, animated: true)
         }
         else if bookingCategorySegm.selectedSegmentIndex == 2 {
         let vc:BookingDetailsViewController = BookingDetailsViewController.instantiate(appStoryboard: .booking)
         vc.detailsFlow = .completed
         self.navigationController?.pushViewController(vc, animated: true)
         
         }
         */
        
    }
    
    //MARK: ---------------DATA RELOAD
    @objc func reloadData(sender: UIButton){
//        let getTags = self.selectedTags
//        self.selectedTags = getTags
        
        let vc:CreateTrainerViewController = CreateTrainerViewController.instantiate(appStoryboard: .booking)
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
}

//MARK: ----------------EXTENSION FOR API
extension BookingListViewController{
    
    private func bookingListApi(typeStr: String, dateStr: String?, sessionType: String?, location: String?){
//        type: 0, 1 => completed, 2 => upcoming, 0 => cancel
        
        BookingVM.getBookingApi(inputType: typeStr, inputDate: dateStr, inputSessionType: sessionType, inputLocation: location, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
           
            print("getResultData", getResultData)
            self.bookingData?.removeAll()
            
            if getResultData.status == true {
                self.bookingData?.append(contentsOf: getResultData.data ?? [])
                
//                getResultData.data = [BookingDataModel(id: 01)]
//                self.bookingData?.append(contentsOf: getResultData.data ?? [BookingDataModel(id: 01)])
//                print("ookingData", bookingData as Any)
            }
            self.bookingListTbl.reloadData()
        })
    }
}

