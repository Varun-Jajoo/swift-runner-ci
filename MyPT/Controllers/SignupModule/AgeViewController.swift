//
//  AgeViewController.swift
//  MyPT
//
//  Created by techsaga corp on 05/11/24.
//

import UIKit

class AgeViewController: CommonViewController {

    //MARK: -------------VARIABLE
    var selectedDate:String?
    private let dobPicker = WheelDob()
    
    
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
        self.wheelDobSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        dobPicker.frame = CGRect(x: 0, y: 20, width: self.yearsMBV.frame.width, height: 300)
    }
    
    func setNavUI(){
        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        self.setProgress(0.4)
        
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
//        self.setRighMenu(rightImgs: [nil], setTitle: [AppStrings.skip_Str], setTintColor: .black, setTitleColor: UIColor.appWhite) skipe remove need of client
    }
    
    override func rightBtnActn(sender: UIButton) {
        
        appUserDefaults.setRegistrationSkip(value: true)
        appSceneDelegate?.setupTab(selectedTab: 0, isGoGeustDashboard: !appUserDefaults.getIsPackageCreated())
        
//        appSceneDelegate?.goToGuestDashboard()
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
        self.noteLbl.font = AppFont.regular.size(12.0, familyName: familyOverpassMono)
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
                    appUserDefaults.setRegistrationSkip(value: false)
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
    
    func wheelDobSetup(){
        
        dobPicker.delegate = self
        dobPicker.backgroundColor = UIColor.clear
        self.yearsMBV.addSubview(dobPicker)
        
//        let dobPicker = WheelDob()
//         dobPicker.frame = CGRect(x: 0, y: 0, width: self.yearsMBV.frame.width, height: 500)
       
        //        let dobPicker = WheelDob()
        //        dobPicker.frame = CGRect(x: 10, y: 200, width: self.view.frame.width-20, height: 500)
        //        dobPicker.delegate = self
        //        dobPicker.backgroundColor = UIColor.clear //UIColor.black.withAlphaComponent(0.8)
        //        view.addSubview(dobPicker)
        
    }
    
}

extension AgeViewController: SelectedDateDelegate{
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


