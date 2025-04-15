//
//  BookingListViewController.swift
//  MyPT
//
//  Created by techsaga corp on 16/12/24.
//

import UIKit

class BookingListViewController: CommonViewController {

    //MARK: ---------------- VARIABLE
    var selectedIndex:NSIndexPath = NSIndexPath(row: 0, section: 0)
    var bookingData:[Any]?
    
    //MARK: ---------------- IBOUTLET
    @IBOutlet weak var bookingCategorySegm: UISegmentedControl!
    @IBOutlet weak var monthsBtn: UIButton!
    @IBOutlet weak var filterBtn: UIButton!
    @IBOutlet weak var bookingListTbl: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bookingCategorySegm.setTitle(AppStrings.upcoming, forSegmentAt: 0)
        self.bookingCategorySegm.setTitle(AppStrings.cancelled, forSegmentAt: 1)
        self.bookingCategorySegm.setTitle(AppStrings.completed, forSegmentAt: 2)
        self.bookingCategorySegm.selectedSegmentIndex = 0
        
        self.bookingData = [1,1,1,1,1]

//        self.setUpUI()
        self.setUpFont()
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
    }
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.booking_Listings], setTintColor: .black, setTitleColor: UIColor.appWhite)
//        self.setRighMenu(rightImgs: [AppImages.shareGymWorkout], setTitle: [""], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    func setUpUI(){
        
        bookingListTbl.register(UINib(nibName: "BookingListTableViewCell", bundle: nil), forCellReuseIdentifier: "BookingListTableViewCell")
        
        DispatchQueue.main.async {
            self.bookingCategorySegm.backgroundColor = UIColor.mainBg.withAlphaComponent(0.6)
            self.bookingCategorySegm.setTitleColor(UIColor.appWhite, state: .normal)
            self.bookingCategorySegm.setTitleColor(UIColor.mainBg, state: .selected)
            self.bookingCategorySegm.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.monthsBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.filterBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
        }
    }
    
    func setUpFont(){
        self.bookingCategorySegm.setTitleFont(AppFont.semibold.size(14, familyName: familyManrope))
        self.monthsBtn.titleLabel?.font = AppFont.semibold.size(12, familyName: familyManrope)
        self.filterBtn.titleLabel?.font = AppFont.semibold.size(12, familyName: familyManrope)
    }
    
    @IBAction func bookingCategorySegActn(_ sender: UISegmentedControl) {
        print("segment selected tag = ", sender.selectedSegmentIndex)
        selectedIndex = NSIndexPath(row: sender.selectedSegmentIndex, section: 0)
        self.bookingListTbl.reloadData()
        
        if sender.selectedSegmentIndex == 0 {
            self.bookingData?.append(1)
            self.bookingData?.append(1)
            self.bookingData?.append(1)
            self.bookingListTbl.reloadData()
        }else{
//            self.bookingData?.removeAll()
            self.bookingListTbl.reloadData()
        }
    }
    
    @IBAction func monthsBtnAcn(_ sender: Any) {
        print("month btn clicked...")
        let vc:SelectMonthViewController = SelectMonthViewController.instantiate(appStoryboard: .booking)
        vc.modalTransitionStyle = .coverVertical
        self.navigationController?.present(vc, animated: true)
    }
    
    @IBAction func filterBtnActn(_ sender: Any) {
        print("fliter btn clicked...")
        let vc:FilterViewController = FilterViewController.instantiate(appStoryboard: .booking)
        vc.modalTransitionStyle = .coverVertical
        vc.navFilterCtrl = self.navigationController
        self.navigationController?.present(vc, animated: true)
    }
    
}

//MARK: ----------------UITABLEVIEW DATASOURCE/DELEGATE

extension BookingListViewController: UITableViewDataSource, UITableViewDelegate{
   
    //MARK: ------------NO DATA FOUND CONFIGURATION
    func noSessionsConfig(inputTable:UITableView?, getCount:Int?) -> Int{
        let msgImage = UIImage(named: "ic_noSessions")
       
        guard let countReturn = inputTable?.numberOfRows(count: self.bookingData?.count, title: AppStrings.no_sessions_found, message: AppStrings.you_have_not_booked_session_yet, messageImage: msgImage, messageImageHeight: (msgImage?.size.height ?? 10) * 0.7, reloadSetTitle: AppStrings.book_session.uppercased(), target: self, action: #selector(reloadData(sender: )), fromTop: 12.0) else { return 0}
      
        return  countReturn
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return noSessionsConfig(inputTable: self.bookingListTbl, getCount: self.bookingData?.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:BookingListTableViewCell = bookingListTbl.dequeueReusableCell(withIdentifier: "BookingListTableViewCell", for: indexPath) as! BookingListTableViewCell
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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let vc:BookingDetailsViewController = BookingDetailsViewController.instantiate(appStoryboard: .booking)
//        self.navigationController?.pushViewController(vc, animated: true)
        
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
        
    }
    
    @objc func reloadData(sender: UIButton){
        self.bookingData?.append(1)
        self.bookingData?.append(1)
        self.bookingData?.append(1)
        self.bookingListTbl.reloadData()
    }
    
}

