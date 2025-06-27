//
//  HealthDataViewController.swift
//  MyPT
//
//  Created by techsaga corp on 26/06/25.
//

import UIKit

class HealthDataViewController: CommonViewController {

    //MARK: ------------VARIABLE
    var gaugeView: GaugeView!
    
//    let ringView = ProgressRingView()
    
    
    //MARK: ------------IBOUTLET
    @IBOutlet weak var healthDataMStck: UIStackView!
    @IBOutlet weak var topSegMBV: UIStackView!
    @IBOutlet weak var healthMBV: UIView!
    @IBOutlet weak var myStatsMBV: UIView!
    @IBOutlet weak var topLineView: UIView!
    @IBOutlet weak var heightWeightMV: UIStackView!
    @IBOutlet weak var heightMBV: UIView!
    @IBOutlet weak var weightMBV: UIView!
    @IBOutlet weak var clientDataMBV: UIView!
    @IBOutlet weak var goalMBV: UIView!
    @IBOutlet weak var dietMBV: UIView!
    @IBOutlet weak var UpcomingMealsMBV: UIView!
    @IBOutlet weak var fitnessResourceMBV: UIView!
    @IBOutlet weak var motivationMBV: UIView!
    @IBOutlet weak var footerImgView: UIImageView!
    @IBOutlet weak var healthBtn: UIButton!
    @IBOutlet weak var myStatsBtn: UIButton!
    @IBOutlet weak var heightTitleLbl: UILabel!
    @IBOutlet weak var heightUnitLbl: UILabel!
    @IBOutlet weak var weightTitleLbl: UILabel!
    @IBOutlet weak var weightUnitLbl: UILabel!
    @IBOutlet weak var clientDataTitleLbl: UILabel!
    @IBOutlet weak var specificGoalTitleLbl: UILabel!
    @IBOutlet weak var showGoalBtn: UIButton!
    @IBOutlet weak var dietTitleLbl: UILabel!
    @IBOutlet weak var dietSeeMoreBtn: UIButton!
    @IBOutlet weak var upcomingMealsTitleLbl: UILabel!
    @IBOutlet weak var upcomingMealsSeeMoreBtn: UIButton!
    @IBOutlet weak var upcomingMealsImgView: UIImageView!
    @IBOutlet weak var fuelBodyNutritionLbl: UILabel!
    @IBOutlet weak var fuelBodyNutritionDescLbl: UILabel!
    @IBOutlet weak var fitnessResourceTitleLbl: UILabel!
    @IBOutlet weak var fitnessSeeMoreBtn: UIButton!
    @IBOutlet weak var motivationLineV: UILabel!
    @IBOutlet weak var motivationSubV: UIView!
    @IBOutlet weak var motivationQuotesLbl: UILabel!
    @IBOutlet weak var writerLbl: UILabel!
    @IBOutlet weak var fitnessTblView: UITableView!
    @IBOutlet weak var clientDataCollView: UICollectionView!
    @IBOutlet weak var dietCollView: UICollectionView!
    @IBOutlet weak var fitnessTblViewHeightConstrrnt: NSLayoutConstraint!
    
    //------------------**************
    @IBOutlet weak var myStatsMStck: UIStackView!
    @IBOutlet weak var healthOverviewMBV: UIView!
    @IBOutlet weak var healthSubView: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        healthDataMStck.isHidden = false
        myStatsMStck.isHidden = true
        setupFont()
        setupUI()
        self.registerCell()
        self.setSegBtn(isHealth: true)
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
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: ["Health Data"], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    private func gaugeViewSet(){
        
//        let gauge = GaugeView()
//        gauge.translatesAutoresizingMaskIntoConstraints = false
//        healthSubView.addSubview(gauge)
//
//        NSLayoutConstraint.activate([
////            gauge.leadingAnchor.constraint(equalTo: healthSubView.leadingAnchor),
////            gauge.trailingAnchor.constraint(equalTo: healthSubView.trailingAnchor),
//            gauge.centerXAnchor.constraint(equalTo: healthSubView.centerXAnchor),
//            gauge.centerYAnchor.constraint(equalTo: healthSubView.centerYAnchor),
//            gauge.widthAnchor.constraint(equalToConstant: 200),
//            gauge.heightAnchor.constraint(equalToConstant: 100)
////            gauge.bottomAnchor.constraint(equalTo: healthSubView.bottomAnchor),
////            gauge.heightAnchor.constraint(equalTo: healthSubView.heightAnchor, multiplier: 0.5)
//        ])
//        
//        
//        // Set progress
////        gauge.progress = 0.75
//        
//                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                            gauge.progress = 0.75
//                        }
        
        
        
        /*
        gaugeView = GaugeView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        gaugeView.translatesAutoresizingMaskIntoConstraints = false
        healthSubView.addSubview(gaugeView)
        
        NSLayoutConstraint.activate([
                    gaugeView.centerXAnchor.constraint(equalTo: healthSubView.centerXAnchor),
                    gaugeView.centerYAnchor.constraint(equalTo: healthSubView.centerYAnchor),
                    gaugeView.widthAnchor.constraint(equalToConstant: 200),
                    gaugeView.heightAnchor.constraint(equalToConstant: 200)
                ])

                // Example: Animate progress after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.gaugeView.progress = 0.75 // Set to 75%
                }

    */
        
        let gauge = GaugeView()
        gauge.translatesAutoresizingMaskIntoConstraints = false
        healthSubView.addSubview(gauge)

        NSLayoutConstraint.activate([
//            gauge.centerXAnchor.constraint(equalTo: healthSubView.centerXAnchor),
//            gauge.centerYAnchor.constraint(equalTo: healthSubView.centerYAnchor),
            
            gauge.topAnchor.constraint(equalTo: healthSubView.topAnchor, constant: 10),
            gauge.bottomAnchor.constraint(equalTo: healthSubView.bottomAnchor, constant: -1),
            gauge.widthAnchor.constraint(equalTo: healthSubView.widthAnchor, multiplier: 1),
            gauge.heightAnchor.constraint(equalTo: gauge.widthAnchor, multiplier: 0.6)
        ])

        gauge.progress = 0.6 // 60%
        
    }
    
    private func registerCell(){
        clientDataCollView.register(UINib(nibName: "ClientDataCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "ClientDataCollectionViewCell")
        dietCollView.register(UINib(nibName: "UpcomingMealsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "UpcomingMealsCollectionViewCell")
        fitnessTblView.register(UINib(nibName: "FitnessResourcesTableViewCell", bundle: nil), forCellReuseIdentifier: "FitnessResourcesTableViewCell")
    }
    
    enum healthBtnTag: Int {
    case health = 1201, myStats, moreDiet, moreUpcoming, moreFitness
    }
    
    @IBAction func commonHealthBtnActn(_ sender: UIButton) {
        
        switch sender.tag {
        case healthBtnTag.health.rawValue:
            print("health btn clicked")
            self.setSegBtn(isHealth: true)
        case healthBtnTag.myStats.rawValue:
            print("myStats btn clicked")
            self.setSegBtn(isHealth: false)
        case healthBtnTag.moreDiet.rawValue:
            print("moreDiet btn clicked")
        case healthBtnTag.moreUpcoming.rawValue:
            print("moreUpcoming btn clicked")
        case healthBtnTag.moreFitness.rawValue:
            print("moreFitness btn clicked")
        default:
            print("None.......")
            break
        }
    }
    
    
    private func setSegBtn(isHealth:Bool){
//        healthDataMStck.isHidden = true
//        myStatsMStck.isHidden = true
        
        if isHealth {
            self.healthBtn.applyTransition(type: .moveIn, subtype: .fromRight, duration: 0.5, timingFunction: .easeInEaseOut, completion: {[weak self] in
                guard self != nil else {
                    return
                }
                self?.healthDataMStck.isHidden = false
                self?.myStatsMStck.isHidden = true
            })
            
            self.healthBtn.backgroundColor = UIColor.appWhite
            self.myStatsBtn.backgroundColor = UIColor.clear
            self.healthBtn.setTitleColor(UIColor.mainBg, for: .normal)
            self.myStatsBtn.setTitleColor(UIColor.appWhite, for: .normal)
        }
        else{
            self.myStatsBtn.applyTransition(type: .moveIn, subtype: .fromLeft, duration: 0.5, timingFunction: .easeInEaseOut, completion: {[weak self] in
                guard self != nil else {
                    return
                }
                self?.healthDataMStck.isHidden = true
                self?.myStatsMStck.isHidden = false
                
                self?.gaugeViewSet()
            })
            self.healthBtn.backgroundColor = UIColor.clear
            self.myStatsBtn.backgroundColor = UIColor.appWhite
            self.myStatsBtn.setTitleColor(UIColor.mainBg, for: .normal)
            self.healthBtn.setTitleColor(UIColor.appWhite, for: .normal)
            
//            self.gaugeViewSet()
        }
    }
    
    private func setupUI(){
        DispatchQueue.main.async {
            [
                self.heightMBV,
                self.weightMBV
            ].forEach({[weak self] in
                guard self != nil else {
                    return
                }
                $0?.addGradient(colors: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 0.7), UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 0.5)], locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 12)
            })
            
            self.showGoalBtn.addGradient(colors: [UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 0.6), UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 0.5)], locations: [0,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 0, y: 0), cornerRadius: 12)
                                    
            self.motivationLineV.backgroundColor = UIColor.clear
            self.motivationLineV.addGradient(colors: UIColor.appMultiColor(.lineVGradient2), locations: [0,0.5,1], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1), cornerRadius: 0.2)
            
            self.topSegMBV.backgroundColor = UIColor(red: 28/255.0, green: 31/255.0, blue: 33/255.0, alpha: 1.0)
            DispatchQueue.main.async {
                self.topSegMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
                self.healthBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
                self.myStatsBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 8.0)
            }
        }
    }
    
    private func setupFont(){
        [
            healthBtn.titleLabel,
            myStatsBtn.titleLabel,
            fuelBodyNutritionDescLbl
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        })
        
        [
            heightTitleLbl,
            weightTitleLbl,
            clientDataTitleLbl,
            specificGoalTitleLbl,
            dietTitleLbl,
            upcomingMealsTitleLbl,
            fitnessResourceTitleLbl
        ].forEach({[weak self] in
            guard self != nil else {
                return
            }
            $0?.font = AppFont.semibold.size(16.0, familyName: familyManrope)
        })
         
        self.showGoalBtn.titleLabel?.font = AppFont.medium.size(18.0, familyName: familyClashDisplay)
        fuelBodyNutritionLbl.font = AppFont.medium.size(24, familyName: familyClashDisplay)
        motivationQuotesLbl.font = AppFont.medium.size(24, familyName: familyClashDisplay)
        writerLbl.font = AppFont.regular.size(12, familyName: familyClashDisplay)
        
        let firstPart = setAttributedTxt(inputLabel: self.heightUnitLbl, mainStr: "5", subStr: "ft")
        let secondPart = setAttributedTxt(inputLabel: self.heightUnitLbl, mainStr: "7", subStr: "in")

        let combined = NSMutableAttributedString(attributedString: firstPart)
        combined.append(secondPart)

        heightUnitLbl.attributedText = combined
        
        weightUnitLbl.attributedText = setAttributedTxt(inputLabel: self.heightUnitLbl, mainStr: "58", subStr: "kg")
        
    }
    
    private func setAttributedTxt(inputLabel:UILabel, mainStr: String, subStr: String) -> NSAttributedString{
        //-------------------- Attributed Text for Price
        let defaultAttributes = [
            .font: AppFont.medium.size(48.0, familyName: familyClashDisplay),
            .foregroundColor: UIColor.appWhite
        ] as [NSAttributedString.Key : Any]
        
        let makeAttributes = [
            mainStr,
            subStr.attributedStringWithGradient([UIColor.appWhite, UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0)], frame: inputLabel.bounds, font: AppFont.medium.size(30.0, familyName: familyClashDisplay), startPoint: CGPoint(x: 1, y: 1), endPoint: CGPoint(x: 0, y: 0))
        ] as [AttributedStringComponent]
                
        return NSAttributedString(from: makeAttributes, defaultAttributes: defaultAttributes) ?? NSAttributedString()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        
        if fitnessTblView.contentSize.height != 0 {
            self.fitnessTblViewHeightConstrrnt.constant = fitnessTblView.contentSize.height
        }
        view.layoutIfNeeded()
    }
    
  }


extension HealthDataViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == dietCollView {
            let dietCell: UpcomingMealsCollectionViewCell = dietCollView.dequeueReusableCell(withReuseIdentifier: "UpcomingMealsCollectionViewCell", for: indexPath) as! UpcomingMealsCollectionViewCell
            DispatchQueue.main.async {
                dietCell.setGradientMultiBorder(cornerRadius: 24.0, width: 1.5, colors: [UIColor(red: 49.0/255.0, green: 52.0/255.0, blue: 58.0/255.0, alpha: 1.0), UIColor(red: 135.0/255.0, green: 143.0/255.0, blue: 160.0/255.0, alpha: 1.0)], startPoint: CGPoint(x: 0, y: 1), endPoint: CGPoint(x: 1, y: 1))
            }
            
            dietCell.mealTypeImgViewHeightConstrnt.constant = 10.0
            dietCell.likeBtnTopconstrnt.constant = 1.0
            dietCell.mealTypeImgview.isHidden = true
            dietCell.mealsTypeTitleLbl.isHidden = true
            
            return dietCell
        }else if collectionView == clientDataCollView{
            let dataCell: ClientDataCollectionViewCell = clientDataCollView.dequeueReusableCell(withReuseIdentifier: "ClientDataCollectionViewCell", for: indexPath) as! ClientDataCollectionViewCell
            dataCell.clientDataProgressMBV.isHidden = true
            dataCell.unitLbl.text = "NA"
            return dataCell
        }
       
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         if collectionView == dietCollView{
            return CGSize(width: collectionView.frame.width*0.75, height: collectionView.frame.height)
         }else{
             return CGSize(width: collectionView.frame.width*0.43, height: collectionView.frame.height)
         }
    }
    
}

extension HealthDataViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let fitnessCell: FitnessResourcesTableViewCell = fitnessTblView.dequeueReusableCell(withIdentifier: "FitnessResourcesTableViewCell", for: indexPath) as! FitnessResourcesTableViewCell
        
        
        return fitnessCell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
    }
    
}
