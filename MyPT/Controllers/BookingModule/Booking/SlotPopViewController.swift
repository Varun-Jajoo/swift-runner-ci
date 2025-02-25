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

    private let showCalView = CalendarView()
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    var slotTimes:[String]?
    
    //MARK: -------------IBOUTLET
    @IBOutlet weak var slotpopMBV: UIView!
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var selectTimeTitleLbl: UILabel!
    @IBOutlet weak var daySegment: UISegmentedControl!
    @IBOutlet weak var sloteCollView: UICollectionView!
    @IBOutlet weak var rescheduleBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupFont()
        self.enableContinueBtn(isSelected: false, btn: self.rescheduleBtn)
        self.setUpSegment()
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
    
    func setupUI(){
        slotTimes = ["10:00 - 11:00","11:00 - 12:00","12:00 - 01:00","01:00 - 02:00","02:00 - 03:00", "03:00 - 04:00", "04:00 - 05:00", "05:00 - 06:00", "06:00 - 07:00","07:00 - 08:00", "09:00 - 10:00", "10:00 - 11:00"]
        
        sloteCollView.register(UINib(nibName: "ProductCategoryCollViewCell", bundle: nil), forCellWithReuseIdentifier: "ProductCategoryCollViewCell")
        
        DispatchQueue.main.async {
            self.slotpopMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            
            self.slotpopMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.black, shadowRadius: 12, opacity: 0.8, offset: .zero, cornerRadius: 12)
            self.rescheduleBtn.setCornerRadius(borderWidth: 0, borderColor: UIColor.appDarkGray, cornerRadious: 12.0)
        }
    }
    
    func setUpSegment(){
//        modeSeg.tintColor = UIColor.appWhite // Set the tint color
        self.daySegment.backgroundColor = UIColor.mainBg.withAlphaComponent(0.6)
        self.daySegment.selectedSegmentIndex = 1
        
        self.daySegment.setImage(UIImage.textEmbededImage(image: AppImages.night_mode!, string: "", color: UIColor.mainBg, segFont: AppFont.semibold.size(10.0, familyName: familyManrope)), forSegmentAt: 0)
        self.daySegment.setImage(UIImage.textEmbededImage(image: AppImages.sunny_mode!, string: "Morning", color: UIColor.mainBg, segFont: AppFont.semibold.size(10.0, familyName: familyManrope)), forSegmentAt: 1)
        
        self.daySegment.setTitleTextAttributes([.foregroundColor: UIColor.mainBg, .font : AppFont.semibold.size(10.0, familyName: familyManrope)], for: .selected)
        self.daySegment.setTitleTextAttributes([.foregroundColor: UIColor.appWhite, .font: AppFont.semibold.size(10.0, familyName: familyManrope)], for: .normal)
    }
    
    
    @IBAction func daySegmActn(_ sender: UISegmentedControl) {
        print("segment tag", sender.selectedSegmentIndex)
        
        let selectedIndex = sender.selectedSegmentIndex
            switch selectedIndex {
            case 0:
                // Handle Option 1
                print("Night mode", selectedIndex)
                daySegment.setImage(UIImage.textEmbededImage(image: AppImages.night_mode!, string: "Night", color: UIColor.mainBg, segFont: AppFont.semibold.size(10.0, familyName: familyManrope)), forSegmentAt: 0)
                daySegment.setImage(UIImage.textEmbededImage(image: AppImages.sunny_mode!, string: "", color: UIColor.mainBg, segFont: AppFont.semibold.size(10.0, familyName: familyManrope)), forSegmentAt: 1)
                break
            case 1:
                print("Morning mode", selectedIndex)
                daySegment.setImage(UIImage.textEmbededImage(image: AppImages.night_mode!, string: "", color: UIColor.mainBg, segFont: AppFont.semibold.size(10.0, familyName: familyManrope)), forSegmentAt: 0)
                daySegment.setImage(UIImage.textEmbededImage(image: AppImages.sunny_mode!, string: "Morning", color: UIColor.mainBg, segFont: AppFont.semibold.size(10.0, familyName: familyManrope)), forSegmentAt: 1)
                
                break
            default:
                break
            }
        
    }
    
    
    @IBAction func rescheduleBtnActn(_ sender: Any) {
        print("Reschedule btn clicked..")
        self.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: NSNotification.Name("DataSlotselected"), object: "Data from selected slot")
        })
    }
    
    @IBAction func dismissBtnActn(_ sender: Any) {
        print("Dismiss btn Actn..")
        self.dismiss(animated: true)
    }
    
    func setupFont(){
        self.topTitleLbl.font = AppFont.semibold.size(18.0, familyName: familyManrope)
        self.selectTimeTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.rescheduleBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
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
        return slotTimes?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:ProductCategoryCollViewCell = sloteCollView.dequeueReusableCell(withReuseIdentifier: "ProductCategoryCollViewCell", for: indexPath) as! ProductCategoryCollViewCell
        cell.cellMBV.backgroundColor = UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1)
        cell.titleLbl.text = slotTimes?[indexPath.row] as? String
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width*0.28, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.enableContinueBtn(isSelected: true, btn: self.rescheduleBtn)
    }
   
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("Did deselect a cell at \(indexPath.row)")
        let cell = collectionView.cellForItem(at: indexPath) as! ProductCategoryCollViewCell
        
        cell.cellMBV.backgroundColor = UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1)
                
    }
    
}
