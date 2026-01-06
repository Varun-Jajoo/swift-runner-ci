//
//  GenderViewController.swift
//  MyPT
//
//  Created by techsaga corp on 25/10/24.
//

import UIKit

enum selectedBtn: Int {
    case maleSelect = 301, femaleSelect, othersSelect
}

class GenderViewController: CommonViewController {
    
    //MARK: ------------ VARIABLE
    var dataGender: [[String: Any]]?
    var genderImg: [UIImageView]?
    var selectedGender: String?
    private var backgroundGradient: CAGradientLayer?
    
    
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
    @IBOutlet var viewBackground: UIView!
    @IBOutlet weak var lblHelps: UILabel!
    @IBOutlet weak var lblMale: UILabel!
    @IBOutlet weak var lblFemale: UILabel!
    @IBOutlet weak var lblOthers: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setUpFont()
        setupBackgroundGradient()
//        self.enableContinueBtn(isSelected: false)
        updateContinueButton(isEnabled: false)
        setupContinueButtonIcon(isEnabled: false)
       
        dataGender = [
            ["images": AppImages.maleUnselected as Any, "seleced_images": AppImages.maleSelected as Any],
            ["images": AppImages.femaleUnselected as Any, "seleced_images": AppImages.femaleSelected as Any],
            ["images": AppImages.othersUnselected as Any, "seleced_images": AppImages.othersSelected as Any]
        ]
        genderImg = [maleBGImg, femaleBGImg, othersGenderBGImg]
        continueBtn.adjustsImageWhenDisabled = false
        continueBtn.adjustsImageWhenHighlighted = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundGradient?.frame = viewBackground.bounds
    }
    
    func setNavUI() {
        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        self.setProgress(0.3)
        self.setLeftMenu(leftImgs: [AppImages.backArrowWithBg], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
        self.setRighMenu(setTitle: [AppStrings.skipStr], setTintColor: .black, setTitleColor: UIColor.txtSkip)
    }
    
    override func rightBtnActn(sender: UIButton) {
        appUserDefaults.setRegistrationSkip(value: true)
        appSceneDelegate?.setupTab(selectedTab: 0, isGoGeustDashboard: !appUserDefaults.getIsPackageCreated())
    }
    
    //------------------************Font
    func setUpFont() {
        self.lblMale.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        self.lblFemale.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        self.lblOthers.font = AppFont.regular.size(16.0, familyName: familyFunnelSans)
        self.lblHelps.font = AppFont.semibold.size(14.0, familyName: familyFunnelSans)
        self.titleLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.continueBtn.titleLabel?.font = AppFont.medium.size(14.0, familyName: familyFunnelSans)
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
    
    private func setupBackgroundGradient() {
        // Remove old gradient if any
        backgroundGradient?.removeFromSuperlayer()

        let gradient = CAGradientLayer()
        gradient.colors = UIColor.appMultiColor(.greenBgGradient).map { $0.cgColor }

        // VERY IMPORTANT – match first UI direction
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint   = CGPoint(x: 1.0, y: 1.0)

        gradient.locations = [0.0, 0.5, 1.0]
        gradient.cornerRadius = 0

        viewBackground.layer.insertSublayer(gradient, at: 0)
        backgroundGradient = gradient
    }
    
    //MARK: --------> Update View
    func updateUI(selectedView:Int){
        if let genderImg = genderImg {
            for i in genderImg.enumerated() {
                if i.offset == selectedView {
                    updateContinueButton(isEnabled: true)
                    i.element.image = dataGender?[i.offset]["seleced_images"] as? UIImage
                } else {
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
    
    func updateContinueButton(isEnabled: Bool) {
        continueBtn.isEnabled = isEnabled
        continueBtn.isUserInteractionEnabled = isEnabled
        
        UIView.animate(withDuration: 0.2) {
            self.setupContinueButtonIcon(isEnabled: isEnabled)
            if isEnabled {
                self.continueBtn.tintColor = .mainBg   // arrow color
                self.continueBtn.backgroundColor = .appWhite
                self.continueBtn.setTitleColor(.mainBg, for: .normal)
            } else {
                self.continueBtn.tintColor = .appWhite
                self.continueBtn.backgroundColor = .appDarkGray
                self.continueBtn.setTitleColor(.appWhite, for: .normal)
            }
        }
    }
    
    func setupContinueButtonIcon(isEnabled: Bool) {
        let arrowImage = UIImage(named: isEnabled ? "blackRightArrow" : "whiteRightArrow")?
            .withRenderingMode(.alwaysOriginal)
        
        continueBtn.setImage(arrowImage, for: .normal)
        
        // Force image on right side
        continueBtn.semanticContentAttribute = .forceRightToLeft
        
        // Space between text and image
        continueBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -12)
        continueBtn.titleEdgeInsets = UIEdgeInsets(top: 0, left: -1, bottom: 0, right: 12)
        
        continueBtn.contentEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
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
                    appUserDefaults.setRegistrationSkip(value: false)
                    
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
//    func enableContinueBtn(isSelected:Bool = false){
//        if isSelected {
//            self.continueBtn.isUserInteractionEnabled = true
//            self.continueBtn.backgroundColor = UIColor.appWhite
//            self.continueBtn.setTitleColor(UIColor.mainBg, for: .normal)
//        } else {
//            self.continueBtn.isUserInteractionEnabled = false
//            self.continueBtn.backgroundColor = UIColor.appDarkGray
//            self.continueBtn.setTitleColor(UIColor.appWhite, for: .normal)
//        }
//    }
}
