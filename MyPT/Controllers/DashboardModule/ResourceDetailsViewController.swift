//
//  ResourceDetailsViewController.swift
//  MyPT
//
//  Created by techsaga corp on 13/05/25.
//

import UIKit

class ResourceDetailsViewController: CommonViewController {

    //----------------------VARIABLE
    var resourceData: ResourceModel? 
    var inputShreId: String?
    
    
    //-----------------------SHARE BTN
    lazy var shareNavBtn: UIBarButtonItem = {
        let button =  UIButton(type: .system)
        button.tintColor = UIColor.appWhite
        button.backgroundColor = .clear
        button.setImage(AppImages.shareGymWorkout, for: .normal)
        button.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appWhite, cornerRadious: 12.0)
        button.addTarget(self, action: #selector(shareBtnTapped), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        return UIBarButtonItem(customView: button)
    }()
    
    //MARK: ---------------- IBOUTLET
    @IBOutlet weak var resourceImgView: UIImageView!
    @IBOutlet weak var topMBV: UIView!
    @IBOutlet weak var resourceNameLbl: UILabel!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var timeBtn: UIButton!
    @IBOutlet weak var detailsMBV: UIView!
    @IBOutlet weak var introductionLbl: UILabel!
    @IBOutlet weak var detailsDescTxtView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.setupFont()
        self.setInputData()
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
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [nil], setTintColor: .black, setTitleColor: UIColor.appWhite)
        navigationItem.rightBarButtonItem = self.shareNavBtn
    }
    
    @objc func shareBtnTapped() {
        print("Custom right button tapped")
//        Utility.shared.shareSocial(viewController: self, textToShare: "Share to social", imageToShare: AppImages.navLeft ?? UIImage(), urlShareStr: "https://www.google.com/")
        
        ImageDownloader.shared.downloadImage(from: self.resourceData?.image ?? "", completion: {[weak self] img in
        guard let self = self , let img = img else {
        return
        }
        let getBaseUrl:String = AppBaseUrl.baseScheme.rawValue + "://" + AppBaseUrl.baseDevUrl.rawValue
        print(getBaseUrl)
        //            let urlString = "https://mobileapp.mypt-me.com/\(self.inputType ?? "")/\(studioDetails?.id ?? 0)/\(gymDetailsFlow)"
        
            let urlString = "\(getBaseUrl)/\("fitnessResouce")/\(self.inputShreId ?? "")/\("healthPfofile")"
        Utility.shared.shareSocial(viewController: self, textToShare: self.resourceData?.title ?? "", imageToShare: img, urlShareStr: urlString)
        })
    }
    
    private func setInputData(){
        self.resourceImgView.loadImage(urlString: self.resourceData?.image, placeholder: nil)
        self.resourceNameLbl.text = self.resourceData?.title
        self.dateBtn.setTitle(" " + (self.resourceData?.date ?? ""), for: .normal)
        self.timeBtn.setTitle(" " + (self.resourceData?.readingTime ?? ""), for: .normal)
        self.detailsDescTxtView.text = self.resourceData?.description
    }
    
    private func setupUI(){
        DispatchQueue.main.async {
            self.detailsMBV.roundSideCorners(radius: 32.0, cornerSide: [.topLeft, .topRight])
//            self.topMBV.addGradientLayer(colors: UIColor.appMultiColor(.gradientColor2), locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1.0), cornerRadius: 0)
            
//            self.topMBV.addGradientLayer(colors: [UIColor(red: 0, green: 0, blue: 0, alpha: 0), UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)], locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1.0), cornerRadius: 0)
            
            self.topMBV.addGradient(colors: [UIColor(red: 0, green: 0, blue: 0, alpha: 0), UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)], locations: [0,1], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0, y: 1.0), cornerRadius: 0)
            
        }
    }
    
    private func setupFont(){
        self.resourceNameLbl.font = AppFont.semibold.size(20.0, familyName: familyClashDisplay)
        self.dateBtn.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.timeBtn.titleLabel?.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.introductionLbl.font = AppFont.semibold.size(18.0, familyName: familyManrope)
        self.detailsDescTxtView.font = AppFont.regular.size(14.0, familyName: familyManrope)
        
        self.dateBtn.setTitleColor(UIColor.appWhite, for: .normal)
        self.timeBtn.setTitleColor(UIColor.appWhite, for: .normal)
        self.dateBtn.setImage(UIImage(named: "ic_clock")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.dateBtn.tintColor = UIColor.appWhite
        
        self.timeBtn.setImage(UIImage(named: "ic_clock")?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.timeBtn.tintColor = UIColor.appWhite
        
//        self.dateBtn.setTitleColor(UIColor(red: 212.0/255.0, green: 212.0/255.0, blue: 212.0/255.0, alpha: 1.0), for: .normal)
//        self.timeBtn.setTitleColor(UIColor(red: 212.0/255.0, green: 212.0/255.0, blue: 212.0/255.0, alpha: 1.0), for: .normal)
//        self.dateBtn.setImage(UIImage(named: "ic_clock")?.withRenderingMode(.alwaysTemplate), for: .normal)
//        self.dateBtn.tintColor = UIColor(red: 212.0/255.0, green: 212.0/255.0, blue: 212.0/255.0, alpha: 1.0)
//        
//        self.timeBtn.setImage(UIImage(named: "ic_clock")?.withRenderingMode(.alwaysTemplate), for: .normal)
//        self.timeBtn.tintColor = UIColor(red: 212.0/255.0, green: 212.0/255.0, blue: 212.0/255.0, alpha: 1.0)
    }

}
