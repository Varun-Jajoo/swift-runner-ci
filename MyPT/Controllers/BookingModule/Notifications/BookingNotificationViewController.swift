//
//  BookingNotificationViewController.swift
//  MyPT
//
//  Created by techsaga corp on 05/08/25.
//

import UIKit

class BookingNotificationViewController: CommonViewController, UITableViewDelegate, UITableViewDataSource{
   
    var bookingData:[BookingDataModel]? = []
    
    @IBOutlet weak var notificationsTblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshApiNotification(notification:)), name: NSNotification.Name("refreshApiNotification"), object: nil)
        
        notificationsTblView.register(UINib(nibName: "BookingNotificationTableViewCell", bundle: nil), forCellReuseIdentifier: "BookingNotificationTableViewCell")
        //type = 3 , for Booking notification
        self.bookingListApi(typeStr: "3", dateStr: nil, sessionType: nil, location: nil)
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
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: ["Notification "], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    @objc func refreshApiNotification(notification: Notification){
        self.bookingListApi(typeStr: "3", dateStr: nil, sessionType: nil, location: nil)
    }
    
    //------------------------------ TABLEVIEW DELEGATE/DATASOURCE
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return noSessionsConfig(inputTable: self.notificationsTblView, getCount: self.bookingData?.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: BookingNotificationTableViewCell = notificationsTblView.dequeueReusableCell(withIdentifier: "BookingNotificationTableViewCell", for: indexPath) as! BookingNotificationTableViewCell
        cell.addressMBV.isHidden = true
        cell.distanceLbl.numberOfLines = 1
        cell.landMarkLbl.numberOfLines = 2
        
        cell.setCellData(cellData: self.bookingData?[indexPath.row])
        cell.rescheduleBtn.accessibilityHint = "\(self.bookingData?[indexPath.row].id?.value ?? "0")"
        cell.denyRequestBtn.accessibilityHint = "\(self.bookingData?[indexPath.row].id?.value ?? "0")"
        cell.acceptBtn.accessibilityHint = "\(self.bookingData?[indexPath.row].id?.value ?? "0")"
        cell.addAddressBtn.accessibilityHint = "\(self.bookingData?[indexPath.row].id?.value ?? "0")"
       
        cell.rescheduleBtn.addTarget(self, action: #selector(rescheduleBtnActn(sender: )), for: .touchUpInside)
        cell.acceptBtn.addTarget(self, action: #selector(acceptBtnActn(sender: )), for: .touchUpInside)
        cell.addAddressBtn.addTarget(self, action: #selector(addAddressBtnActn(sender: )), for: .touchUpInside)
        cell.denyRequestBtn.addTarget(self, action: #selector(denyRequestBtnActn(sender: )), for: .touchUpInside)
       
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        let vc:BookingDetailsViewController = BookingDetailsViewController.instantiate(appStoryboard: .booking)
//        vc.detailsFlow = .bookingConfirm
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: ------------NO DATA FOUND CONFIGURATION
    func noSessionsConfig(inputTable:UITableView?, getCount:Int?) -> Int{
        let imgHeight = (self.notificationsTblView?.frame.size.height ?? 50) * 0.3
        let msgImage = UIImage(named: "ic_noSessions")?.resized(to: CGSize(width: imgHeight, height: imgHeight))
        
        guard let countReturn = inputTable?.numberOfRows(count: self.bookingData?.count, title: "No Notifications found", message: "", messageImage: msgImage, messageImageHeight: imgHeight, fromCenter: -imgHeight/2, fromTop: nil) else { return 0}
        return  countReturn
    }
    
    @objc func rescheduleBtnActn(sender: UIButton){
        let vc:FilterViewController = FilterViewController.instantiate(appStoryboard: .booking)
        vc.modalTransitionStyle = .coverVertical
        vc.flowUI = .reschedule
        vc.navFilterCtrl = self.navigationController
        vc.bookingIdStr =  sender.accessibilityHint
        self.navigationController?.present(vc, animated: true)
    }
    
    @objc func acceptBtnActn(sender: UIButton){
        
        let vc:BookingDetailsViewController = BookingDetailsViewController.instantiate(appStoryboard: .booking)
        vc.detailsFlow = .bookingConfirm
        vc.bookingIdStr = sender.accessibilityHint
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func addAddressBtnActn(sender: UIButton){
        let vc:LocationsViewController = LocationsViewController.instantiate(appStoryboard: .main)
        vc.flowLocation = .confirmAddAddress
        vc.isFromEditAddress = false
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func denyRequestBtnActn(sender: UIButton){
        print("Deny Request............")
        var trainerData: TrainerDeyRequestModel?
        
        let indx = (bookingData?.firstIndex(where: {"\($0.id?.value ?? "0")" == sender.accessibilityHint}))
        if let indx = indx {
            let bookingDetail = bookingData?[indx]
            trainerData = TrainerDeyRequestModel(id: bookingDetail?.id?.intValue, type: bookingDetail?.type?.value, trainer_image: bookingDetail?.trainer_image?.value, trainer: bookingDetail?.trainer?.value, location: bookingDetail?.location?.value, distance: bookingDetail?.distance?.value, scheduleMsg: bookingDetail?.scheduleMsg?.value)
            
            let vc:DeleteAccPopupViewController = DeleteAccPopupViewController.instantiate(appStoryboard: .more)
            vc.modalPresentationStyle = .automatic
            vc.delPopUpFlow = .deyRequest
            vc.trainerData = trainerData
            self.present(vc, animated: true)
        }
    }
}

extension BookingNotificationViewController{
    private func bookingListApi(typeStr: String, dateStr: String?, sessionType: String?, location: String?){
//        type: 0, 1 => completed, 2 => upcoming, 0 => cancel
        BookingVM.getBookingApi(inputType: typeStr, inputDate: dateStr, inputSessionType: sessionType, inputLocation: location, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
            self.bookingData?.removeAll()
            if getResultData.status == true {
                self.bookingData?.append(contentsOf: getResultData.data ?? [])
            }
            self.notificationsTblView.reloadData()
        })
    }
}
