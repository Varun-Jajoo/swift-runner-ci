//
//  AgeViewController.swift
//  MyPT
//
//  Created by techsaga corp on 05/11/24.
//

import UIKit

class AgeViewController: CommonViewController {

    //MARK: -------------VARIABLE
    private let datePickerContainer = DatePickerContainerView2() //DatePickerContainerView()
    var selectedDate:String?
    
    
    //MARK: ----------IBOUTLET
    @IBOutlet weak var bottomNoteMBV: UIView!
    @IBOutlet weak var noteLbl: UILabel!
    @IBOutlet weak var continueBtn: UIButton!
    
    @IBOutlet weak var yearsMBV: UIView!
    @IBOutlet weak var monthsMBV: UIView!
    @IBOutlet weak var daysMBV: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setUpFont()
        self.enableContinueBtn(isSelected: true)
//        self.setupCustomDOB()
        self.setupCostomDOB2()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    func setNavUI(){
        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        self.setProgress(0.4)
        
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
        self.setRighMenu(rightImgs: [nil], setTitle: [AppStrings.skip_Str], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    //MARK: ---------- SET UI
    func setupUI(){
        //-----------*************
        DispatchQueue.main.async {
            self.bottomNoteMBV.setCornerRadius(borderWidth: 1, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    //------------------************Font
    func setUpFont(){
        self.noteLbl.font = AppFont.regular.size(12.0, familyName: familyOverpass)
        self.continueBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
    
    @IBAction func continueBtnActn(_ sender: Any) {
        print("Continue btn actn.....")
        //"dob"="2022-12-28"
        if let selectedDate = selectedDate, !selectedDate.isEmpty {
            print("selectedDate = ", selectedDate)
            
            RegistrationVM.addDobApi(viewController: self, inputDob: selectedDate, completion: { [weak self] getResultData in
                guard let self = self else { return  }
                
                if getResultData?.status == true {
                    
                    if let detailsData = getResultData?.data {
                        appUserDefaults.saveUserToUserDefaults(detailsData)
                    }
                    
                    let vc:LoadingViewController = LoadingViewController.instantiate(appStoryboard: .main)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            })
        }else{
            AlertHelper.shared.alertMesssage(view: self, title: "", message: AppAlertStrings.select_dob)
        }
        
        
//        let vc:LoadingViewController = LoadingViewController.instantiate(appStoryboard: .main)
//        self.navigationController?.pushViewController(vc, animated: true)
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
    
    func setupCostomDOB2(){
        
        datePickerContainer.delegate = self
        DispatchQueue.main.async {
            self.datePickerContainer.frame = self.yearsMBV.bounds
            self.yearsMBV.addSubview(self.datePickerContainer)
        }

      datePickerContainer.backgroundColor = UIColor.clear
      
    }
    
    
    //MARK: ----------------MAKE CUSTOM DOB
    func setupCustomDOB(){
        DispatchQueue.main.async {
            var circularPicker = CustomCircularDOB() //CustomPickerView()
            circularPicker.frame = self.yearsMBV.bounds
            circularPicker.pickerType = .year // Set the initial picker type
                circularPicker.backgroundColor = UIColor.mainBg
            circularPicker.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: circularPicker.frame.size.width/2.0)
//                circularPicker.frame.origin.x = 30
            self.yearsMBV.addSubview(circularPicker)
            
            self.yearsMBV.backgroundColor = UIColor.black
            
            var circularPickerM = CustomCircularDOB() //CircularPicker()
            circularPickerM.frame = self.monthsMBV.bounds
            circularPickerM.pickerType = .month // Set the initial picker type
//                circularPickerM.frame.origin.x = 30
           
            circularPickerM.backgroundColor = UIColor.mainBg
            circularPickerM.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: circularPicker.frame.size.width/2.0)
            self.monthsMBV.addSubview(circularPickerM)
            
            var circularPickerDay = CustomCircularDOB()
            circularPickerDay.frame = self.daysMBV.bounds
            circularPickerDay.pickerType = .day // Set the initial picker type
//            circularPickerDay.backgroundColor = UIColor.clear
            circularPickerDay.backgroundColor = UIColor.mainBg
            circularPickerDay.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: circularPicker.frame.size.width/2.0)
//                circularPickerDay.frame.origin.x = 30
            self.daysMBV.addSubview(circularPickerDay)
        }
    }
    
}

//MARK: --------------------- DatePickerContainerDelegate
extension AgeViewController: DatePickerContainerDelegate{
    func selectDate(date: (year: String?, month: String?, day: String?)?) {
        selectedDate = nil
        guard let date = date else { return }
        print("selected date is = ", date)
        selectedDate = "\(date.year ?? "")-\(date.month ?? "")-\(date.day ?? "")"
    }
    
    func selectAge(age: String?) {
        print("age is = ", age ?? "")
    }
}
