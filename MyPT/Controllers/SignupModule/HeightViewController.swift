//
//  HeightViewController.swift
//  MyPT
//
//  Created by techsaga corp on 05/11/24.
//

import UIKit

class HeightViewController: CommonViewController {

    //MARK: -------------VARIABLE
    let heightRengeView = RangePickerView()
    var heightValues = Array(1 ... 12)
    var selectedHeight:String?
    
    
    //MARK: -------------IBOUTLET
    @IBOutlet weak var measureScaleMBV: UIView!
    @IBOutlet weak var heightMeasureType: UISegmentedControl!
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var continueBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setUpFont()
        setUpSegmet()
        setupSegmentedControlStyle()
        enableContinueBtn(isSelected: true)
        setLayout()
        
        if let userData = appUserDefaults.getUserFromUserDefaults(as: UserModel.self), let userName = userData.name {
            print("userData", userData)
            print("userData name: ", userName, "Id: ",userData.id ?? "",  userData.phone ?? "")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    func setNavUI(){
        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        self.setProgress(0.5)
        
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
        self.setRighMenu(rightImgs: [nil], setTitle: [AppStrings.skip_Str], setTintColor: .black, setTitleColor: UIColor.appWhite)
        //        self.setNavigationTitle(title: AppStrings.select_plan, color: UIColor.black, font: AppFont.Bold.size(22.0))
    }
    
    //------------------************Font
    func setUpFont(){
        self.topTitleLbl.font = AppFont.medium.size(28.0, familyName: familyClashDisplay)
        self.continueBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
    
    //MARK: ---------- SET UI
    func setupUI(){
        //-----------*************
        DispatchQueue.main.async {
            self.heightMeasureType.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 6.0)
            self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    func setUpSegmet(){
        heightMeasureType.setTitle("feet", forSegmentAt: 0)
        heightMeasureType.setTitle("cms", forSegmentAt: 1)
        setUISegmentControlAppearance()
    }
    
    func setUISegmentControlAppearance() {
//        UISegmentedControl.appearance().selectedSegmentTintColor = .white
//        UISegmentedControl.appearance().backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.1)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.txtDarkGray, .font:AppFont.semibold.size(14.0, familyName: familyManrope)], for: .normal)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.appWhite, .font:AppFont.semibold.size(14.0, familyName: familyManrope)], for: .selected)
    }
    
    func setLayout(){
        DispatchQueue.main.async {
            self.heightRengeView.frame = self.measureScaleMBV.bounds
            self.measureScaleMBV.addSubview(self.heightRengeView)
        }
        
        heightRengeView.delegate = self
        heightRengeView.alignment = .vertical
        heightRengeView.valueType = "ft"
        heightRengeView.backgroundColor = UIColor.clear
        
        if heightRengeView.alignment == .vertical {
            heightRengeView.transform = CGAffineTransform(rotationAngle: -CGFloat.pi)
        }
    }
    
    
    //MARK: ------------setup segmantstyle
    func setupSegmentedControlStyle(){
        let unselectedBackgroundImage = UIImage(color: UIColor(red: 16/255.0, green: 17/255.0, blue: 19/255.0, alpha: 1))
        let selectedBacgroundImage = UIImage(color:UIColor.appYellow)

        heightMeasureType.setBackgroundImage(unselectedBackgroundImage, for: .normal, barMetrics: .default)
        heightMeasureType.setBackgroundImage(unselectedBackgroundImage, for: .highlighted, barMetrics: .default)
        heightMeasureType.setBackgroundImage(selectedBacgroundImage, for: .selected, barMetrics: .default)

        heightMeasureType.setDividerImage(selectedBacgroundImage, forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)

        heightMeasureType.layer.borderWidth = 0
        heightMeasureType.layer.borderColor = UIColor.clear.cgColor
    }
    
    @IBAction func heightMeasureTypeActn(_ sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex )
        if sender.selectedSegmentIndex == 0 {
            heightValues = Array(1 ... 12)
            heightRengeView.setRange()
            heightRengeView.valueType = "ft"
        }else{
            heightValues = Array(50...250)
            heightRengeView.setRange()
            heightRengeView.valueType = "cm"
        }
    }
    
    
    @IBAction func continueBtnActn(_ sender: Any) {
        
        //--------discussion on responce model as like weight, height data type
        
        if let selectedHeight = self.selectedHeight, !selectedHeight.isEmpty {
            RegistrationVM.addheightApi(viewController: self, inputHeight: selectedHeight, completion: { [weak self] getResultData in
                guard let self = self, let getResultData = getResultData else { return  }
                
                if getResultData.status == true {
                    if let detailsData = getResultData.data {
                        appUserDefaults.saveUserToUserDefaults(detailsData)
                    }
                    
                    let vc:GoalsViewController = GoalsViewController.instantiate(appStoryboard: .main)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            })
        }else{
            AlertHelper.shared.alertMesssage(view: self, title: "", message: AppAlertStrings.select_Height)
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
}

//MARK: -------------EXTENSION FOR RangePickerViewDelegate
extension HeightViewController: RangePickerViewDelegate{
    func rangePickerView(_ rangePickerView: RangePickerView, titleForRowAtIndex row: Int) -> String? {
        String(heightValues[row])
    }

    func rangePickerView(_ rangePickerView: RangePickerView, didSelectRow row: Int) {}

    func rangePickerView(_ rangePickerView: RangePickerView, numberOfIndicesAt row: Int) -> Int? {
        heightValues.count
    }

    func rangePickerView(_ rangePickerView: RangePickerView, headerTitleIndicesAt row: Int) -> String? {
        
        self.selectedHeight = nil
        self.selectedHeight = String(heightValues[row])
        
       return String(heightValues[row])
    }
}
