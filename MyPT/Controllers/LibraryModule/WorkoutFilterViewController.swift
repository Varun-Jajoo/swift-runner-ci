//
//  WorkoutFilterViewController.swift
//  MyPT
//
//  Created by techsaga corp on 08/01/25.
//

import UIKit

class WorkoutFilterViewController: UIViewController {

    //MARK: --------------VARIABLE
    var workTypeData:[Any]?
    var filterCount:((Int)-> Void)?
    
    var countItems:Int = 0{
        didSet{
            filterCount?(countItems)
            self.applyFilterBtn.setTitle("APPLY FILTER (\(countItems))", for: .normal)
        }
    }
    
    //MARK: ----------------IBOUTLET
    @IBOutlet weak var filterPopupMBV: UIView!
    @IBOutlet weak var filterByMBV: UIView!
    @IBOutlet weak var filterBySubMbv: UIView!
    @IBOutlet weak var workoutTypeMBV: UIView!
    @IBOutlet weak var bodyPartsMBV: UIView!
    @IBOutlet weak var workoutLevelMBV: UIView!
    @IBOutlet weak var workoutDurationMBV: UIView!
    @IBOutlet weak var workoutRangeMBV: CustomRangeSlider!
    @IBOutlet weak var calorieBurnMBV: UIView!
    @IBOutlet weak var applyFilterMBV: UIView!
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var filterTitleLbl: UILabel!
    @IBOutlet weak var workoutTypeTitleLbl: UILabel!
    @IBOutlet weak var bodypartsLbl: UILabel!
    @IBOutlet weak var workoutLevelTitleLbl: UILabel!
    @IBOutlet weak var durationTitleLbl: UILabel!
    @IBOutlet weak var minutesLbl: UILabel!
    @IBOutlet weak var calorieBurnTitleLbl: UILabel!
    @IBOutlet weak var KcalLbl: UILabel!
    @IBOutlet weak var helpBtn: UIButton!
    @IBOutlet weak var applyFilterBtn: UIButton!
    @IBOutlet weak var filterByTxtField: UITextField!
    @IBOutlet weak var workoutTypeCollView: UICollectionView!
    @IBOutlet weak var bodypartsCollView: UICollectionView!
    @IBOutlet weak var workoutLevelCollView: UICollectionView!
    
    @IBOutlet weak var customThumbSlider: ThumbTextSlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupFont()
        
        self.filterByTxtField.text = "Most Popular"
        
        self.workTypeData = ["ic_filterRunning","ic_Filter_scadling","ic_filter_walking","ic_filter_walking2","ic_filter_cycling","ic_barbell_ diagonal"]
        
        self.setupCustomSlider()
       
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }
    
    @IBAction func helpBtnActn(_ sender: Any) {
        print("helpBtn clicked...")
    }
    
    @IBAction func filterByDropDownBtnActn(_ sender: Any) {
        print("Filter by btn actn clicked.....")
    }

    @IBAction func applyFilterBtnActn(_ sender: Any) {
        print("applyFilterBtnActn clicked..")
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupCustomSlider(){
        self.customThumbSlider.leftThumbImamge = nil
        self.customThumbSlider.thumbBgColor = UIColor.appYellow
        self.customThumbSlider.borderSetup = (UIColor.appWhite, 2.5, 12.0)
        self.customThumbSlider.thumbTextLabel.textColor = UIColor.appWhite
        self.customThumbSlider.thumbTextLabel.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.customThumbSlider.setMinimumValue = 1.0
        self.customThumbSlider.setMaximumValue = 5000
        self.customThumbSlider.setMinvalue = "\u{007E} 1"
        self.customThumbSlider.addTarget(self, action: #selector(sliderValueChanged(slider: )), for: .valueChanged)
    }
    
    //MARK: ------------------Slider action
    @objc func sliderValueChanged(slider:UISlider){
        print("slider is called..", slider.value)
        self.customThumbSlider.thumbTextLabel.text = "\u{007E}" + "\(Int(slider.value))"
        self.customThumbSlider.value = slider.value
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            self.filterByTxtField.setLeftPaddingWithImage(45.0, self.filterByTxtField.font?.lineHeight.magnitude ?? 1.0, UIImage(named: "ic_mostPopularchart"))
            self.filterPopupMBV.roundSideCorners(radius: 12.0, cornerSide: [.topLeft, .topRight])
            self.filterPopupMBV.applyShadow(fillColor: UIColor.appCard2, shadowColor: UIColor.black, shadowRadius: 12, opacity: 0.8, offset: .zero, cornerRadius: 12)
            self.filterBySubMbv.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.txtDarkGray, cornerRadious: 12.0)
            self.applyFilterBtn.setCornerRadius(borderWidth: 0, borderColor: UIColor.appDarkGray, cornerRadious: 12.0)
        }
    }
    
    func setupFont(){
        self.workoutTypeCollView.register(UINib(nibName: "WithMeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "WithMeCollectionViewCell")
        
        self.bodypartsCollView.register(UINib(nibName: "FilterCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FilterCategoryCollectionViewCell")
        self.workoutLevelCollView.register(UINib(nibName: "FilterCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FilterCategoryCollectionViewCell")
        
        self.bodypartsCollView.allowsMultipleSelection = true
        self.workoutLevelCollView.allowsMultipleSelection = true
        
        //------------------------************
        self.topTitleLbl.font = AppFont.bold.size(24.0, familyName: familyManrope)
        self.filterTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.workoutTypeTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.bodypartsLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.workoutLevelTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.durationTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.minutesLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.calorieBurnTitleLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.KcalLbl.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.applyFilterBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }
 
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: view)
                  if !self.filterPopupMBV.frame.contains(location) {
                      self.dismiss(animated: true, completion: nil)
                  }else{
                      print("tap at popup view.")
                  }
        }
    }
}

//MARK: ------------------UICOLLECTIONVIEW DELEGATE/DATASOURCE
extension WorkoutFilterViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == workoutTypeCollView {
            return self.workTypeData?.count ?? 0
        }
        else if collectionView == bodypartsCollView{
            return 5
        }else{
            return 5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == workoutTypeCollView {
            let workoutTypeCell:WithMeCollectionViewCell = workoutTypeCollView.dequeueReusableCell(withReuseIdentifier: "WithMeCollectionViewCell", for: indexPath) as! WithMeCollectionViewCell
          
            DispatchQueue.main.async {
                workoutTypeCell.cellMBV.backgroundColor = UIColor(red: 28.0/255.0, green: 31.0/255.0, blue: 33.0/255.0, alpha: 1.0)
                workoutTypeCell.cellMBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            }
           
            workoutTypeCell.videoThumbnailImgView.image = nil
            workoutTypeCell.videoThumbnailImgView.isHidden = true
            workoutTypeCell.centerImgView.isHidden = false
            workoutTypeCell.centerImgView.image = nil
            workoutTypeCell.centerImgView.image = UIImage(named: self.workTypeData?[indexPath.row] as? String ?? "")
            
            return workoutTypeCell
        }
        else if collectionView == bodypartsCollView{
            let bodypartCell:FilterCategoryCollectionViewCell = bodypartsCollView.dequeueReusableCell(withReuseIdentifier: "FilterCategoryCollectionViewCell", for: indexPath) as! FilterCategoryCollectionViewCell
            
            bodypartCell.gymCategoryImgView.isHidden = true
            bodypartCell.gymCategoryImgView.image = nil
            bodypartCell.gymCategoryImgWidthConstrnt.constant = 1.0
//            bodypartCell.selectionImgView.image = UIImage(named: "ic_filterChecked")
            bodypartCell.selectionImgView.image = UIImage(named: "ic_filterUncheck")
            
            return bodypartCell
            
        }else{
            let levelCell:FilterCategoryCollectionViewCell = workoutLevelCollView.dequeueReusableCell(withReuseIdentifier: "FilterCategoryCollectionViewCell", for: indexPath) as! FilterCategoryCollectionViewCell
            
            levelCell.gymCategoryImgView.isHidden = true
            levelCell.gymCategoryImgView.image = nil
            levelCell.gymCategoryImgWidthConstrnt.constant = 1.0
//            levelCell.selectionImgView.image = UIImage(named: "ic_filterChecked")
            levelCell.selectionImgView.image = UIImage(named: "ic_filterUncheck")
            
            return levelCell
        }
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        
////        let vc:WorkoutDetailsViewController = WorkoutDetailsViewController.instantiate(appStoryboard: .library)
////        self.navigationController?.pushViewController(vc, animated: true)
//    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        
        if collectionView == workoutTypeCollView {
            self.countItems += 1
            
            let selectedCell = collectionView.cellForItem(at: indexPath) as? WithMeCollectionViewCell
            guard let selectedCell = selectedCell else { return }
            selectedCell.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0), cornerRadious: 12.0)
        }
        else if collectionView == bodypartsCollView{
            self.countItems += 1
            
            let bodypartcell = collectionView.cellForItem(at: indexPath) as? FilterCategoryCollectionViewCell
            guard let bodypartcell = bodypartcell else { return }
            bodypartcell.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0), cornerRadious: 12.0)
            bodypartcell.selectionImgView.image = UIImage(named: "ic_filterChecked")
            
        }else{
            self.countItems += 1
            
            let filtercell = collectionView.cellForItem(at: indexPath) as? FilterCategoryCollectionViewCell
            guard let filtercell = filtercell else { return }
            filtercell.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0), cornerRadious: 12.0)
            filtercell.selectionImgView.image = UIImage(named: "ic_filterChecked")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
      
        
        if collectionView == workoutTypeCollView {
           
            let deselectedcell = collectionView.cellForItem(at: indexPath) as? WithMeCollectionViewCell
            guard let deselectedcell = deselectedcell else { return }
            deselectedcell.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 12.0)
            
          
            guard self.countItems > 1 else {
                return
            }
            self.countItems -= 1
        }
        else if collectionView == bodypartsCollView{
        
            let bodypartcell = collectionView.cellForItem(at: indexPath) as? FilterCategoryCollectionViewCell
            guard let bodypartcell = bodypartcell else { return }
            bodypartcell.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 12.0)
            bodypartcell.selectionImgView.image = UIImage(named: "ic_filterUncheck")
            
            guard self.countItems > 1 else {
                return
            }
            self.countItems -= 1
            
        }else{
            
            let filtercell = collectionView.cellForItem(at: indexPath) as? FilterCategoryCollectionViewCell
            guard let filtercell = filtercell else { return }
            filtercell.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 12.0)
            filtercell.selectionImgView.image = UIImage(named: "ic_filterUncheck")
            
            guard self.countItems > 1 else {
                return
            }
            self.countItems -= 1
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView == workoutTypeCollView {
            return CGSize(width: collectionView.frame.width*0.142, height: collectionView.frame.width*0.142)
        }
        else{
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        }
    }
    
}


