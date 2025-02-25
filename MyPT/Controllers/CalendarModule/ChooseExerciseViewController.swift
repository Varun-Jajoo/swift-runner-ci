//
//  ChooseExerciseViewController.swift
//  MyPT
//
//  Created by techsaga corp on 24/12/24.
//

import UIKit

class ChooseExerciseViewController: CommonViewController {

    //MARK: -------------IBOIUTLET
    var filterData:[[String:Any]]?
    var categoryData:[[String:Any]]?
    var sentBackData: ((Bool) -> Void)?
    var addExerciseCount:Int = 0{
        didSet{
            if addExerciseCount > 0 {
                self.addExerciseBtn.setTitle("ADD EXERCISE (\(addExerciseCount))", for: .normal)
            }else{
                self.addExerciseBtn.setTitle("ADD EXERCISE", for: .normal)
            }
        }
    }
        
    //MARK: --------------IBOUTLET
    @IBOutlet var customHeaderView: UIView!
    @IBOutlet weak var serchTxtFiled: UITextField!
    @IBOutlet weak var serchTxtFiledHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var logoBtn: UIButton!
    @IBOutlet weak var gymCategoryCollView: UICollectionView!
    @IBOutlet weak var gymCategoryCollViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var filterCategoryCollView: UICollectionView!
    @IBOutlet weak var filterCategoryCollViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var filterCategoryCollViewBottomConstrnt: NSLayoutConstraint!
    @IBOutlet weak var exerciseTblView: UITableView!
    @IBOutlet weak var addExerciseBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupFont()
        self.setupInputData()
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
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.choose_Exercise], setTintColor: .black, setTitleColor: UIColor.appWhite)
//        self.setRighMenu(rightImgs: [nil], setTitle: [AppStrings.skip_Str], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    func setupInputData(){
        
        self.exerciseTblView.register(UINib(nibName: "ExerciseTableViewCell", bundle: nil), forCellReuseIdentifier: "ExerciseTableViewCell")
        self.gymCategoryCollView.register(UINib(nibName: "FilterCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FilterCategoryCollectionViewCell")
        self.filterCategoryCollView.register(UINib(nibName: "FilterCategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FilterCategoryCollectionViewCell")
        
        self.categoryData = [
            ["title":"All muscles","filterImg": UIImage(named: "ic_running_ jogging") as Any],
            ["title":"All equipment's","filterImg": UIImage(named: "ic_barbell_ diagonal") as Any]
        ]
    
        self.gymCategoryCollView.reloadData()
    }
    
    func setupUI(){
        
        self.exerciseTblView.allowsMultipleSelection = true
        
        DispatchQueue.main.async {
            self.serchTxtFiled.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.logoBtn.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: 8.0)
            self.addExerciseBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    func setupFont(){
        self.serchTxtFiled.font = AppFont.semibold.size(14.0, familyName: familyManrope)
        self.serchTxtFiled.placeholderSet(placeHolder: "Search for Exercise", color: UIColor.txtDarkGray)
        self.serchTxtFiled.setLeftPaddingWithImage(50.0, 0, AppImages.search_normal)
        
        self.addExerciseBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()
        self.serchTxtFiledHeightConstrnt.constant = 46.0
        self.gymCategoryCollViewHeightConstrnt.constant = 46.0
//        self.filterCategoryCollViewHeightConstrnt.constant = 46.0
        
        if let countF = filterData?.count, countF != 0 {
            self.filterCategoryCollViewHeightConstrnt.constant = 46.0
            self.filterCategoryCollViewBottomConstrnt.constant = 10.0
        }else{
            self.filterCategoryCollViewHeightConstrnt.constant = 1.0
            self.filterCategoryCollViewBottomConstrnt.constant = 2.0
        }
        
        
//        self.filterCategoryCollViewBottomConstrnt.constant = 20.0
        
        self.customHeaderView.layoutIfNeeded()
        self.exerciseTblView.reloadData()
    }
    
    @IBAction func addExerciseBtnActn(_ sender: UIButton) {
        sentBackData?(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        guard let headerView = exerciseTblView.tableHeaderView else {return}
//        let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
//        if customHeaderView.frame.size.height != size.height {
//            customHeaderView.frame.size.height = size.height
//            exerciseTblView.tableHeaderView = customHeaderView
//            exerciseTblView.layoutIfNeeded()
//        }
//    }
    
}

//MARK: -------------EXTENSION FOR UITABLEVIEW DELEGATE/DATASOURCE
extension ChooseExerciseViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ExerciseTableViewCell = exerciseTblView.dequeueReusableCell(withIdentifier: "ExerciseTableViewCell", for: indexPath) as! ExerciseTableViewCell
     
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as! ExerciseTableViewCell
        
        selectedCell.cellMBV.setCornerWithShadow(borderWidth: 1.0, borderColor: UIColor(red: 158.0/255.0, green: 188.0/255.0, blue: 255.0/255.0, alpha: 1.0), shadowColor: UIColor.black, offSet: .zero, opacity: 0.4, shadowRadius: 0.5, cornerRadious: 12.0)
        
        selectedCell.checkBtn.setImage(UIImage(named: "ic_filterChecked"), for: .normal)
        
        self.addExerciseCount += 1
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deSelectedCell = tableView.cellForRow(at: indexPath) as! ExerciseTableViewCell
        
        deSelectedCell.cellMBV.setCornerWithShadow(borderWidth: 1.0, borderColor: UIColor.appBorder, shadowColor: UIColor.black, offSet: .zero, opacity: 0.4, shadowRadius: 0.5, cornerRadious: 12.0)
        
        deSelectedCell.checkBtn.setImage(UIImage(named: "ic_filterUncheck"), for: .normal)
        guard self.addExerciseCount > -1 else {
            return
        }
        self.addExerciseCount -= 1
    }
    /*
     func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
         let deSelectedCell = tableView.cellForRow(at: indexPath) as! PointsTableViewCell
         deSelectedCell.leftImgView.image = nil
     }
     */
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return customHeaderView
    }
    
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
        
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
//       {
//           return UITableView.automaticDimension
//       }
    
       func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

           return UITableView.automaticDimension

       }
}


//MARK: -----------------EXTENSION FOR UICOLLECTIONVIEW DATASOURCE/DELEGATE
extension ChooseExerciseViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == gymCategoryCollView {
            return categoryData?.count ?? 0
        }else{
            return filterData?.count ?? 0
        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == gymCategoryCollView {
            let cell:FilterCategoryCollectionViewCell = gymCategoryCollView.dequeueReusableCell(withReuseIdentifier: "FilterCategoryCollectionViewCell", for: indexPath) as! FilterCategoryCollectionViewCell
            cell.gymCategoryImgView.image = categoryData?[indexPath.row]["filterImg"] as? UIImage //filterImg
            cell.gymCategoryNameLbl.text = categoryData?[indexPath.row]["title"] as? String
            
            return cell
        } else{
            let cell:FilterCategoryCollectionViewCell = filterCategoryCollView.dequeueReusableCell(withReuseIdentifier: "FilterCategoryCollectionViewCell", for: indexPath) as! FilterCategoryCollectionViewCell
            DispatchQueue.main.async {
                cell.cellMBV.setCornerRadius(borderWidth: 1.0, borderColor: UIColor.appBorder, cornerRadious: cell.cellMBV.frame.size.height/2.0)
            }
            
            cell.gymCategoryImgView.image = filterData?[indexPath.row]["filterImg"] as? UIImage //filterImg
            cell.selectionImgView.image = UIImage(named: "ic_cross_circle")
            cell.gymCategoryNameLbl.text = filterData?[indexPath.row]["title"] as? String
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            let vc:ExerciseFilterPopupViewController = ExerciseFilterPopupViewController.instantiate(appStoryboard: .calendar)
            vc.modalPresentationStyle = .automatic
            vc.setupExerciseFilterFlow = .muscles
            vc.sentBackFilterData = { [weak self] getbackData in
                
                guard let self = self else { return  }
                
                self.filterData = [
                    ["title": getbackData.first as? String as Any,"filterImg": UIImage(named: "ic_running_ jogging") as Any],
                    ["title":getbackData.first as? String as Any,"filterImg": UIImage(named: "ic_barbell_ diagonal") as Any]
                ]
            
                self.filterCategoryCollView.reloadData()
                
            }
            self.navigationController?.present(vc, animated: true)
        }else{
            let vc:ExerciseFilterPopupViewController = ExerciseFilterPopupViewController.instantiate(appStoryboard: .calendar)
            vc.modalPresentationStyle = .automatic
            vc.setupExerciseFilterFlow = .equipment
            
            vc.sentBackFilterData = { [weak self] getbackData in
                
                guard let self = self else { return  }
                
                self.filterData = [
                    ["title": getbackData.first as? String as Any,"filterImg": UIImage(named: "ic_running_ jogging") as Any],
                    ["title":getbackData.first as? String as Any,"filterImg": UIImage(named: "ic_barbell_ diagonal") as Any]
                ]
            
                self.filterCategoryCollView.reloadData()
                
            }
            
            self.navigationController?.present(vc, animated: true)
        }
       
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        self.updateViewConstraints()
    }
}
