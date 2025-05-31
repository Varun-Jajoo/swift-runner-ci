//
//  SlotPopViewController.swift
//  MyPT
//
//  Created by techsaga corp on 20/12/24.
//

import UIKit

class SlotPopViewController: UIViewController {

    //MARK: ------------- VARIABLE
    var navCtrl:UINavigationController?
    var bookingIdStr:String? = nil
    private var newSlotId:Int? = nil
    var dateStr: String? = nil
    var reasonRescheduleStr: String? = nil
    
    
    var modeStr:String? = nil{
        didSet{
            if let modeStr = modeStr {
                self.setSlots(timingStr: modeStr)
            }
        }
    }
    
    private let showCalView = CalendarView()
    var slotsData: AvailabilityDataModel?
    var slotTimes:[SlotModel]? = []
    var disabledTimes: [String] = []
    
    //MARK: -------------IBOUTLET
    @IBOutlet weak var slotpopMBV: UIView!
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var selectTimeTitleLbl: UILabel!
    @IBOutlet weak var sloteCollView: UICollectionView!
    @IBOutlet weak var rescheduleBtn: UIButton!
    @IBOutlet weak var modeStckView: UIStackView!
    @IBOutlet weak var nightModeBtn: UIButton!
    @IBOutlet weak var morningModeBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupFont()
        self.enableContinueBtn(isSelected: false, btn: self.rescheduleBtn)
        self.setModeTime(isNight: false)
        self.modeStr = "morning"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.slotpopMBV.applyTransition(type: .moveIn, subtype: .fromBottom, duration: 0.9, timingFunction: .easeInEaseOut)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    private func setupUI(){
        DispatchQueue.main.async {
            self.slotpopMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            self.slotpopMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.black, shadowRadius: 12, opacity: 0.8, offset: .zero, cornerRadius: 12)
            self.rescheduleBtn.setCornerRadius(borderWidth: 0, borderColor: UIColor.appDarkGray, cornerRadious: 12.0)
            self.modeStckView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 7.63)
            self.nightModeBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 7.63)
            self.morningModeBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 7.63)
        }
    }
    
    @IBAction func commonModeBtnActn(_ sender: UIButton) {
        if sender.tag == 101 {
            self.modeStr = "night"
            self.setModeTime(isNight: true)
        }else{
            self.modeStr = "morning"
            self.setModeTime(isNight: false)
        }
    }
    
    private func setModeTime(isNight:Bool = false){
        
        if isNight {
            self.nightModeBtn.applyTransition(type: .moveIn, subtype: .fromRight, duration: 0.5, timingFunction: .easeInEaseOut, completion: nil)
            
            self.nightModeBtn.setTitle("Night", for: .normal)
            self.nightModeBtn.setImage(AppImages.night_mode?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.nightModeBtn.tintColor = UIColor.mainBg
            
            self.morningModeBtn.setTitle(nil, for: .normal)
            self.morningModeBtn.setImage(AppImages.sunny_mode?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.morningModeBtn.tintColor = UIColor.appWhite
            
            self.nightModeBtn.backgroundColor = UIColor.appWhite
            self.morningModeBtn.backgroundColor = UIColor.clear
            //------------------***************
            
        }else{
            self.morningModeBtn.applyTransition(type: .moveIn, subtype: .fromLeft, duration: 0.5, timingFunction: .easeInEaseOut, completion: nil)
            
            self.nightModeBtn.setTitle(nil, for: .normal)
            self.nightModeBtn.setImage(AppImages.night_mode?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.nightModeBtn.tintColor = UIColor.white
            
            self.morningModeBtn.setTitle("Morning", for: .normal)
            self.morningModeBtn.setImage(AppImages.sunny_mode?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.morningModeBtn.tintColor = UIColor.mainBg
            
            self.nightModeBtn.backgroundColor = UIColor.clear
            self.morningModeBtn.backgroundColor = UIColor.appWhite
            //------------------------------*************
        }
    }
            
    @IBAction func rescheduleBtnActn(_ sender: Any) {
        print("Reschedule btn clicked..")
        self.rescheduleSession(newIdStr: self.newSlotId)
        
        /*
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: NSNotification.Name("DataSlotselected"), object: "Your booking will be rescheduled once the trainer approves the request.")
        })
        */
    }
    
    @IBAction func dismissBtnActn(_ sender: Any) {
        print("Dismiss btn Actn..")
        self.dismiss(animated: true)
    }
    
    func setupFont(){
        self.topTitleLbl.font = AppFont.semibold.size(18.0, familyName: familyManrope)
        self.selectTimeTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.rescheduleBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        
        self.nightModeBtn.titleLabel?.font = AppFont.semibold.size(10.0, familyName: familyManrope)
        self.morningModeBtn.titleLabel?.font = AppFont.semibold.size(10.0, familyName: familyManrope)
        
        //------------------Register tableview
        self.sloteCollView.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")
    }
    
    //MARK: -------------- ENABLE CONTINUE
    func enableContinueBtn(isSelected:Bool = false, btn:UIButton){
        if isSelected {
            btn.isUserInteractionEnabled = true
            btn.backgroundColor = UIColor.appWhite
            btn.setTitleColor(UIColor.mainBg, for: .normal)
        } else {
            btn.isUserInteractionEnabled = false
            btn.backgroundColor = UIColor.appDarkGray
            btn.setTitleColor(UIColor.appWhite, for: .normal)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: view)
                  if !self.slotpopMBV.frame.contains(location) {
                      self.dismiss(animated: true, completion: nil)
                  }else{
                      print("tap at popup view.")
                  }
        }
    }
}

//MARK: ------------UICOLLECIONVIEW DATASOURCE/DELEGATE
extension SlotPopViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return collectionView.numberOfRows(count: slotTimes?.count ?? 0, title: AppAlertStrings.no_results_found, message: "", messageImage: AppImages.search_NoResult?.resized(to: CGSize(width: 100, height: 80)), messageImageHeight: nil, target: nil, fromTop: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ProductCategoryCollViewCell = sloteCollView.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCollViewCell", for: indexPath) as! ProductCategoryCollViewCell
        cell.cellMBV.backgroundColor = UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1)
        
        var time = slotTimes?[indexPath.row].time as? String
        time = time?.replacingOccurrences(of: "AM", with: "")
                   .replacingOccurrences(of: "PM", with: "")
                   .trimmingCharacters(in: .whitespaces)
        cell.titleLbl.text = time
        
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
        
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.width)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.newSlotId = slotTimes?[indexPath.row].id
        self.enableContinueBtn(isSelected: true, btn: self.rescheduleBtn)
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

//MARK: -----------------EXTENSION FOR API
extension SlotPopViewController{
    
    private func setSlots(timingStr: String?){
         let params:[String:String] = [
            "id": self.bookingIdStr ?? "", //id: 1, booking id
            "timing": timingStr ?? "", //timing: morning, morning/night
            "date": self.dateStr ?? "" //date: 2025-04-12, date is required
         ]
        
        BookingVM.allSlotsRescheduleApi(inputParams: params, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
            print("getResultData", getResultData)
            
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
           
            self.sloteCollView.reloadData()
            
            //----------------For left align of cell when data is 1
            if self.slotTimes?.count ?? 0 == 1 {
                self.sloteCollView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .left, animated: true)
                if let flowLayout = sloteCollView.collectionViewLayout as? UICollectionViewFlowLayout {
                    flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 19, bottom: 0, right: sloteCollView.bounds.width)
                }
            }else{
                if let flowLayout = sloteCollView.collectionViewLayout as? UICollectionViewFlowLayout {
                    flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 19, bottom: 0, right: 19)
                }
            }
        })
    }
    
    //MARK: -----------------RESCHEDULE
    private func rescheduleSession(newIdStr: Int?){
        let params:[String:Any] = [
            "id": self.bookingIdStr ?? "", //id:1 ,  booking id main id
            "new_slot_id": newIdStr ?? 0 , //new_slot_id:2 , new slot id
            "reason": self.reasonRescheduleStr ?? "" // reason field is required
        ]
        
        BookingVM.rescheduleSessionConsumerApi(inputParams: params, completion: {[weak self] getResultData in
            guard let self = self, let getResultData = getResultData else { return }
            
            if getResultData["success"] as? Bool == true {
                self.dismiss(animated: true, completion: {
                    NotificationCenter.default.post(name: NSNotification.Name("DataSlotselected"), object: getResultData["msg"] as? String)
                })
            }
        })
    }
}
