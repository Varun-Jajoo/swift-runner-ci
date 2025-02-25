//
//  RepeatFrequencyPopupViewController.swift
//  MyPT
//
//  Created by techsaga corp on 30/12/24.
//

import UIKit

class RepeatFrequencyPopupViewController: UIViewController {

    //MARK: -------------- VARIABLE
    var navCtnl: UINavigationController?
    
    
    var countDays: Int = 0 {
        didSet {
            self.countTxtField.text = "\(countDays)"
        }
    }
    
    //MARK: --------------- IBOUTLET
    @IBOutlet weak var popupMBV: UIView!
    @IBOutlet weak var topBarBtn: UIButton!
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var repeatMBV: UIView!
    @IBOutlet weak var dayMBV: UIView!
    @IBOutlet weak var endsMBV: UIView!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var repeatEveryTitleLbl: UILabel!
    @IBOutlet weak var countTxtField: UITextField!
    @IBOutlet weak var repeatDaysStck: UIStackView!
    @IBOutlet weak var weakBtn: UIButton!
    @IBOutlet weak var DaysBtn: UIButton!
    @IBOutlet weak var weeksBtn: UIButton!
    @IBOutlet weak var daysTitleLbl: UILabel!
    @IBOutlet weak var mBtn: UIButton!
    @IBOutlet weak var tBtn: UIButton!
    @IBOutlet weak var wBtn: UIButton!
    @IBOutlet weak var thBtn: UIButton!
    @IBOutlet weak var fBtn: UIButton!
    @IBOutlet weak var sBtn: UIButton!
    @IBOutlet weak var sunBtn: UIButton!
    @IBOutlet weak var endsTitleLbl: UILabel!
    @IBOutlet weak var noEndsDateMBV: UIView!
    @IBOutlet weak var endOnMBV: UIView!
    @IBOutlet weak var noEndsDateBtn: UIButton!
    @IBOutlet weak var EndsonBtn: UIButton!
    @IBOutlet weak var endsDateBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.countTxtField.isUserInteractionEnabled = false
        self.setuiFont()
        self.daysPopupShow(isShow: false)
        
//        self.updateUI(selectedView: [mBtn,
//                                     tBtn,
//                                     wBtn,
//                                     thBtn,
//                                     fBtn,
//                                     sBtn,
//                                     sunBtn], selectedTag: 0)
        
        //----------------_************
        self.countDays = 1
        self.weakBtn.accessibilityHint = "Days"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        self.view.applyTransition(type: .moveIn, subtype: .fromRight, duration: 0.5, timingFunction: .easeInEaseOut, completion: {
            print("Animation done.")
        })
        
        self.setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        self.setupUI()
    }
    

    @IBAction func doneBtnActn(_ sender:UIButton) {
        print("clicked at done......")
        self.dismiss(animated: true, completion: {
            print("Animation is done.")
        })
        
//        self.dismiss(animated: true, completion: {
//            let vc:TimeSlotPopupViewController = TimeSlotPopupViewController.instantiate(appStoryboard: .calendar)
//            vc.modalPresentationStyle = .automatic
//            vc.navCtrl = self.navCtnl
//            vc.timePopFlow = .repsFreq
//            self.navCtnl?.present(vc, animated: false)
//        })
    }

    //MARK: -----------COMMON BTN TAG
    enum btnTag:Int {
        case countIncrease = 401, countDecrease, weekBtn, daysBtn, weeksBtn
    }
    
    @IBAction func commonBtnActn(_ sender: UIButton) {
        print("common btn clicked..")
        
        switch sender.tag {
        case btnTag.countIncrease.rawValue:
            print("countIncrease clicked..")
  
            guard self.countDays < (self.weakBtn.accessibilityHint == "Days" ? 6 : 4) else {
                return
            }
            
            self.countDays += 1
        case btnTag.countDecrease.rawValue:
            print("countDecrease clicked..")
            guard self.countDays > 1 else {
                return
            }
            self.countDays -= 1
        case btnTag.weekBtn.rawValue:
            print("weeks clicked..")
            weakBtn.isSelected = !weakBtn.isSelected
            if weakBtn.isSelected {
                weakBtn.isSelected = !weakBtn.isSelected
                daysPopupShow(isShow: true)
            }else{
                daysPopupShow(isShow: false)
            }
            
        case btnTag.daysBtn.rawValue:
            print("daysBtn clicked..")
            self.dayMBV.isHidden = false
//            self.dayMBV.isHidden = true
            daysPopupShow(isShow: false)
            self.countDays = 1
            self.weakBtn.accessibilityHint = "Days"
            self.weakBtn.setTitle("Days", for: .normal)
        case btnTag.weeksBtn.rawValue:
            print("weeksBtn clicked..")
            self.dayMBV.isHidden = true
//            self.dayMBV.isHidden = false
            self.countDays = 1
            self.weakBtn.accessibilityHint = "Weeks"
            self.weakBtn.setTitle("Weeks", for: .normal)
            daysPopupShow(isShow: false)
            
        default:
          print("default...... none of these")
        }
    }
    
    func daysPopupShow(isShow: Bool){
        
        if isShow {
            self.DaysBtn.isHidden = false
            self.weeksBtn.isHidden = false
        }else{
            self.DaysBtn.isHidden = true
            self.weeksBtn.isHidden = true
        }
    }
    
    //MARK: -------------DAYS BTNS
    
    //MARK: -----------COMMON BTN TAG
    enum daysbtnTag:Int {
        case mon = 4101, tue, wed, thus, fri, sat, sun
    }
    
    @IBAction func daysBtnActn(_ sender: UIButton) {
        print("4101 btn clicked")
        
//        self.updateUI(selectedView: [mBtn,
//                                     tBtn,
//                                     wBtn,
//                                     thBtn,
//                                     fBtn,
//                                     sBtn,
//                                     sunBtn], selectedTag: sender.tag)
        
        switch sender.tag {
        case daysbtnTag.mon.rawValue:
            print("cliecked at mon")
            mBtn.isSelected = !mBtn.isSelected
            if mBtn.isSelected {
                mBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1.0), cornerRadious: 12.0)
             }else{
                 mBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
             }
            
        case daysbtnTag.tue.rawValue:
            tBtn.isSelected = !tBtn.isSelected
          
            if tBtn.isSelected {
                tBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1.0), cornerRadious: 12.0)
             }else{
                 tBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
             }
            
            print("cliecked at tue")
        case daysbtnTag.wed.rawValue:
            wBtn.isSelected = !wBtn.isSelected
            
            if wBtn.isSelected {
                wBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1.0), cornerRadious: 12.0)
             }else{
                 wBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
             }
           
            print("cliecked at wed")
        case daysbtnTag.thus.rawValue:
            thBtn.isSelected = !thBtn.isSelected
            
            if thBtn.isSelected {
                thBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1.0), cornerRadious: 12.0)
             }else{
                 thBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
             }
        
            print("cliecked at thus")
        case daysbtnTag.fri.rawValue:
            fBtn.isSelected = !fBtn.isSelected
            
            if fBtn.isSelected {
                fBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1.0), cornerRadious: 12.0)
             }else{
                 fBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
             }
            
            print("cliecked at fri")
        case daysbtnTag.sat.rawValue:
            sBtn.isSelected = !sBtn.isSelected
            
            if sBtn.isSelected {
                sBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1.0), cornerRadious: 12.0)
             }else{
                 sBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
             }
           
            print("cliecked at sat")
        case daysbtnTag.sun.rawValue:
            sunBtn.isSelected = !sunBtn.isSelected
            
            if sunBtn.isSelected {
                sunBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1.0), cornerRadious: 12.0)
             }else{
                 sunBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
             }
            
            
           
            print("cliecked at sun")
            
        default:
            print("none of these...")
        }
        
    }
    
    
    //MARK: ------------SHOW DATE START/END
    func updateUI(selectedView:[UIButton], selectedTag:Int){
            
            for i in selectedView{
                if i.tag == selectedTag {
                    i.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1.0), cornerRadious: 12.0)
                }else{
                    i.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
                }
            }
        }
    
    func setupUI(){
        DispatchQueue.main.async {
          
            self.popupMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            self.popupMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.black, shadowRadius: 12, opacity: 0.8, offset: .zero, cornerRadius: 12)
            self.countTxtField.setCornerRadius(borderWidth: 0.5, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.repeatDaysStck.setCornerRadius(borderWidth: 0.5, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.mBtn.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.tBtn.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.wBtn.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.thBtn.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.fBtn.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.sBtn.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.sunBtn.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.endsDateBtn.setCornerRadius(borderWidth: 0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.doneBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            
            self.repeatDaysStck.setCornerRadius(borderWidth: 0.5, borderColor: UIColor.appBorder, cornerRadious: 8.0)
        }
    }
    
    func setuiFont(){
        self.topTitleLbl.font = AppFont.semibold.size(18.0, familyName: familyManrope)
        self.doneBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.repeatEveryTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.countTxtField.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.weakBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.DaysBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.weeksBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.daysTitleLbl.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.mBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.tBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.wBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.thBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.fBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.sBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.sunBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.endsTitleLbl.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.noEndsDateBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.EndsonBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        self.endsDateBtn.titleLabel?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: view)
                  if !self.popupMBV.frame.contains(location) {
                      self.dismiss(animated: true, completion: nil)
                  }else{
                      print("tap at popup view.")
                  }
        }
    }
}

