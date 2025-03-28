//
//  SlotDurationViewController.swift
//  MyPT
//
//  Created by techsaga corp on 26/11/24.
//

import UIKit

struct GetSlotParamsModel {
    
    var trainer_id: String?
    var type: String?
    var date: String?
    var timing: String?
    var studio_id: String?
    var address_id: String?
    
    func getParams() -> [String: String] {
        var dict: [String: String] = [:]
        
        if let trainer_id = trainer_id { dict["trainer_id"] = trainer_id }
        if let type = type { dict["type"] = type }
        if let date = date { dict["date"] = date }
        if let timing = timing { dict["timing"] = timing }
        if let studio_id = studio_id { dict["studio_id"] = studio_id }
        if let address_id = address_id { dict["address_id"] = address_id }
        
        return dict
    }
}

struct BookSlotParamsModel {
    
    var studio_id: String?
    var type: String?
    var trainer_id: String?
    var slot_id: String?
    var address_id: String?
    
    func getParams() -> [String: String] {
        var dict: [String: String] = [:]
        
        if let trainer_id = trainer_id { dict["trainer_id"] = trainer_id }
        if let type = type { dict["type"] = type }
        if let studio_id = studio_id { dict["studio_id"] = studio_id }
        if let slot_id = slot_id { dict["slot_id"] = slot_id }
        if let address_id = address_id { dict["address_id"] = address_id }
        
        return dict
    }
}


class SlotDurationViewController: CommonViewController {

    //MARK: ------------------VARIABLE
    var inputGetSlotParams:GetSlotParamsModel?
    var inputBookSlotParams:BookSlotParamsModel? = nil
    
    var slotDurationFlow:calendarFlow = .defaultFlow
    let showCalView = CalendarView()
    var selectedDate:String?
    var slotsData: AvailabilityDataModel?
    var slotTimes:[SlotModel]? = []
    var disabledTimes: [String] = [] 
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    //MARK: --------------IBOULTET
    @IBOutlet weak var calendarView: UIView!
    @IBOutlet weak var startEndMBV: UIView!
    @IBOutlet weak var startTitleLbl: UILabel!
    @IBOutlet weak var endTitleLbl: UILabel!
    @IBOutlet weak var startDateBtn: UIButton!
    @IBOutlet weak var endDateBtn: UIButton!
    
    //    @IBOutlet weak var slotDate: FSCalendar!
    @IBOutlet weak var selectTimeTitleLbl: UILabel!
    @IBOutlet weak var modeSeg: UISegmentedControl!
    @IBOutlet weak var dateListCollView: UICollectionView!
    @IBOutlet weak var bottomStck: UIStackView!
    @IBOutlet weak var packageMBV: UIView!
    @IBOutlet weak var bottomPriceMBV: UIView!
    @IBOutlet weak var createPackageBtn: UIButton!
    @IBOutlet weak var amoutLbl: UILabel!
    @IBOutlet weak var viewBreakdownLbl: UILabel!
    @IBOutlet weak var paymentBtn: UIButton!
    @IBOutlet weak var continueBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpSegment()
        self.setUPUI()
        setupCalendarView()
        setUPFont()
        flowSetup()
        
        self.getSlot(params: inputGetSlotParams?.getParams() ?? [:])
        self.setInputData()
    }

    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.view.applyTransition(type: .moveIn, subtype: .fromTop, duration: 0.8, timingFunction: .easeInEaseOut)
        self.calendarView.applyTransition(type: .push, subtype: .fromLeft, duration: 1.4, timingFunction: .easeInEaseOut)
                
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
        
        self.bottomPriceMBV.isHidden = true
        self.packageMBV.isHidden = true
        self.paymentBtn.isHidden = true
        self.dateListCollView.reloadData()
    }
    
    private func setInputData(){
        
        self.createPackageBtn.setTitle("Create a Package and save 50%", for: .normal)
        
        //-------------------- Attributed Text for Price
        var getAmount:String = ""
        var currencyStr:String = ""
        
        if let pricePackage = self.slotsData?.price {
            let components = pricePackage.split(separator: " ")
            getAmount = "\(components.first ?? "")"
            currencyStr = "\(components.last ?? "")"
        }
        
        
        let defaultAttributes = [
            .font: AppFont.bold.size(32.0, familyName: familyManrope),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let makeAttributes = [
            .font: AppFont.regular.size(14.0, familyName: familyManrope),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let attributedNickName = [
            getAmount,
            NSAttributedString(string: currencyStr,
                               attributes: makeAttributes)
        ] as [AttributedStringComponent]
        
        self.amoutLbl.attributedText = NSAttributedString(from: attributedNickName, defaultAttributes: defaultAttributes)
    }
    
    
    func setNavUI(){
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.book_a_Slot], setTintColor: .black, setTitleColor: UIColor.appWhite)
        self.setRighMenu(rightImgs: [AppImages.moreSettings], setTitle: [""], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    private func setUPFont(){
        
        self.selectTimeTitleLbl.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.createPackageBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.createPackageBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.viewBreakdownLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
       
        self.startTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.endTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.startDateBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.endDateBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.continueBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
    
    private func setUPUI(){
        dateListCollView.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")
        
        //---------------**************
        DispatchQueue.main.async {
            self.packageMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.paymentBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
        
        
        /*
        //-------------------- Attributed Text for Price
        let defaultAttributes = [
            .font: AppFont.bold.size(32.0, familyName: familyManrope),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let makeAttributes = [
            .font: AppFont.regular.size(14.0, familyName: familyManrope),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let attributedNickName = [
            "360",
            NSAttributedString(string: "AED",
                               attributes: makeAttributes)
        ] as [AttributedStringComponent]
        
        self.amoutLbl.attributedText = NSAttributedString(from: attributedNickName, defaultAttributes: defaultAttributes)
        */
        
    }
    
    
    private func setupCalendarView() {
           // Add the calendar view to the view controller
//        showCalView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width - 50, height: 100)
        calendarView.backgroundColor = .clear
           calendarView.addSubview(showCalView)
        showCalView.backgroundColor = .clear
        
        showCalView.setCurrentMonth(Calendar.current.component(.month, from: Date()), year: Calendar.current.component(.year, from: Date()))
        
//        showCalView.setCurrentMonth(01, year: 2025)
        
//        showCalView.setCurrentMonth(Int(self.getMonth(inputDateStr: self.selectedDate).0) ?? 01, year: Int(self.getMonth(inputDateStr: self.selectedDate).1) ?? 2024)
           
        showCalView.translatesAutoresizingMaskIntoConstraints = false
           NSLayoutConstraint.activate([
            showCalView.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor, constant: 5),
            showCalView.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor, constant: -5),
            showCalView.topAnchor.constraint(equalTo: calendarView.safeAreaLayoutGuide.topAnchor, constant: 5),
            showCalView.bottomAnchor.constraint(equalTo: calendarView.safeAreaLayoutGuide.bottomAnchor, constant: -5),
//            showCalView.heightAnchor.constraint(equalToConstant: 300) // Adjust height as needed
           ])
        
        //---------------------*********** For Selected date
        if let selectedDate = self.selectedDate {
            showCalView.setCurrentMonth(Int(self.getMonth(inputDateStr: selectedDate).0) ?? 01, year: Int(self.getMonth(inputDateStr: selectedDate).1) ?? 2024)
        }
       
        if let selectedDate = self.selectedDate , let targetDate = dateFromString(selectedDate) {
            self.showCalView.selectedDate = targetDate
        }
        
       }
    
    // Helper function to convert string to Date
    private func dateFromString(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"  // Specify the format of your input string
        return dateFormatter.date(from: dateString)
    }
    
    private func getMonth(inputDateStr:String) -> (String, String){
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "dd-MM-yyyy" //"yyyy-MM-dd"
        
        if let date = inputFormatter.date(from: inputDateStr) {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            
            print("Year: \(year)")
            print("Month: \(month)") // This will be in numeric form (1 for January, 2 for February, etc.)
            return ("\(month)", "\(year)")
        }
        return ("","")
    }

    func setUpSegment(){
//        modeSeg.tintColor = UIColor.appWhite // Set the tint color
        modeSeg.backgroundColor = UIColor.mainBg.withAlphaComponent(0.6)
        modeSeg.selectedSegmentIndex = 1
        
        modeSeg.setImage(UIImage.textEmbededImage(image: AppImages.night_mode!, string: "", color: UIColor.mainBg, segFont: AppFont.semibold.size(10.0, familyName: familyManrope)), forSegmentAt: 0)
        modeSeg.setImage(UIImage.textEmbededImage(image: AppImages.sunny_mode!, string: "Morning", color: UIColor.mainBg, segFont: AppFont.semibold.size(10.0, familyName: familyManrope)), forSegmentAt: 1)
        
        modeSeg.setTitleTextAttributes([.foregroundColor: UIColor.mainBg, .font : AppFont.semibold.size(10.0, familyName: familyManrope)], for: .selected)
        modeSeg.setTitleTextAttributes([.foregroundColor: UIColor.appWhite, .font: AppFont.semibold.size(10.0, familyName: familyManrope)], for: .normal)
    }
    
    @IBAction func selectModeActn(_ sender: UISegmentedControl) {
       
        self.enableContinueBtn(isSelected: false)
        
        let selectedIndex = sender.selectedSegmentIndex
            switch selectedIndex {
            case 0:
                // Handle Option 1
                print("Night mode", selectedIndex)
//                modeSeg.setWidth((UIImage.textEmbededImage(image: AppImages.night_mode!, string: "Night", color: UIColor.mainBg, segFont: AppFont.semibold.size(10.0, familyName: familyManrope))?.size.width ?? 60) + 15, forSegmentAt: 0)
//                modeSeg.setWidth(40, forSegmentAt: 1)
               
                modeSeg.setImage(UIImage.textEmbededImage(image: AppImages.night_mode!, string: "Night", color: UIColor.mainBg, segFont: AppFont.semibold.size(10.0, familyName: familyManrope)), forSegmentAt: 0)
                modeSeg.setImage(UIImage.textEmbededImage(image: AppImages.sunny_mode!, string: "", color: UIColor.mainBg, segFont: AppFont.semibold.size(10.0, familyName: familyManrope)), forSegmentAt: 1)
                
                //------------------***************
                self.bottomPriceMBV.isHidden = true
                self.packageMBV.isHidden = true
               
                self.inputBookSlotParams = nil
                inputGetSlotParams?.timing = "night"
                self.getSlot(params: inputGetSlotParams?.getParams() ?? [:])
                
                
                break
            case 1:
                print("Morning mode", selectedIndex)
//                modeSeg.setWidth((UIImage.textEmbededImage(image: AppImages.sunny_mode!, string: "Morning", color: UIColor.mainBg, segFont: AppFont.semibold.size(10.0, familyName: familyManrope))?.size.width ?? 60) + 15, forSegmentAt: 1)
//                modeSeg.setWidth(40, forSegmentAt: 0)
                
                modeSeg.setImage(UIImage.textEmbededImage(image: AppImages.night_mode!, string: "", color: UIColor.mainBg, segFont: AppFont.semibold.size(10.0, familyName: familyManrope)), forSegmentAt: 0)
                modeSeg.setImage(UIImage.textEmbededImage(image: AppImages.sunny_mode!, string: "Morning", color: UIColor.mainBg, segFont: AppFont.semibold.size(10.0, familyName: familyManrope)), forSegmentAt: 1)
               
                //------------------------------*************
                self.bottomPriceMBV.isHidden = true
                self.packageMBV.isHidden = true
                
                self.inputBookSlotParams = nil
                inputGetSlotParams?.timing = "morning"
                self.getSlot(params: inputGetSlotParams?.getParams() ?? [:])
                
                break
            default:
                break
            }
    }
    
    
    //MARK: -------------FLOW SETUP
    func flowSetup(){
        
        self.enableContinueBtn(isSelected: false)
        
        switch slotDurationFlow {
        case .bookTrainer:
            self.calendarView.isHidden = false
            self.bottomPriceMBV.isHidden = true
            self.packageMBV.isHidden = true
            self.startEndMBV.isHidden = true
            self.continueBtn.isHidden = true
          
        case .createPackage:
            self.calendarView.isHidden = true
            self.packageMBV.isHidden = true
            self.bottomPriceMBV.isHidden = true
            self.startEndMBV.isHidden = false
            self.continueBtn.isHidden = false
            
            self.startDateBtn.isUserInteractionEnabled = false
            self.endDateBtn.isUserInteractionEnabled = false
            self.startDateBtn.isSelected = true
            updateUI(selectedView: [startDateBtn, endDateBtn])
            
        case .defaultFlow:
            print("default is called..")
        }
    }
    
    //MARK: -------------- ENABLE CONTINUE
    func enableContinueBtn(isSelected:Bool = false){
        if isSelected {
            self.continueBtn.isUserInteractionEnabled = true
            self.continueBtn.backgroundColor = UIColor.appWhite
            self.continueBtn.setTitleColor(UIColor.mainBg, for: .normal)
        } else {
            self.continueBtn.isUserInteractionEnabled = false
            self.continueBtn.backgroundColor = UIColor.appDarkGray
            self.continueBtn.setTitleColor(UIColor.appWhite, for: .normal)
        }
    }
    
    
    //MARK: ------------SHOW DATE START/END
        func updateUI(selectedView:[UIButton]){
            
            for i in selectedView{
                if i.isSelected {
                    i.backgroundColor = UIColor.clear
                    i.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1.0), cornerRadious: 12.0)
                }else{
                    i.backgroundColor = UIColor(red: 49.0/255.0, green: 52.0/255.0, blue: 58.0/255.0, alpha: 1)
                    i.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
                }
            }
        }
    
    //MARK: ----------CREATE PACKAGE BTN ACTN
    @IBAction func createPackageBtnActn(_ sender: Any) {
        print("clicked at createPackageBtn")
        let vc:CreatePackageViewViewController = CreatePackageViewViewController.instantiate(appStoryboard: .booking)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    //MARK: -----------MAKRE PAYMENT BTN ACTN
    @IBAction func paymentBtnActn(_ sender: Any) {
        print("clicked at paymentBtn")
        
        if let slotId = inputBookSlotParams?.slot_id, !slotId.isEmpty {
            self.bookSlot(inputParam: inputBookSlotParams?.getParams() ?? [:])
        }else{
            AlertHelper.shared.alertMesssage(view: self, title: "", message: "Please select slot")
        }
        
        /*
        let vc:PaymentSuccessViewController = PaymentSuccessViewController.instantiate(appStoryboard: .booking)
        self.navigationController?.pushViewController(vc, animated: true)
        */
        
    }
    
    @IBAction func continueBtnActn(_ sender: Any) {
        print("continue btn clicked.")
        let vc:ReviewPackageViewController = ReviewPackageViewController.instantiate(appStoryboard: .booking)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

//MARK: ------------UICOLLECIONVIEW DATASOURCE/DELEGATE
extension SlotDurationViewController:UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return collectionView.numberOfRows(count: slotTimes?.count ?? 0, title: AppAlertStrings.no_results_found, message: "", messageImage: AppImages.search_NoResult?.resized(to: CGSize(width: 150, height: 150)), messageImageHeight: nil, target: nil, fromCenter: -100, fromTop: nil)
        
//        return slotTimes?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        let cell:ProductCategoryCollViewCell = dateListCollView.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCollViewCell", for: indexPath) as! ProductCategoryCollViewCell
        cell.cellMBV.backgroundColor = UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1)
        cell.titleLbl.text = slotTimes?[indexPath.row].time as? String
                
        if let getTimes = slotTimes?[indexPath.row].time as? String {
            let isTimeDisable = self.disabledTimes.contains(getTimes)
            if isTimeDisable {
                cell.cellMBV.backgroundColor = UIColor.appDarkGray
            }else{
                cell.cellMBV.backgroundColor = UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
//        return CGSize(width: collectionView.frame.width*0.28, height: 50)
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.width)
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        switch slotDurationFlow {
        case .bookTrainer:
            //            self.bottomPriceMBV.isHidden = false
            //            self.packageMBV.isHidden = false
            
            if self.bottomPriceMBV.isHidden {
                self.bottomPriceMBV.animShow(duration: 0.2, delay: 0.1) {
                    self.bottomPriceMBV.isHidden = false
                    self.paymentBtn.isHidden = false
//                    self.packageMBV.isHidden = false
                    self.packageMBV.animShow(duration: 0.1, delay: 0) {
                        self.packageMBV.isHidden = false
                    }
                }
            }
            
            //------------------************Booked param
            print("Slot Id: ","\(slotTimes?[indexPath.row].id ?? 0)")
            
            self.inputBookSlotParams = BookSlotParamsModel(studio_id: inputGetSlotParams?.studio_id, type: inputGetSlotParams?.type, trainer_id: inputGetSlotParams?.trainer_id, slot_id: "\(slotTimes?[indexPath.row].id ?? 0)", address_id: inputGetSlotParams?.address_id)
         
        case .createPackage:
            self.enableContinueBtn(isSelected: true)
        case .defaultFlow:
            print("default is called..")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("Did deselect a cell at \(indexPath.row)")
        let cell = collectionView.cellForItem(at: indexPath) as! ProductCategoryCollViewCell
        
        cell.cellMBV.backgroundColor = UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1)
                
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
         guard let getTimes = slotTimes?[indexPath.row].time as? String else { return true }
                 
         return !self.disabledTimes.contains(getTimes)
    }
}

extension SlotDurationViewController{
    
    //MARK: -----------------GET SLOT API
    private func getSlot(params: [String : String]){
        print("params: ", params)
        TrainerVM.getSlotsApi(viewController: self, inputParms: params, completion: { [weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return  }
            
            print(getResultData)
            
            self.slotsData = getResultData.data
            self.slotTimes?.removeAll()
            self.slotTimes?.append(contentsOf: self.slotsData?.slots ?? [])
            print("total slots: ",self.slotTimes?.count ?? 0)
            
            if let getData = getResultData.data?.slots {
                self.disabledTimes.removeAll()
                getData.forEach({[weak self] in
                    guard let self = self else { return  }
                    if let getTime = $0.time, let isBooked = $0.isBooked, isBooked {
                        self.disabledTimes.append(getTime)
                    }
                })
            }
            self.setInputData()
            self.dateListCollView.reloadData()
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
                self.navigationController?.pushViewController(vc, animated: true)
            }
          
        })
    }
}

