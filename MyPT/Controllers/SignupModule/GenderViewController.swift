//
//  GenderViewController.swift
//  MyPT
//
//  Created by techsaga corp on 25/10/24.
//

import UIKit

class GenderViewController: CommonViewController {
    
    //MARK: ------------ VARIABLE
    var dataGender:[[String:Any]]?
    var genderImg:[UIImageView]?
    var selectedGender:String?
    
    
    //MARK: --------------IBOUTLET
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var maleMBV: UIView!
    @IBOutlet weak var femaleMBV: UIView!
    @IBOutlet weak var othersMBV: UIView!
    @IBOutlet weak var continueBtn:UIButton!
    @IBOutlet weak var maleBtn: UIButton!
    @IBOutlet weak var femaleBtn: UIButton!
    @IBOutlet weak var othersBtn: UIButton!
    @IBOutlet weak var maleBGImg: UIImageView!
    @IBOutlet weak var femaleBGImg: UIImageView!
    @IBOutlet weak var othersGenderBGImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setUpFont()
        self.enableContinueBtn(isSelected: false)
       
        dataGender = [ ["images":AppImages.male as Any,"seleced_images":AppImages.male_selected as Any],
                       ["images":AppImages.female as Any,"seleced_images":AppImages.female_selected as Any],
                       ["images":AppImages.othersGender as Any,"seleced_images":AppImages.othersGender_selected as Any]
                    ]
        
        genderImg = [maleBGImg,femaleBGImg,othersGenderBGImg]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    func setNavUI(){
        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        self.setProgress(0.3)
        
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
        self.setRighMenu(rightImgs: [nil], setTitle: [AppStrings.skip_Str], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    override func rightBtnActn(sender: UIButton) {
        appSceneDelegate?.goToGuestDashboard()
    }
    
    //------------------************Font
    func setUpFont(){
        self.titleLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.continueBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
    
    //MARK: ---------- SET UI
    func setupUI(){
        DispatchQueue.main.async {
            self.maleMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.femaleMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.othersMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    //MARK: --------> Update View
    func updateUI(selectedView:Int){
        if let genderImg = genderImg {
            for i in genderImg.enumerated() {
                if i.offset == selectedView {
                    self.enableContinueBtn(isSelected: true)
                    i.element.image = dataGender?[i.offset]["seleced_images"] as? UIImage
                }else{
                    i.element.image = dataGender?[i.offset]["images"] as? UIImage
                }
            }
        }
    }
    
//    func updateUI(selectedView:[UIButton]){
//        for i in selectedView{
//            if i.isSelected {
//                self.enableContinueBtn(isSelected: true)
//                i.backgroundColor = UIColor.appBorder
//                i.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188/255.0, blue: 255/255.0, alpha: 1.0), cornerRadious: 16.0)
//            }else{
//                i.backgroundColor = UIColor.clear
//                i.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 16.0)
//            }
//        }
//    }
    
    enum selectedBtn:Int {
        case maleSelect = 301 , femaleSelect, othersSelect
    }
    
    @IBAction func genderSewectionBtnActn(_ sender: UIButton) {
        switch sender.tag {
        case selectedBtn.maleSelect.rawValue:
            self.selectedGender = "male"
            updateUI(selectedView: 0)
        case selectedBtn.femaleSelect.rawValue:
            self.selectedGender = "female"
            updateUI(selectedView: 1)
        case selectedBtn.othersSelect.rawValue:
            self.selectedGender = "other"
            updateUI(selectedView: 2)
        default:
            print("none.......")
        }
    }
    
    @IBAction func continueBtnActn(_ sender:Any){
        print("continue btn clicked.")
        if let selectedGender = self.selectedGender {
            RegistrationVM.addGenderApi(viewController: self, inputGender: selectedGender, completion: { [weak self] getResultData in
                guard let self = self, let getResultData = getResultData else { return  }
                
                if getResultData.status == true {
                    if let detailsData = getResultData.data {
                        appUserDefaults.saveUserToUserDefaults(detailsData)
                    }
                    
                    let vc:AgeViewController = AgeViewController.instantiate(appStoryboard: .main)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            })
        }
        
                
        /*
        let vc:AgeViewController = AgeViewController.instantiate(appStoryboard: .main)
        self.navigationController?.pushViewController(vc, animated: true)
         */
        
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
