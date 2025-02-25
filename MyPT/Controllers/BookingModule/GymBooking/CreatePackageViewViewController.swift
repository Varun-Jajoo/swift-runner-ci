//
//  CreatePackageViewViewController.swift
//  MyPT
//
//  Created by techsaga corp on 29/11/24.
//

import UIKit

class CreatePackageViewViewController: CommonViewController {

    //MARK: --------------VARIABLE
    var packageData:[[String:Any]]?
   
    //MARK: -------------IBOUTLET
    @IBOutlet weak var topTitleLbl: UILabel!
    @IBOutlet weak var packageList: UITableView!
    @IBOutlet weak var continueBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        packageData = [["title":"One on One","trainerImg":AppImages.one_to_one as Any, "trainerImg_selected":AppImages.one_to_one_Selected as Any],
                       ["title":"With Buddy","trainerImg":AppImages.withBuddy as Any, "trainerImg_selected":AppImages.withBuddy_selected as Any],
                       ["title":"With Group","trainerImg":AppImages.withGroup as Any, "trainerImg_selected":AppImages.withGroup_selected as Any]
        ]

        packageList.register(UINib(nibName: "TrainerTypeTableViewCell", bundle: nil), forCellReuseIdentifier: "TrainerTypeTableViewCell")
        
        self.continueBtn.isUserInteractionEnabled = false
        self.setupUI()
    }
    
    deinit {
        print("------\(#function)------\(String(describing: Self.self))------" )
    }
    
    @IBAction func continueBtnActn(_ sender: Any) {
        print("continue btn clicked..")
        let vc:ChooseSessionViewController = ChooseSessionViewController.instantiate(appStoryboard: .booking)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationColor(setColor: .clear)
        self.statusBarColor(setColor: .clear)
        setNavUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Automatically select the first cell
        let firstIndexPath = IndexPath(item: 0, section: 0)
        DispatchQueue.main.async {
            //packageList
            
            self.packageList.selectRow(at: firstIndexPath, animated: true, scrollPosition: .top)
            // Optional: perform any additional setup for the selected cell
            self.packageList.delegate?.tableView?(self.packageList, didSelectRowAt: firstIndexPath)
            self.view.layoutIfNeeded()
        }
    }
    
    func setNavUI(){
        self.setupNavigationBarProgress(progressBarWidth: self.view.frame.size.width*0.37)
        self.setProgress(0.2)
        
        self.setLeftMenu(leftImgs: [AppImages.backarrow], setTitle: [""], setTintColor: .black, setTitleColor: .clear)
        self.setRighMenu(rightImgs: [nil], setTitle: [AppStrings.skip_Str], setTintColor: .black, setTitleColor: UIColor.appWhite)
    }
    
    //MARK: ---------- SET UI
    func setupUI(){
        DispatchQueue.main.async {
            self.continueBtn.setCornerRadius(borderWidth: 0, borderColor: nil, cornerRadious: 12.0)
        }
    }
    
    //------------------************Font
    func setUpFont(){
        self.topTitleLbl.font = AppFont.medium.size(32.0, familyName: familyClashDisplay)
        self.continueBtn.titleLabel?.font = AppFont.bold.size(16.0, familyName: familyManrope)
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

extension CreatePackageViewViewController:UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return packageData?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:TrainerTypeTableViewCell = packageList.dequeueReusableCell(withIdentifier: "TrainerTypeTableViewCell", for: indexPath) as! TrainerTypeTableViewCell
        cell.titleLbl.isHidden = true
        cell.trainerImgView.isHidden = true
        
        cell.setSelectdBGCell(packageData?[indexPath.row]["trainerImg"] as? UIImage, selectedImg: packageData?[indexPath.row]["trainerImg_selected"] as? UIImage, isSelectedCell: false)
        
        self.enableContinueBtn(isSelected: true)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedCell = tableView.cellForRow(at: indexPath) as! TrainerTypeTableViewCell
        
        selectedCell.setSelectdBGCell(packageData?[indexPath.row]["trainerImg"] as? UIImage, selectedImg: packageData?[indexPath.row]["trainerImg_selected"] as? UIImage, isSelectedCell: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deSelectedCell = tableView.cellForRow(at: indexPath) as! TrainerTypeTableViewCell
        
        deSelectedCell.setSelectdBGCell(packageData?[indexPath.row]["trainerImg"] as? UIImage, selectedImg: packageData?[indexPath.row]["trainerImg_selected"] as? UIImage, isSelectedCell: false)
    }
    
    
}
