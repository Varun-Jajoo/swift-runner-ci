//
//  EditExerciseViewController.swift
//  MyPT
//
//  Created by techsaga corp on 31/12/24.
//

import UIKit

class EditExerciseViewController: CommonViewController {

    //MARK: -------------- VARIABLE
    var expendedIndex: IndexPath = IndexPath(row: 0, section: 0)
    
    var addSets:[Any]?
    
    //MARK: --------------IBOUTLET
    @IBOutlet var customFooterView: UIView!
    @IBOutlet weak var addsetsBtn: UIButton!
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var workoutImgView: UIImageView!
    @IBOutlet weak var workoutDetails1MBV: UIStackView!
    @IBOutlet weak var workoutDetails2MBV: UIStackView!
    @IBOutlet weak var duration1MBV: UIView!
    @IBOutlet weak var calories1MBV: UIView!
    @IBOutlet weak var duration2MBV: UIView!
    @IBOutlet weak var calories2MBV: UIView!
    @IBOutlet weak var durationCount1Lbl: UILabel!
    @IBOutlet weak var durationTitle1Lbl: UILabel!
    @IBOutlet weak var caloriesCount1Lbl: UILabel!
    @IBOutlet weak var caloriesTitle1Lbl: UILabel!
    @IBOutlet weak var durationCount2Lbl: UILabel!
    @IBOutlet weak var durationTitle2Lbl: UILabel!
    @IBOutlet weak var caloriesCount2Lbl: UILabel!
    @IBOutlet weak var caloriesTitle2Lbl: UILabel!
    @IBOutlet weak var setListTblView: UITableView!
    @IBOutlet weak var setListTblViewHeightConstrnt: NSLayoutConstraint!
    @IBOutlet weak var saveBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addSets = [1,1]
        
        self.setupFont()
        self.setupInputData()
        self.addsetsBtn.addTarget(self, action: #selector(addSetsBtnActn(sender: )), for: .touchUpInside)
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
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [AppStrings.edit_Exercise], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupUI()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        if setListTblView.contentSize.height != 0 {
            self.setListTblViewHeightConstrnt.constant = self.setListTblView.contentSize.height
        }
        self.view.layoutIfNeeded()
    }
    
    
    @IBAction func saveBtnActn(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupInputData(){
        workoutDetails1MBV.isHidden = false
        workoutDetails2MBV.isHidden = true
        
        self.setListTblView.register(UINib(nibName: "AddSetsTableViewCell", bundle: nil), forCellReuseIdentifier: "AddSetsTableViewCell")
    }
    
    func setupUI(){
        DispatchQueue.main.async {
            self.workoutImgView.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 24.0)
            
//            self.workoutImgView.setCornerWithShadow(borderWidth: 0, borderColor: nil, shadowColor: UIColor.black, offSet: .zero, opacity: 0.4, shadowRadius: 12.0, cornerRadious: 24)
            
            self.duration1MBV.addGradient(colors: [UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 1.0),UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1.0),UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1.0)], locations: [0,0.8], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0.8, y: 1.0))
            self.calories1MBV.addGradient(colors: [UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 1.0),UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1.0),UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1.0)], locations: [0,0.8], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0.8, y: 1.0))
            
            self.duration2MBV.addGradient(colors: [UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 1.0),UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1.0),UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1.0)], locations: [0,0.8], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0.8, y: 1.0))
            self.calories2MBV.addGradient(colors: [UIColor(red: 71.0/255.0, green: 77.0/255.0, blue: 96.0/255.0, alpha: 1.0),UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1.0),UIColor(red: 16.0/255.0, green: 17.0/255.0, blue: 19.0/255.0, alpha: 1.0)], locations: [0,0.8], startPoint: CGPoint(x: 0, y: 0), endPoint: CGPoint(x: 0.8, y: 1.0))
            
            self.duration1MBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.calories1MBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.duration2MBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.calories2MBV.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
            self.saveBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    func setupFont(){
        self.topTitleLbl.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.durationCount1Lbl.font = AppFont.medium.size(30.0, familyName: familyClashDisplay)
        self.durationTitle1Lbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.caloriesCount1Lbl.font = AppFont.medium.size(30.0, familyName: familyClashDisplay)
        self.caloriesTitle1Lbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.durationCount2Lbl.font = AppFont.medium.size(30.0, familyName: familyManrope)
        self.durationTitle2Lbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.caloriesCount2Lbl.font = AppFont.semibold.size(30.0, familyName: familyClashDisplay)
        self.caloriesTitle2Lbl.font = AppFont.semibold.size(12.0, familyName: familyManrope)
        self.saveBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
        self.addsetsBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
    }

}


extension EditExerciseViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addSets?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:AddSetsTableViewCell = setListTblView.dequeueReusableCell(withIdentifier: "AddSetsTableViewCell", for: indexPath) as! AddSetsTableViewCell
        
        if expendedIndex.row == indexPath.row {
            cell.expendingImgView.image = UIImage(named: "ic_arrow_up")
            
            cell.innnerTblView.isHidden = false
            cell.innnerTblViewHeightConstrnt.constant = 195.0
        }else{
            cell.expendingImgView.image = UIImage(named: "ic_arrow_down")
//            cell.expendingImgView.image = UIImage(named: "ic_arrow_up")
            cell.innnerTblView.isHidden = true
            cell.innnerTblViewHeightConstrnt.constant = 1.0
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        expendedIndex = indexPath
        setListTblView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.updateViewConstraints()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
        
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return customFooterView
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
    @objc func addSetsBtnActn(sender: UIButton){
        
        print("add Sets btn clicked")
        
        self.addSets?.append(1)
        self.setListTblView.reloadData()

    }
}
